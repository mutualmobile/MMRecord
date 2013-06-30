// MMRecord.m
//
// Copyright (c) 2013 Mutual Mobile (http://www.mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MMRecord.h"

#import "MMRecordCache.h"
#import "MMRecordProtoRecord.h"
#import "MMRecordRepresentation.h"
#import "MMRecordResponse.h"
#import "MMServer.h"

/*
 * Does ARC support support GCD objects?
 * It does if the minimum deployment target is iOS 6+ or Mac OS X 8+
 */
#if TARGET_OS_IPHONE

// Compiling for iOS

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 // iOS 6.0 or later
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else                                         // iOS 5.X or earlier
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

#else

// Compiling for Mac OS X

#if MAC_OS_X_VERSION_MIN_REQUIRED >= 1080     // Mac OS X 10.8 or later
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else
#define NEEDS_DISPATCH_RETAIN_RELEASE 1     // Mac OS X 10.7 or earlier
#endif

#endif

@class MMRecordErrorHandler;

NSString* const MMRecordErrorDomain = @"com.mutualmobile.mmrecord";

static dispatch_group_t _mmrecord_request_group = nil;
static dispatch_semaphore_t _mmrecord_request_semaphore = nil;
static BOOL _mmrecord_batch_requests = NO;
static MMRecordLoggingLevel _mmrecord_logging_level = 0;

static NSMutableDictionary* MM_registeredServerClasses;
static MMRecordOptions* MM_recordOptions;
static MMRecordErrorHandler* MM_errorHandler;

NSString * const MMRecordEntityPrimaryAttributeKey = @"MMRecordEntityPrimaryAttributeKey";
NSString * const MMRecordAttributeAlternateNameKey = @"MMRecordAttributeAlternateNameKey";

// This class is used for error handling with MMRecord.  You can specify error levels and this class
// will be used to decide which errors are logged and which errors cause a fatal error that will
// result in an import failure.  An instance of this class will be passed to virtually every private
// parsing method.
@interface MMRecordErrorHandler : NSObject {
    MMRecordErrorCode   mostRecentFatalErrorCode_;
    NSString *          mostRecentFatalErrorDescription_;
    BOOL                receivedFatalError_;
}

- (BOOL)receivedFatalError;
- (NSError *)fatalError;

- (void)handleErrorCode:(MMRecordErrorCode)errorCode description:(NSString*)description;
- (void)handleFatalErrorCode:(MMRecordErrorCode)errorCode description:(NSString*)description;

@end

@interface MMRecordRequestState : NSObject

@property (nonatomic, strong) MMRecordOptions *options;

@property (nonatomic, getter = isBatched) BOOL batched;
@property (nonatomic) dispatch_queue_t parsingQueue;
@property (nonatomic) dispatch_group_t dispatchGroup;

@property (nonatomic, copy) NSString *URN;
@property (nonatomic, copy) NSDictionary *data;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;

@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, copy) NSArray *records;
@property (nonatomic, copy) NSArray *objectIDs;

@property (nonatomic, copy) NSString *cacheKey;
@property (nonatomic, copy) NSString *keyPathForMetaData;

@property (nonatomic, strong) id domain;
@property (nonatomic, copy) id (^customResponseBlock)(id JSON);
@property (nonatomic, copy) void (^resultBlock)(NSArray *records, id customResponseObject);
@property (nonatomic, copy) void (^failureBlock)(NSError* error);

+ (MMRecordRequestState *)requestStateForURN:(NSString*)URN
                                        data:(NSDictionary*)data
                                     context:(NSManagedObjectContext*)context
                                      domain:(id)domain
                         customResponseBlock:(id (^)(id JSON))customResponseBlock
                                 resultBlock:(void(^)(NSArray *records, id customResponseObject))resultBlock
                                failureBlock:(void(^)(NSError* error))failureBlock;

@end


// This category adds functionality to the CoreData framework's `NSManagedObjectContext` class.
// It provides support for convenience functions for context merging as well as obtaining an
// `NSEntityDescription` object for a given class name.
@interface NSManagedObjectContext (MMRecord)

- (void)MMRecord_startObservingWithContext:(NSManagedObjectContext*)context;
- (void)MMRecord_stopObservingWithContext:(NSManagedObjectContext*)context;
- (NSEntityDescription*)MMRecord_entityForClass:(Class)managedObjectClass;

@end


// This category adds custom errors and descriptions that describe error conditions in `MMRecord`.
@interface NSError (MMRecord)

+ (NSString*)descriptionForMCErrorCode:(MMRecordErrorCode)errorCode;
+ (NSError *)errorWithMMRecordCode:(MMRecordErrorCode)errorCode description:(NSString*)description;

@end

// This extension to `MMRecord` provides convenience methods for obtaining and restoring options.
@interface MMRecord (MMRecordOptionsInternal)

