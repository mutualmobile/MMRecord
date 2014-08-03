//
// MMRecordRequest.m
//
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
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

#import "MMRecordRequest.h"

#import "MMRecord.h"
#import "MMRecordCache.h"
#import "MMRecordDebugger.h"
#import "MMRecordResponse.h"
#import "MMServer.h"

// Tweaks
#ifdef FBMMRecordTweakModelDefine
#import "FBMMRecordTweakModel.h"
#endif

static dispatch_group_t _mmrecord_request_group = nil;
static dispatch_semaphore_t _mmrecord_request_semaphore = nil;
static BOOL _mmrecord_batch_requests = NO;

// This category adds functionality to the CoreData framework's `NSManagedObjectContext` class.
// It provides support for convenience functions for context merging as well as obtaining an
// `NSEntityDescription` object for a given class name.
@interface NSManagedObjectContext (MMRecord)

- (void)MMRecord_startObservingWithContext:(NSManagedObjectContext*)context;
- (void)MMRecord_stopObservingWithContext:(NSManagedObjectContext*)context;
- (NSEntityDescription*)MMRecord_entityForClass:(Class)managedObjectClass;

@end

@implementation MMRecordRequest


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
            _mmrecord_request_group = nil;
        }
        
        if (dispatchGroup) {
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

+ (void)configureRequestState:(MMRecordRequestState *)state {
    state.batched = [self batchRequests];
    state.dispatchGroup = [self dispatchGroup];
    state.parsingQueue = [self parsingQueue];
    
    if (state.options.isRecordLevelCachingEnabled) {
        state.cacheKey = [self keyForCachingRequestWithState:state];
        state.keyPathForMetaData = [state.options keyPathForMetaData];
    }
}



#pragma mark - Performing Requests

+ (void)startRequestWithRequestState:(MMRecordRequestState *)state {
    [self configureRequestState:state];
    [self preflightRequestWithRequestState:state];
}

+ (void)startBatchedRequestsInBatchExecutionBlock:(void(^)())batchExecutionBlock
                              withCompletionBlock:(void(^)())completionBlock {
    [self setBatchDispatchGroup:YES];
    dispatch_group_t dispatchGroup = [self dispatchGroup];
    batchExecutionBlock();
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), completionBlock);
    [self setBatchDispatchGroup:NO];
}

+ (void)preflightRequestWithRequestState:(MMRecordRequestState *)state {
    MMRecordOptions *options = state.options;
    
    BOOL isValid = [self validateSetUpForStartRequestState:state];
    
    if (options.debugger.encounteredFailureCondition || isValid == NO) {
        [self failRequestWithRequestState:state];
    } else {
        BOOL cached = [self shortCircuitRequestByReturningCachedResultsForState:state];
        
        if (cached == NO) {
            [self performRequestWithRequestState:state];
        }
    }
}

// You should really do your preflight check before calling this method.
+ (void)performRequestWithRequestState:(MMRecordRequestState *)state {
    if ([state isBatched]) {
        dispatch_group_enter(state.dispatchGroup);
    }
    
    [state.serverClass
     startRequestWithURN:state.URN
     data:state.data
     paged:NO
     domain:state.domain
     batched:state.isBatched
     dispatchGroup:state.dispatchGroup
     responseBlock:^(id responseObject) {
         dispatch_queue_t parsingQueue = state.parsingQueue;
         dispatch_group_async(state.dispatchGroup, parsingQueue, ^{
             [self continueRequestByHandlingResponse:responseObject
                                               state:state];
             
             if ([state isBatched]) {
                 dispatch_group_leave(state.dispatchGroup);
             }
         });
     } failureBlock:^(NSError *error) {
         if (state.failureBlock != nil) {
             state.failureBlock(error);
         }
         
         if ([state isBatched]) {
             dispatch_group_leave(state.dispatchGroup);
         }
     }];
}


#pragma mark - Finalizing Requests

