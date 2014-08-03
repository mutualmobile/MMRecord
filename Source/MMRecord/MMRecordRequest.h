//
// MMRecordRequest.h
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

#import <Foundation/Foundation.h>

@class MMRecordOptions;
@class MMRecordRequestState;

@interface MMRecordRequest : NSObject

+ (void)startRequestWithRequestState:(MMRecordRequestState *)state;

+ (void)startBatchedRequestsInBatchExecutionBlock:(void(^)())batchExecutionBlock
                              withCompletionBlock:(void(^)())completionBlock;

/**
 This method will initiate the MMRecordResponse parsing and population process to create and update
 instances of MMRecord objects for the given response. Normally this method will be called once the
 startRequestWithRequestState completes, and will be passed that request's state, but you can call
 it yourself with your own state. This method does expect that the initialEntityClass, context, and
 responseObject parameters are filled in as part of the request state.
 */
+ (void)handleResponseForRequestState:(MMRecordRequestState *)state
                  withCompletionBlock:(void(^)(NSArray *records))completionBlock;

+ (NSArray *)recordsForRequestState:(MMRecordRequestState *)state;

@end

@interface MMRecordRequestState : NSObject

@property (nonatomic, strong) MMRecordOptions *options;

@property (nonatomic, getter = isBatched) BOOL batched;
@property (nonatomic) dispatch_queue_t parsingQueue;
@property (nonatomic) dispatch_group_t dispatchGroup;

@property (nonatomic, strong) Class initialEntityClass;
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

@property (nonatomic, strong) Class serverClass;
@property (nonatomic, strong) id domain;
@property (nonatomic, copy) id (^customResponseBlock)(id JSON);
@property (nonatomic, copy) void (^resultBlock)(NSArray *records, id customResponseObject);
@property (nonatomic, copy) void (^failureBlock)(NSError* error);

@end