+ (MMRecordOptions *)currentOptions;
+ (MMRecordOptions *)defaultOptions;
+ (void)restoreDefaultOptions;

@end

@implementation MMRecord

#pragma mark - Required Subclass Methods

+ (NSString*)keyPathForResponseObject {
    [self doesNotRecognizeSelector:_cmd];
    
    return nil;
}


#pragma mark - Optional Subclass Methods

+ (BOOL)shouldUseSubEntityRecordClassToRepresentData:(NSDictionary *)dict {
    return NO;
}

+ (Class)representationClass {
    return [MMRecordRepresentation class];
}

+ (NSDateFormatter *)dateFormatter {
    return nil;
}

- (NSString *)recordDetailURN {
    return nil;
}

+ (NSString *)keyPathForMetaData {
    return nil;
}

+ (BOOL)isRecordLevelCachingEnabled {
    return NO;
}


#pragma mark - Request Options Configuration Methods

+ (void)setOptions:(MMRecordOptions *)options {
    MM_recordOptions = options;
}

+ (MMRecordOptions *)currentOptions {
    if (MM_recordOptions != nil) {
        return MM_recordOptions;
    }
    
    return [self defaultOptions];
}

+ (MMRecordOptions *)defaultOptions {
    MMRecordOptions *options = [[MMRecordOptions alloc] init];
    options.automaticallyPersistsRecords = YES;
    options.callbackQueue = dispatch_get_main_queue();
    options.isRecordLevelCachingEnabled = NO;
    options.keyPathForResponseObject = [self keyPathForResponseObject];
    options.keyPathForMetaData = [self keyPathForMetaData];
    options.pageManagerClass = [[self server] pageManagerClass];
    options.deleteOrphanedRecordBlock = nil;
    return options;
}

+ (void)restoreDefaultOptions {
    if ([self batchRequests] == NO) {
        MM_recordOptions = nil;
    }
}


#pragma mark - Error Handling

+ (MMRecordErrorHandler *)currentErrorHandler {
    if (MM_errorHandler) {
        return MM_errorHandler;
    }
    
    MM_errorHandler = [MMRecordErrorHandler new];
    return MM_errorHandler;
}

+ (void)resetErrorHandler {
    MM_errorHandler = nil;
}


#pragma mark - Setting and Accessing the MMServer Class

+ (BOOL)registerServerClass:(Class)server {
    if ([server isSubclassOfClass:[MMServer class]]) {
        if (MM_registeredServerClasses == nil) {
            MM_registeredServerClasses = [NSMutableDictionary dictionary];
        }
        
        [MM_registeredServerClasses setValue:NSStringFromClass(server) forKey:NSStringFromClass(self)];
        
        return YES;
    }
    
    if (server == nil) {
        [MM_registeredServerClasses setValue:nil forKey:NSStringFromClass(self)];
    }
    
    return NO;
}

+ (Class)server {
    if ([self hasRegisteredServerClass]) {
        return [self registeredServerClass];
    } else if ([self superclassHasRegisteredServerClass]) {
        return [self registeredServerClassFromSuperclass];
    } else {
        return nil;
    }
}

+ (BOOL)hasRegisteredServerClass {
    if ([self registeredServerClass] == nil) {
        return NO;
    }
    
    return YES;
}

+ (Class)registeredServerClass {
    NSString *serverName = [MM_registeredServerClasses valueForKey:NSStringFromClass(self)];
    
    if (serverName != nil) {
        return NSClassFromString(serverName);
    }
    
    return nil;
}

+ (BOOL)superclassHasRegisteredServerClass {
    if ([self registeredServerClassFromSuperclass] == nil) {
        return NO;
    }
    
    return YES;
}

+ (Class)registeredServerClassFromSuperclass {
    id tempObject = [self alloc];
    Class superClass = [tempObject superclass];
    
    if ([superClass respondsToSelector:@selector(server)]) {
        return [superClass server];
    }
    
    return nil;
}


#pragma mark - Request Cancellation

+ (void)cancelRequestsWithDomain:(id)domain {
    [[self server] cancelRequestsWithDomain:domain];
}


#pragma mark - Logging Level

+ (void)setLoggingLevel:(MMRecordLoggingLevel)loggingLevel {
    _mmrecord_logging_level = loggingLevel;
}

+ (MMRecordLoggingLevel)loggingLevel {
    return _mmrecord_logging_level;
}


#pragma mark - Internal Dispatch Methods

+ (dispatch_queue_t)parsingQueue {
    static dispatch_queue_t _parsing_queue = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _parsing_queue = dispatch_queue_create("com.mutualmobile.mmrecord", NULL);
    });
    
    return _parsing_queue;
}