+ (NSArray *)recordsForRequestState:(MMRecordRequestState *)state {
    state.backgroundContext = [[NSManagedObjectContext alloc] init];
    
    MMRecordResponse *response = [self responseForState:state context:state.backgroundContext];
    
    [self configureBackgroundContext:state.backgroundContext
                         withOptions:state.options
                         mainContext:state.context
                mainStoreCoordinator:state.coordinator];
    
    state.records = [response records];
    
    state.objectIDs = [self objectIDsForRecords:state.records
                                  onMainContext:state.context
                          fromBackgroundContext:state.backgroundContext
                                          state:state];
    
    NSArray *mainContextRecords = [self mainContextRecordsFromObjectIDs:state.objectIDs mainContext:state.context];

    return mainContextRecords;
}

+ (void)continueRequestByHandlingResponse:(id)responseObject
                                    state:(MMRecordRequestState *)state {
    state.responseObject = responseObject;
    
    [self handleResponseForRequestState:state withCompletionBlock:nil];
}

+ (void)handleResponseForRequestState:(MMRecordRequestState *)state
                  withCompletionBlock:(void(^)(NSArray *records))completionBlock {
    state.backgroundContext = [[NSManagedObjectContext alloc] init];
    
    [self configureBackgroundContext:state.backgroundContext
                         withOptions:state.options
                         mainContext:state.context
                mainStoreCoordinator:state.coordinator];
    
    if (completionBlock != nil) {
        typedef void (^OriginalResultBlock)(NSArray *records, id customResponseObject);
        OriginalResultBlock originalResultBlock = state.resultBlock;
        
        state.resultBlock = ^(NSArray *records, id customResponseObject) {
            if (completionBlock) {
                completionBlock(records);
            }
            
            if (originalResultBlock) {
                originalResultBlock(records, customResponseObject);
            }
        };
    }
    
    MMRecordResponse *response = [self responseForState:state context:state.backgroundContext];
    
    [response recordsWithCompletionBlock:^(NSArray *records) {
        [self completeRequestWithState:state records:records];
    }];
}

+ (void)completeRequestWithState:(MMRecordRequestState *)state records:(NSArray *)records {
    state.records = records;
    
    [self conditionallyDeleteRecordsOphanedByResponse:state.responseObject
                                     populatedRecords:state.records
                                                state:state
                                              context:state.backgroundContext];
    
    [self performCachingForRecords:state.records
                fromResponseObject:state.responseObject
                      requestState:state
                       withOptions:state.options];
    
    state.objectIDs = [self objectIDsForRecords:state.records
                                  onMainContext:state.context
                          fromBackgroundContext:state.backgroundContext
                                          state:state];
    
    if ([state.options.debugger encounteredFailureCondition] == NO) {
        [self passRequestWithRequestState:state];
    } else {
        [self failRequestWithRequestState:state];
    }
    
    [self setDispatchGroup:nil];
}

+ (void)passRequestWithRequestState:(MMRecordRequestState *)state {
    [self invokeResultBlockWithRequestState:state];
}

+ (void)failRequestWithRequestState:(MMRecordRequestState *)state {
    MMRecordOptions *options = state.options;

    if ([state isBatched]) {
        dispatch_group_enter(state.dispatchGroup);
    }
    
    dispatch_group_async(state.dispatchGroup, options.callbackQueue, ^{
        state.failureBlock([options.debugger primaryError]);
        
        if ([state isBatched]) {
            dispatch_group_leave(state.dispatchGroup);
        }
    });
}

+ (void)invokeResultBlockWithRequestState:(MMRecordRequestState *)state {
    MMRecordOptions *options = state.options;

    if ([state isBatched]) {
        dispatch_group_enter(state.dispatchGroup);
    }
    
    dispatch_group_async(state.dispatchGroup, options.callbackQueue, ^{
        id customResponseObject = (state.customResponseBlock) ? state.customResponseBlock(state.responseObject) : nil;
        
        NSArray *mainContextRecords = [self mainContextRecordsFromObjectIDs:state.objectIDs mainContext:state.context];
        
        if (state.resultBlock != nil) {
            state.resultBlock(mainContextRecords, customResponseObject);
        }
        
        if ([state isBatched]) {
            dispatch_group_leave(state.dispatchGroup);
        }
    });
}


