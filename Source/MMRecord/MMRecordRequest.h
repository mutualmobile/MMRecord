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

/**
 This class encapsulates the process of making a request for MMRecord through an associated MMServer
 and handling the logic for converting that response into populated instances of MMRecords. This
 class provides both a synchronous and asynchronous interface to the MMRecord response handling
 process, as well as singular and batched interfaces to the request process.
 
 This class is meant to be used from requests started from subclasses of MMRecord, however, it can
 also be used independently to provide your own access to the MMRecord parsing system.
 
 To use this class yourself, you will need to create and configure MMRecordRequestState objects.
 These include bits of data about the request and describe how the request will be handled.
 Documentation on the MMRecordRequestState class is below.
 */
@interface MMRecordRequest : NSObject

/**
 Asynchronous method for starting a request with given state. This method will start the request
 using the MMServer included with the state, and will call the respective result, customResult, and 
 failure blocks when appropriate.
 
 This class also expects important meta data, such as a URN and data parameters that a server may
 need, and a properly configured options object and Core Data properties to be given to it via the
 state parameter.
 
 @param state Important information needed to perform this request.
 */
+ (void)startRequestWithRequestState:(MMRecordRequestState *)state;

/**
 Batched entry point to the start request method. This method will group all requests started in the
 batch execution block together. Once those request are complete, the associated completionBlock
 will be called.
 
 @param batchExecutionBlock A block in which all batched requests should be started.  This block
 will be executed immediately and all requests started inside of it will be associated with the
 same dispatch group and started with the batched property set to YES.
 @param completionBlock A block to be executed when the dispatch group notify occurs signaling that
 the group has finished executing.
 */
 + (void)startBatchedRequestsInBatchExecutionBlock:(void(^)())batchExecutionBlock
                              withCompletionBlock:(void(^)())completionBlock;

/**
 This method will initiate the MMRecordResponse parsing and population process to create and update
 instances of MMRecord objects for the given response. Normally this method will be called once the
 startRequestWithRequestState completes, and will be passed that request's state, but you can call
 it yourself with your own state. This method does expect that the initialEntityClass, context, and
 responseObject parameters are filled in as part of the request state.
 
 @discussion This method is asynchronous.
 @param state State used to describe the original request and for handling the response.
 @param completionBlock Optional block that gets executed when the request is finished being
 processed. Defaults to nil.
 */
+ (void)handleResponseForRequestState:(MMRecordRequestState *)state
                  withCompletionBlock:(void(^)(NSArray *records))completionBlock;

/**
 This method will initiate the MMRecordResponse parsing and population process to create and update
 instances of MMRecord objects for the given response.
 
 @discussion This method is synchronous. If you really need to use it, knock yourself out.
 @param state State used to describe the original request and for handling the response.
 @return An array of populated MMRecord instances return on the context supplied by the given state.
 */
+ (NSArray *)synchronousRecordsForRequestState:(MMRecordRequestState *)state;

@end


/**
 This class stores required state for handling requests with MMRecord.
 
 Note: There is no default value for any property. You are responsible for fully 
 configuring the state object for your request.
 */
@interface MMRecordRequestState : NSObject

/**
 MMRecordOptions object with the options set for a given request.
 */
@property (nonatomic, strong) MMRecordOptions *options;

/**
 Batching Properties.
 */
@property (nonatomic, getter = isBatched) BOOL batched;
@property (nonatomic) dispatch_queue_t parsingQueue;
@property (nonatomic) dispatch_group_t dispatchGroup;

/**
 Server Request Properties.
 */
@property (nonatomic, strong) Class serverClass;
@property (nonatomic, copy) NSString *URN;
@property (nonatomic, copy) NSDictionary *data;
@property (nonatomic, strong) id domain;

/**
 Core Data Properties.
 */
@property (nonatomic, strong) Class initialEntityClass;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectContext *backgroundContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;

/**
 Response Properties.
 */
@property (nonatomic, strong) id responseObject;
@property (nonatomic, copy) NSArray *records;
@property (nonatomic, copy) NSArray *objectIDs;

/**
 Caching Properties.
 */
@property (nonatomic, copy) NSString *cacheKey;
@property (nonatomic, copy) NSString *keyPathForMetaData;

/**
 Callback Block Properties.
 */
@property (nonatomic, copy) id (^customResponseBlock)(id JSON);
@property (nonatomic, copy) void (^resultBlock)(NSArray *records, id customResponseObject);
@property (nonatomic, copy) void (^failureBlock)(NSError* error);

@end