+ (void)setDispatchGroup:(dispatch_group_t)dispatchGroup {
    if (_mmrecord_request_semaphore == nil) {
        _mmrecord_request_semaphore = dispatch_semaphore_create(1);
    }
    
    dispatch_semaphore_wait(_mmrecord_request_semaphore, DISPATCH_TIME_FOREVER);
    if (dispatchGroup != _mmrecord_request_group) {
        if (_mmrecord_request_group) {
#if NEEDS_DISPATCH_RETAIN_RELEASE
            dispatch_release(_mmrecord_request_group);
#endif
            _mmrecord_request_group = nil;
        }
        
        if (dispatchGroup) {
#if NEEDS_DISPATCH_RETAIN_RELEASE
            dispatch_retain(dispatchGroup);
#endif
            _mmrecord_request_group = dispatchGroup;
        }
    }
    dispatch_semaphore_signal(_mmrecord_request_semaphore);
}

+ (dispatch_group_t)dispatchGroup {
    if (_mmrecord_request_semaphore == nil) {
        _mmrecord_request_semaphore = dispatch_semaphore_create(1);
    }
    
    dispatch_semaphore_wait(_mmrecord_request_semaphore, DISPATCH_TIME_FOREVER);
    if(_mmrecord_request_group == NULL) {
        _mmrecord_request_group = dispatch_group_create();
    }
    dispatch_semaphore_signal(_mmrecord_request_semaphore);
    return _mmrecord_request_group;
}


#pragma mark - Batching

+ (void)setBatchDispatchGroup:(BOOL)batch {
    _mmrecord_batch_requests = batch;
    
    if (batch) {
        [self setDispatchGroup:dispatch_group_create()];
    } else {
        [self setDispatchGroup:nil];
    }
}

+ (BOOL)batchRequests {
    return _mmrecord_batch_requests;
}


#pragma mark - Refactoring

+ (void)configureBackgroundContext:(NSManagedObjectContext *)backgroundContext
                       withOptions:(MMRecordOptions *)options
                       mainContext:(NSManagedObjectContext *)mainContext
              mainStoreCoordinator:(NSPersistentStoreCoordinator *)mainStoreCoordinator {
    if (options.automaticallyPersistsRecords == NO) {
        if ([backgroundContext respondsToSelector:@selector(setParentContext:)]) {
            [backgroundContext setParentContext:mainContext];
        }
    } else {
        [backgroundContext setPersistentStoreCoordinator:mainStoreCoordinator];
    }
}

+ (void)configureState:(MMRecordRequestState *)state forCurrentRequestWithOptions:(MMRecordOptions *)options {
    state.options = options;
    state.batched = [self batchRequests];
    state.coordinator = state.context.persistentStoreCoordinator;
    state.dispatchGroup = [self dispatchGroup];
    state.parsingQueue = [self parsingQueue];
    
    if (options.isRecordLevelCachingEnabled) {
        state.cacheKey = [self keyForURN:state.URN data:state.data];
        state.keyPathForMetaData = [self keyPathForMetaData];
    }
}


#pragma mark - Request Methods

+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)data
                    context:(NSManagedObjectContext *)context
                     domain:(id)domain
        customResponseBlock:(id (^)(id JSON))customResponseBlock
                resultBlock:(void(^)(NSArray *records, id customResponseObject))resultBlock
               failureBlock:(void(^)(NSError *error))failureBlock {
    MMRecordRequestState *state = [MMRecordRequestState requestStateForURN:URN
                                                                      data:data
                                                                   context:context
                                                                    domain:domain
                                                       customResponseBlock:customResponseBlock
                                                               resultBlock:resultBlock
                                                              failureBlock:failureBlock];
    [self preflightRequestWithRequestState:state];
}

+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)data
                    context:(NSManagedObjectContext*)context
                     domain:(id)domain
                resultBlock:(void (^)(NSArray *records))resultBlock
               failureBlock:(void (^)(NSError *error))failureBlock {
    [self
     startRequestWithURN:URN
     data:data context:context
     domain:domain
     customResponseBlock:nil
     resultBlock:^(NSArray *records, id customResponseObject) {
         if (resultBlock != nil) {
             resultBlock(records);
         }
     } failureBlock:failureBlock];
}

- (void)startDetailRequestWithDomain:(id)domain
                         resultBlock:(void (^)(MMRecord *object))resultBlock
                        failureBlock:(void (^)(NSError *error))failureBlock {
    id recordDetailURN = [self recordDetailURN];
    
    [[self class]
     startRequestWithURN:recordDetailURN
     data:nil
     context:self.managedObjectContext
     domain:domain
     customResponseBlock:nil
     resultBlock:^(NSArray *objects, id customResponseObject) {
         if ([objects count] > 0) {
             id object = [objects objectAtIndex:0];
             
             if (resultBlock != nil) {
                 resultBlock(object);
             }
         } else {
             if (resultBlock != nil) {
                 resultBlock(nil);
             }
         }
     } failureBlock:^(NSError *error) {
         if (failureBlock != nil) {
             failureBlock(error);
         }
     }];
}