#pragma mark - Caching

+ (BOOL)shortCircuitRequestByReturningCachedResultsForState:(MMRecordRequestState *)state {
    MMRecordOptions *options = state.options;

    if (options.isRecordLevelCachingEnabled) {
        BOOL cached = [MMRecordCache hasResultsForKey:state.cacheKey];
        
        if (cached) {
            NSURLRequest *request = [self cachingRequestWithState:state];
            
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
                     
                     [self passRequestWithRequestState:state];
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

+ (NSURLRequest *)cachingRequestWithState:(MMRecordRequestState *)state {
    return [state.serverClass requestWithURN:state.URN data:state.data];
}

+ (NSString *)keyForCachingRequestWithState:(MMRecordRequestState *)state {
    NSURLRequest *request = [self cachingRequestWithState:state];
    
    return request.URL.absoluteString;
}


#pragma mark - Validation

+ (BOOL)validateSetUpForStartRequestState:(MMRecordRequestState *)state {
    // Make sure the server is set properly.
    if (state.serverClass == nil) {
        MMRecordOptions *options = state.options;
        MMRecordDebugger *debugger = options.debugger;
        
        NSMutableArray *keys = [NSMutableArray array];
        NSMutableArray *values = [NSMutableArray array];
        
        [keys addObject:MMRecordDebuggerParameterRecordClassName];
        [values addObject:self];
        
        if (state.serverClass) {
            [keys addObject:MMRecordDebuggerParameterServerClassName];
            [values addObject:state.serverClass];
        }
        
        NSDictionary *parameters = [debugger parametersWithKeys:keys
                                                         values:values];
        [debugger handleErrorCode:MMRecordErrorCodeUndefinedServer withParameters:parameters];
        
        return NO;
    }
    
    return YES;
}


#pragma mark - Parsing Helper Methods

+ (MMRecordResponse *)responseForState:(MMRecordRequestState *)state
                               context:(NSManagedObjectContext *)context {
    MMRecordOptions *options = state.options;
    id responseObject = state.responseObject;
    
    if (responseObject == nil) {
        MMRecordDebugger *debugger = options.debugger;
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        [parameters setObject:self forKey:MMRecordDebuggerParameterRecordClassName];
        
        if (responseObject) {
            [parameters setObject:responseObject forKey:MMRecordDebuggerParameterResponseObject];
        }
        
        [debugger handleErrorCode:MMRecordErrorCodeInvalidResponseFormat withParameters:parameters];
        
        return nil;
    }
    
    NSEntityDescription *initialEntity = [context MMRecord_entityForClass:state.initialEntityClass];
    
    options.debugger.initialEntity = initialEntity;
    options.debugger.responseObject = responseObject;
    
    NSString *keyPathForResponseObject = options.keyPathForResponseObject;
    
#ifdef FBMMRecordTweakModelDefine
    keyPathForResponseObject = [self tweakedKeyPathForResponseObjectWithInitialEntity:initialEntity
                                                                      existingKeyPath:keyPathForResponseObject];
#endif
    
    NSArray *recordResponseArray = [self parsingArrayFromResponseObject:responseObject
                                               keyPathForResponseObject:keyPathForResponseObject state:state];
    
    if (recordResponseArray.count == 0) {
        MMRecordDebugger *debugger = options.debugger;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        [parameters setObject:self forKey:MMRecordDebuggerParameterRecordClassName];
        
        if (responseObject) {
            [parameters setObject:responseObject forKey:MMRecordDebuggerParameterResponseObject];
        }
        
        [debugger handleErrorCode:MMRecordErrorCodeEmptyResultSet withParameters:parameters];
        return nil;
    }
    
    if ([NSClassFromString([initialEntity managedObjectClassName]) isSubclassOfClass:[MMRecord class]] == NO) {
        MMRecordDebugger *debugger = options.debugger;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        [parameters setObject:self forKey:MMRecordDebuggerParameterRecordClassName];
        
        if (initialEntity) {
            [parameters setObject:initialEntity forKey:MMRecordDebuggerParameterEntityDescription];
        }
        
        [debugger handleErrorCode:MMRecordErrorCodeInvalidEntityDescription withParameters:parameters];
        return nil;
    }
    
    MMRecordResponse *response = [MMRecordResponse responseFromResponseObjectArray:recordResponseArray
                                                                     initialEntity:initialEntity
                                                                           context:context
                                                                           options:options];
    
    return response;
}

+ (NSArray *)parsingArrayFromResponseObject:(id)responseObject
                   keyPathForResponseObject:(NSString *)keyPathForResponseObject
                                      state:(MMRecordRequestState *)state {
    if ([responseObject isKindOfClass:[NSArray class]]) {
        return responseObject;
    }
    
    if (keyPathForResponseObject == nil) {
        if ([state.initialEntityClass isSubclassOfClass:[MMRecord class]]) {
            keyPathForResponseObject = [state.initialEntityClass keyPathForResponseObject];
        }
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
           fromBackgroundContext:(NSManagedObjectContext *)backgroundContext
                           state:(MMRecordRequestState *)state {
    [mainContext MMRecord_startObservingWithContext:backgroundContext];
    
    NSError *coreDataError = nil;
    
    if ([backgroundContext save:&coreDataError] == NO) {
        NSString *coreDataErrorString = [NSString stringWithFormat:@"Core Data error occurred with code: %ld, description: %@",
                                         (long)coreDataError.code,
                                         coreDataError.localizedDescription];
        NSString *errorDescription = [NSString stringWithFormat:@"Unable to save background context while populating records. MMRecord import operation unsuccessful. %@",
                                      coreDataErrorString];
        
        MMRecordOptions *options = state.options;
        MMRecordDebugger *debugger = options.debugger;
        NSDictionary *parameters = [debugger parametersWithKeys:@[MMRecordDebuggerParameterErrorDescription] values:@[errorDescription]];
        
        [debugger handleErrorCode:MMRecordErrorCodeCoreDataSaveError withParameters:parameters];
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
                                              state:(MMRecordRequestState *)state
                                            context:(NSManagedObjectContext *)context {
    MMRecordOptions *options = state.options;
    
    if (options.deleteOrphanedRecordBlock != nil) {
        NSArray *orphanedRecords = [self orphanedRecordsFromContext:context
                                                   populatedRecords:populatedRecords
                                                              state:state];
        
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
                       populatedRecords:(NSArray *)populatedRecords
                                  state:(MMRecordRequestState *)state {
    NSMutableArray *populatedObjectIDs = [NSMutableArray array];
    NSMutableSet *orphanedObjectIDs = [NSMutableSet set];
    
    for (MMRecord *record in populatedRecords) {
        [populatedObjectIDs addObject:[record objectID]];
    }
    
    NSString *entityName = [[context MMRecord_entityForClass:state.initialEntityClass] name];
    
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


#pragma mark - Tweaks Support

+ (NSString *)tweakedKeyPathForResponseObjectWithInitialEntity:(NSEntityDescription *)initialEntity
                                               existingKeyPath:(NSString *)existingKeyPath {
    NSString *keyPath = existingKeyPath;
    NSString *tweakedValue = nil;
    
#ifdef FBMMRecordTweakModelDefine
    tweakedValue = [FBMMRecordTweakModel tweakedKeyPathForEntity:initialEntity];
#endif
    
    if (tweakedValue && [tweakedValue isKindOfClass:[NSString class]]) {
        keyPath = tweakedValue;
    }
    
    return keyPath;
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
    
    for (NSEntityDescription *entityDescription in entities) {
        Class entityManagedObjectClass = NSClassFromString([entityDescription managedObjectClassName]);
        
        if (entityManagedObjectClass == managedObjectClass) {
            return entityDescription;
        }
    }
    
    return nil;
}

@end


#pragma mark - Request State Encapsulation

@implementation MMRecordRequestState

@end

