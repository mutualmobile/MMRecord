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
#import "MMRecordRepresentation.h"
#import "MMRecordRequest.h"
#import "MMServer.h"

static MMRecordLoggingLevel MM_mmrecord_logging_level = 0;
static MMRecordOptions* MM_recordOptions;
static NSMutableDictionary* MM_registeredServerClasses;
static BOOL MM_mmrecord_batch_requests = NO;

NSString * const MMRecordEntityPrimaryAttributeKey = @"MMRecordEntityPrimaryAttributeKey";
NSString * const MMRecordAttributeAlternateNameKey = @"MMRecordAttributeAlternateNameKey";

// This extension to `MMRecord` provides convenience methods for obtaining and restoring options.
@interface MMRecord (MMRecordOptionsInternal)

+ (MMRecordOptions *)currentOptions;
+ (MMRecordOptions *)defaultOptions;
+ (void)restoreDefaultOptions;

@end

@implementation MMRecord

#pragma mark - Required Subclass Methods

+ (NSString*)keyPathForResponseObject {
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
    options.debugger = [[MMRecordDebugger alloc] init];
    options.debugger.loggingLevel = [self loggingLevel];
    options.deleteOrphanedRecordBlock = nil;
    options.entityPrimaryKeyInjectionBlock = nil;
    options.recordPrePopulationBlock = nil;
    return options;
}

+ (void)restoreDefaultOptions {
    if (MM_mmrecord_batch_requests == NO) {
        MM_recordOptions = nil;
    }
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
    MM_mmrecord_logging_level = loggingLevel;
}

+ (MMRecordLoggingLevel)loggingLevel {
    return MM_mmrecord_logging_level;
}


#pragma mark - Request Methods



+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)data
                    context:(NSManagedObjectContext *)context
                     domain:(id)domain
        customResponseBlock:(id (^)(id JSON))customResponseBlock
                resultBlock:(void(^)(NSArray *records, id customResponseObject))resultBlock
               failureBlock:(void(^)(NSError *error))failureBlock {
    MMRecordRequestState *state = [[MMRecordRequestState alloc] init];
    state.options = [self currentOptions];
    state.coordinator = context.persistentStoreCoordinator;
    state.domain = domain;
    state.context = context;
    state.initialEntityClass = self;
    state.data = data;
    state.URN = URN;
    state.serverClass = [self server];
    state.customResponseBlock = customResponseBlock;
    state.resultBlock = resultBlock;
    state.failureBlock = failureBlock;
    
    [MMRecordRequest startRequestWithRequestState:state];
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
    MM_mmrecord_batch_requests = YES;
    [MMRecordRequest startBatchedRequestsInBatchExecutionBlock:batchExecutionBlock
                                           withCompletionBlock:completionBlock];
    MM_mmrecord_batch_requests = NO;
    [self restoreDefaultOptions];
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


#pragma mark - Options

@implementation MMRecordOptions
@end