+ (void)startBatchedRequestsInExecutionBlock:(void(^)())batchExecutionBlock
                         withCompletionBlock:(void(^)())completionBlock {
    [self setBatchDispatchGroup:YES];
    batchExecutionBlock();
    dispatch_group_notify([self dispatchGroup], dispatch_get_main_queue(), completionBlock);
    [self setBatchDispatchGroup:NO];
    [self restoreDefaultOptions];
}


#pragma mark - Performing Requests

+ (void)preflightRequestWithRequestState:(MMRecordRequestState *)state {
    MMRecordOptions *options = [self currentOptions];
    
    [self configureState:state forCurrentRequestWithOptions:options];
    [self resetErrorHandler];
    [self validateSetUpForStartRequest];
    
    BOOL cached = [self shortCircuitRequestByReturningCachedResultsForState:state options:options];
    
    if (cached == NO) {
        [self performRequestWithRequestState:state];
    }
}

// You should really do your preflight check before calling this method.
+ (void)performRequestWithRequestState:(MMRecordRequestState *)state {
    MMRecordOptions *options = [self currentOptions];
    
#if NEEDS_DISPATCH_RETAIN_RELEASE
    dispatch_retain(state.dispatchGroup);
#endif
    
    if ([state isBatched]) {
        dispatch_group_enter(state.dispatchGroup);
    }
    
    [[self server]
     startRequestWithURN:state.URN
     data:state.data
     paged:NO
     domain:state.domain
     batched:state.isBatched
     dispatchGroup:state.dispatchGroup
     responseBlock:^(id responseObject) {
         dispatch_queue_t parsingQueue = state.parsingQueue;
         dispatch_group_async(state.dispatchGroup, parsingQueue, ^{
             [self completeRequestForResponse:responseObject
                                        state:state
                                      options:options];
             
             if ([state isBatched]) {
                 dispatch_group_leave(state.dispatchGroup);
             }
             
#if NEEDS_DISPATCH_RETAIN_RELEASE
             dispatch_release(state.dispatchGroup);
#endif
         });
     } failureBlock:^(NSError *error) {
         if (state.failureBlock != nil) {
             state.failureBlock(error);
         }
         
         if ([state isBatched]) {
             dispatch_group_leave(state.dispatchGroup);
         }
         
#if NEEDS_DISPATCH_RETAIN_RELEASE
         dispatch_release(state.dispatchGroup);
#endif
     }];
    
    [self restoreDefaultOptions];
}


#pragma mark - Finalizing Requests

+ (void)completeRequestForResponse:(id)responseObject
                             state:(MMRecordRequestState *)state
                           options:(MMRecordOptions *)options {
    state.backgroundContext = [[NSManagedObjectContext alloc] init];
    state.responseObject = responseObject;
    
    [self configureBackgroundContext:state.backgroundContext
                         withOptions:options
                         mainContext:state.context
                mainStoreCoordinator:state.coordinator];
    
    state.records = [self recordsFromResponseObject:responseObject
                                            options:options
                                              state:state
                                            context:state.backgroundContext];
    
    [self conditionallyDeleteRecordsOphanedByResponse:responseObject
                                     populatedRecords:state.records
                                              options:options
                                                state:state
                                              context:state.backgroundContext];
    
    [self performCachingForRecords:state.records
                fromResponseObject:state.responseObject
                      requestState:state
                       withOptions:options];
    
    state.objectIDs = [self objectIDsForRecords:state.records
                                  onMainContext:state.context
                          fromBackgroundContext:state.backgroundContext];
    
    if ([[self currentErrorHandler] receivedFatalError] == NO) {
        [self passRequestWithRequestState:state options:options];
    } else {
        [self failRequestWithRequestState:state options:options];
    }
}

+ (void)passRequestWithRequestState:(MMRecordRequestState *)state
                            options:(MMRecordOptions *)options {
    [self invokeResultBlockWithRequestState:state options:options];
}

+ (void)failRequestWithRequestState:(MMRecordRequestState *)state
                            options:(MMRecordOptions *)options {
    if ([state isBatched]) {
        dispatch_group_enter(state.dispatchGroup);
    }
    
    dispatch_group_async(state.dispatchGroup, options.callbackQueue, ^{
        state.failureBlock([[self currentErrorHandler] fatalError]);
        
        if ([state isBatched]) {
            dispatch_group_leave(state.dispatchGroup);
        }
    });
}

+ (void)invokeResultBlockWithRequestState:(MMRecordRequestState *)state
                                  options:(MMRecordOptions *)options {
    if ([state isBatched]) {
        dispatch_group_enter(state.dispatchGroup);
    }
    
    dispatch_group_async(state.dispatchGroup, options.callbackQueue, ^{
        id customResponseObject = (state.customResponseBlock) ? state.customResponseBlock(state.responseObject) : nil;
        
        NSArray *mainContextRecords = [self mainContextRecordsFromObjectIDs:state.objectIDs mainContext:state.context];
        
        if (state.resultBlock != nil) {
            state.resultBlock(mainContextRecords,customResponseObject);
        }
        
        if ([state isBatched]) {
            dispatch_group_leave(state.dispatchGroup);
        }
    });
}


#pragma mark - Caching

+ (BOOL)shortCircuitRequestByReturningCachedResultsForState:(MMRecordRequestState *)state
                                                    options:(MMRecordOptions *)options {
    if (options.isRecordLevelCachingEnabled) {
        BOOL cached = [MMRecordCache hasResultsForKey:state.cacheKey];
        
        if (cached) {
            NSURLRequest *request = [self cachingRequestWithURN:state.URN data:state.data];
            
            [MMRecordCache
             getCachedResultsForRequest:request
             cacheKey:state.cacheKey
             metaKeyPath:state.keyPathForMetaData
             context:state.context
             cacheResultBlock:^(NSArray *cachedResults, id responseObject) {
                 state.responseObject = responseObject;
                 state.records = cachedResults;
                 
                 if (cachedResults) {
                     NSMutableArray *objectIDs = [NSMutableArray array];
                     
                     for (MMRecord *record in cachedResults) {
                         [objectIDs addObject:record.objectID];
                     }
                     
                     state.objectIDs = objectIDs;
                     
                     [self passRequestWithRequestState:state options:options];
                 }
             }];
        }
        
        return cached;
    } else {
        return NO;
    }
}

+ (void)performCachingForRecords:(NSArray *)records
              fromResponseObject:(id)responseObject
                    requestState:(MMRecordRequestState *)state
                     withOptions:(MMRecordOptions *)options {
    if ([options isRecordLevelCachingEnabled]) {
        NSDictionary *metadata = nil;
        
        if ([responseObject isKindOfClass:[NSDictionary class]] && state.keyPathForMetaData != nil) {
            metadata = [responseObject objectForKey:state.keyPathForMetaData];
        }
        
        [MMRecordCache cacheRecords:records
                       withMetadata:metadata
                             forKey:state.cacheKey
                        fromContext:state.context];
    }
}

+ (NSURLRequest *)cachingRequestWithURN:(NSString *)URN data:(NSDictionary *)data {
    return [[self server] requestWithURN:URN data:data];
}

+ (NSString *)keyForURN:(NSString *)URN data:(NSDictionary *)data {
    NSURLRequest *request = [self cachingRequestWithURN:URN data:data];
    
    return request.URL.absoluteString;
}


#pragma mark - Validation

+ (BOOL)validateSetUpForStartRequest {
    // Make sure the server is set properly.
    if ([self server] == nil) {
        MMRecordErrorHandler *errorHandler = [self currentErrorHandler];
        [errorHandler handleFatalErrorCode:MMRecordErrorCodeUndefinedServer
                               description:[NSString stringWithFormat:@"No server defined for class: %@", NSStringFromClass(self)]];
    }
    
    return YES;
}


#pragma mark - Parsing Helper Methods

+ (NSArray*)recordsFromResponseObject:(id)responseObject
                              options:(MMRecordOptions *)options
                                state:(MMRecordRequestState *)state
                              context:(NSManagedObjectContext *)context {
    if (responseObject == nil) {
        [[self currentErrorHandler] handleFatalErrorCode:MMRecordErrorCodeInvalidResponseFormat
                                             description:@"The response object should not be nil"];
        return nil;
    }
    
    NSString *keyPathForResponseObject = options.keyPathForResponseObject;
    
    NSArray *recordResponseArray = [self parsingArrayFromResponseObject:responseObject
                                               keyPathForResponseObject:keyPathForResponseObject];
    NSEntityDescription *initialEntity = [context MMRecord_entityForClass:self];
    
    if ([NSClassFromString([initialEntity managedObjectClassName]) isSubclassOfClass:[MMRecord class]] == NO) {
        MMRecordErrorHandler *errorHandler = [self currentErrorHandler];
        [errorHandler handleFatalErrorCode:MMRecordErrorCodeInvalidEntityDescription
                               description:@"Initial Entity is not a subclass of MMRecord"];
        return nil;
    }
    MMRecordResponse *response = [MMRecordResponse responseFromResponseObjectArray:recordResponseArray
                                                                     initialEntity:initialEntity
                                                                           context:context];
    
    NSArray *records = [response records];
    
    return records;
}

+ (NSArray *)parsingArrayFromResponseObject:(id)responseObject
                   keyPathForResponseObject:(NSString *)keyPathForResponseObject {
    if ([responseObject isKindOfClass:[NSArray class]]) {
        return responseObject;
    }
    
    if (keyPathForResponseObject == nil) {
        keyPathForResponseObject = [self keyPathForResponseObject];
    }
    
    id recordResponseObject = responseObject;
    
    if (keyPathForResponseObject != nil) {
        recordResponseObject = [responseObject valueForKeyPath:keyPathForResponseObject];
    }
    
    if (recordResponseObject == nil || [recordResponseObject isKindOfClass:[NSNull class]]) {
        recordResponseObject = [NSArray array];
    }
    
    if ([recordResponseObject isKindOfClass:[NSArray class]] == NO) {
        recordResponseObject = [NSArray arrayWithObject:recordResponseObject];
    }
    
    return recordResponseObject;
}

+ (NSArray *)objectIDsForRecords:(NSArray *)records
                   onMainContext:(NSManagedObjectContext *)mainContext
           fromBackgroundContext:(NSManagedObjectContext *)backgroundContext {
    [mainContext MMRecord_startObservingWithContext:backgroundContext];
    
    NSError *coreDataError = nil;
    if ([backgroundContext save:&coreDataError] == NO) {
        [[self currentErrorHandler] handleFatalErrorCode:MMRecordErrorCodeCoreDataFetchError
                                             description:@"Unable to save background context. Import operation unsuccessful."];
    }
    
    [mainContext MMRecord_stopObservingWithContext:backgroundContext];
    
    NSMutableArray *objectIDs = [NSMutableArray array];
    
    for (MMRecord *record in records) {
        [objectIDs addObject:[record objectID]];
    }
    
    return objectIDs;
}

+ (NSArray *)mainContextRecordsFromObjectIDs:(NSArray *)objectIDs
                                 mainContext:(NSManagedObjectContext *)mainContext {
    NSMutableArray *mainContextRecords = [NSMutableArray array];
    
    for (NSManagedObjectID *objectID in objectIDs) {
        [mainContextRecords addObject:[mainContext objectWithID:objectID]];
    }
    
    return mainContextRecords;
}


#pragma mark - Orphan Deletion Methods

+ (void)conditionallyDeleteRecordsOphanedByResponse:(id)responseObject
                                   populatedRecords:(NSArray *)populatedRecords
                                            options:(MMRecordOptions *)options
                                              state:(MMRecordRequestState *)state
                                            context:(NSManagedObjectContext *)context {
    if (options.deleteOrphanedRecordBlock != nil) {
        NSArray *orphanedRecords = [self orphanedRecordsFromContext:context populatedRecords:populatedRecords];
        
        BOOL stop = NO;
        
        for (MMRecord *orphanedRecord in orphanedRecords) {
            BOOL deleteOrphan = options.deleteOrphanedRecordBlock(orphanedRecord, populatedRecords, responseObject, &stop);
            
            if (deleteOrphan) {
                [context deleteObject:orphanedRecord];
            }
            
            if (stop) {
                break;
            }
        }
    }
}

+ (NSArray *)orphanedRecordsFromContext:(NSManagedObjectContext *)context
                       populatedRecords:(NSArray *)populatedRecords  {
    NSMutableArray *populatedObjectIDs = [NSMutableArray array];
    NSMutableSet *orphanedObjectIDs = [NSMutableSet set];
    
    for (MMRecord *record in populatedRecords) {
        [populatedObjectIDs addObject:[record objectID]];
    }
    
    NSString *entityName = [[context MMRecord_entityForClass:self] name];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    fetchRequest.fetchBatchSize = 20;
    
    NSArray *allRecords = [context executeFetchRequest:fetchRequest error:NULL];
    
    for (MMRecord *record in allRecords) {
        [orphanedObjectIDs addObject:[record objectID]];
    }
    
    for (NSManagedObjectID *objectID in populatedObjectIDs) {
        [orphanedObjectIDs removeObject:objectID];
    }
    
    NSMutableArray *orphanedRecords = [NSMutableArray array];
    
    for (NSManagedObjectID *orphanedObjectID in orphanedObjectIDs) {
        [orphanedRecords addObject:[context objectWithID:orphanedObjectID]];
    }
    
    return orphanedRecords;
}


#pragma mark - Primary Key Methods

- (id)primaryKeyValue {
    NSDictionary *userInfo = [[self entity] userInfo];
    NSString *primaryAttributeKey = [userInfo valueForKey:MMRecordEntityPrimaryAttributeKey];
    
    if (primaryAttributeKey == nil) {
        return nil;
    }
    
    return [self valueForKey:primaryAttributeKey];
}


#pragma mark - Error Helpers

+ (NSError*)errorWithMMRecordCode:(MMRecordErrorCode)errorCode description:(NSString*)description {
    return [NSError errorWithMMRecordCode:errorCode description:description];
}

@end


#pragma mark - MMServerPageManager Addition

@implementation MMRecord (MMServerPageManager)

+ (void)startPagedRequestWithURN:(NSString *)URN
                            data:(NSDictionary *)data
                         context:(NSManagedObjectContext *)context
                          domain:(id)domain
                     resultBlock:(void (^)(NSArray *records, id pageManager, BOOL *requestNextPage))resultBlock
                    failureBlock:(void (^)(NSError *error))failureBlock {
    MMRecordOptions *options = [self currentOptions];
    
    [self
     startRequestWithURN:URN
     data:data
     context:context
     domain:domain
     customResponseBlock:^id(id JSON) {
         MMServerPageManager *pageManager = [[[options pageManagerClass] alloc] initWithResponseObject:JSON
                                                                                            requestURN:URN
                                                                                           requestData:data
                                                                                           recordClass:self];
         
         return pageManager;
     }
     resultBlock:^(NSArray *records, MMServerPageManager *pageManager) {
         if(resultBlock){
             BOOL requestNextPage = NO;
             
             if (resultBlock != nil) {
                 resultBlock(records,pageManager,&requestNextPage);
             }
             
             if (requestNextPage) {
                 [pageManager startNextPageRequestWithContext:context
                                                       domain:domain
                                                  resultBlock:resultBlock
                                                 failureBlock:failureBlock];
             }
         }
     }
     failureBlock:failureBlock];
}

@end


#pragma mark - MMRecordFetchRequest Addition

@implementation MMRecord (MMRecordFetchRequests)

+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)data
                    context:(NSManagedObjectContext*)context
                     domain:(id)domain
               fetchRequest:(NSFetchRequest *)fetchRequest
        customResponseBlock:(id (^)(id JSON))customResponseBlock
                resultBlock:(void(^)(NSArray *records, id customResponseObject, BOOL requestComplete))resultBlock
               failureBlock:(void(^)(NSError *error))failureBlock {
    MMRecordOptions *options = [self currentOptions];
    
    [context performBlock:^{
        NSArray *results = [context executeFetchRequest:fetchRequest error:NULL];
        
        if (resultBlock != nil) {
            dispatch_async(options.callbackQueue, ^{
                resultBlock(results, nil, NO);
            });
        }
        
        [self
         startRequestWithURN:URN
         data:data
         context:context
         domain:domain
         customResponseBlock:customResponseBlock
         resultBlock:^(NSArray *records, id customResponseObject) {
             if (resultBlock) {
                 dispatch_async(options.callbackQueue, ^{
                     resultBlock(records, customResponseObject, YES);
                 });
             }
         }
         failureBlock:failureBlock];
    }];
}

@end


#pragma mark - Managed Object Context Additions

@implementation NSManagedObjectContext (MMRecord)

#pragma mark - Context Merging

- (void)MMRecord_startObservingWithContext:(NSManagedObjectContext *)otherContext {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MMRecord_MergeContextSaved:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:otherContext];
}

- (void)MMRecord_stopObservingWithContext:(NSManagedObjectContext *)otherContext {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:otherContext];
}

- (void)MMRecord_MergeContextSaved:(NSNotification *)notification {
	[self performSelectorOnMainThread:@selector(MMRecord_MergeChangesFromNotification:) withObject:notification waitUntilDone:YES];
}

- (void)MMRecord_MergeChangesFromNotification:(NSNotification *)note {
	[self mergeChangesFromContextDidSaveNotification:note];
}


#pragma mark - Entity Class

- (NSEntityDescription *)MMRecord_entityForClass:(Class)managedObjectClass {
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    NSManagedObjectModel *model = coordinator.managedObjectModel;
    NSArray *entities = model.entities;
    
    if (entities == nil) {
        return nil;
    }
    
    NSString *name = NSStringFromClass(managedObjectClass);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.managedObjectClassName == %@", name];
    
    for (id obj in entities) {
        if ([predicate evaluateWithObject:obj]) {
            return obj;
        }
    }
    
    return nil;
}

@end


#pragma mark - Custom Error Additions

@implementation NSError (MMRecord)

+ (NSString *)descriptionForMCErrorCode:(MMRecordErrorCode)errorCode {
    NSString *result = nil;
    switch (errorCode) {
        case MMRecordErrorCodeUndefinedServer:
            result = NSLocalizedString(@"Undefined Server. A server class must be registered with MMRecord in order to start requests.",
                                       @"A server class must be registered with MMRecord in order to start requests.");
            break;
        case MMRecordErrorCodeUndefinedPageManager:
            result = NSLocalizedString(@"Missing Page Manager. A page manager class must be defined on your MMServer subclass in order to use paging.",
                                       @"A page manager class must be defined on your MMServer subclass in order to use paging.");
            break;
        case MMRecordErrorCodeInvalidEntityDescription:
            result = NSLocalizedString(@"Invalid Entity Description. This could be because this record class is not used in your managed object model, or because your persistent store coordinator or managed object model are not defined properly. An entity description is required for creating records.",
                                       @"This could be because this record class is not used in your managed object model, or because your persistent store coordinator or managed object model are not defined properly. An entity description is required for creating records.");
            break;
        default:
        case MMRecordErrorCodeUnknown:
            result = NSLocalizedString(@"Unknown Error",
                                       @"Unknown Error Description");
            break;
    }
    
    return result;
}

- (instancetype)initWithMMRecordCode:(MMRecordErrorCode)errorCode description:(NSString *)description {
    NSString *errorDescription = [[NSError descriptionForMCErrorCode:errorCode] stringByAppendingFormat:@" %@", description];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              errorDescription,NSLocalizedDescriptionKey,
                              nil];
    
    self = [self initWithDomain:MMRecordErrorDomain
                           code:errorCode
                       userInfo:userInfo];
    
    return self;
}

+ (NSError *)errorWithMMRecordCode:(MMRecordErrorCode)errorCode description:(NSString *)description {
    return [[NSError alloc] initWithMMRecordCode:errorCode description:description];
}

@end



#pragma mark - Custom Error Handler Class

@implementation MMRecordErrorHandler

- (BOOL)receivedFatalError {
    return receivedFatalError_;
}

- (NSError *)fatalError {
    if (receivedFatalError_) {
        return [MMRecord errorWithMMRecordCode:mostRecentFatalErrorCode_ description:mostRecentFatalErrorDescription_];
    }
    
    return nil;
}

- (void)handleErrorCode:(MMRecordErrorCode)errorCode description:(NSString *)description {
    [self logMessageForCode:errorCode description:description isFatal:NO];
}

- (void)handleFatalErrorCode:(MMRecordErrorCode)errorCode description:(NSString *)description {
    mostRecentFatalErrorCode_ = errorCode;
    mostRecentFatalErrorDescription_ = description;
    receivedFatalError_ = YES;
    
    [self logMessageForCode:errorCode description:description isFatal:YES];
}

- (void)logMessageForCode:(MMRecordErrorCode)errorCode description:(NSString *)description isFatal:(BOOL)isFatal {
#if MMRecordLumberjack
    NSString *errorCodeDescription = [NSError descriptionForMCErrorCode:errorCode];
    
    if (isFatal) {
        MMRLogError(@"%@. %@", errorCodeDescription, description);
    }
    else{
        MMRLogWarn(@"%@. %@", errorCodeDescription, description);
    }
#else
    BOOL shouldLogMessage = NO;
    
    switch ([MMRecord loggingLevel]) {
        case MMRecordLoggingLevelAll:
        case MMRecordLoggingLevelDebug:
        case MMRecordLoggingLevelInfo:
            shouldLogMessage = shouldLogMessage || errorCode == MMRecordErrorCodeMissingRecordPrimaryKey;
            shouldLogMessage = shouldLogMessage || errorCode == MMRecordErrorCodeUndefinedServer;
            shouldLogMessage = shouldLogMessage || errorCode == MMRecordErrorCodeUndefinedPageManager;
            shouldLogMessage = shouldLogMessage || errorCode == MMRecordErrorCodeInvalidEntityDescription;
            break;
        case MMRecordLoggingLevelNone:
            shouldLogMessage = NO;
        default:
            break;
    }
    
    if (shouldLogMessage) {
        NSString *logPrefix = @"--[MMRecord WARNING]-- %@. %@";
        
        if (isFatal) {
            logPrefix = @"--[MMRecord ERROR]-- %@. %@";
        }
        
        NSLog(logPrefix, [NSError descriptionForMCErrorCode:errorCode], description);
    }
#endif
}

@end


#pragma mark - Request State Encapsulation

@implementation MMRecordRequestState

+ (MMRecordRequestState *)requestStateForURN:(NSString *)URN
                                        data:(NSDictionary *)data
                                     context:(NSManagedObjectContext *)context
                                      domain:(id)domain
                         customResponseBlock:(id (^)(id JSON))customResponseBlock
                                 resultBlock:(void(^)(NSArray *records, id customResponseObject))resultBlock
                                failureBlock:(void(^)(NSError *error))failureBlock {
    MMRecordRequestState *state = [MMRecordRequestState new];
    state.URN = URN;
    state.data = data;
    state.context = context;
    state.domain = domain;
    state.customResponseBlock = customResponseBlock;
    state.resultBlock = resultBlock;
    state.failureBlock = failureBlock;
    
    return state;
}

@end


#pragma mark - Options

@implementation MMRecordOptions
@end

#undef MMRLogInfo
#undef MMRLogWarn
#undef MMRLogError
#undef MMRLogVerbose
