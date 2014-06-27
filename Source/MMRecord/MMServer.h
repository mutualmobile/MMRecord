// MMServer.h
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

#import <Foundation/Foundation.h>

#import "MMRecord.h"
#import "MMServerPageManager.h"

/**
 A block that may be called after handling the session time out, if a new session is started 
 successfully.  This block should re-call the request that was started prior to the session timing 
 out.
 */
typedef void (^MMServerSessionTimeoutRestartLastRequestBlock)();

/**
 A block that should be called when the session times out. 
 */
typedef void (^MMServerSessionTimeoutBlock)(MMServerSessionTimeoutRestartLastRequestBlock restartBlock);

/**
 `MMServer` provides the primary interface for making a request to a server.  MMServer is designed 
 to be subclassed.  One of the great things about MMServer is that it removes the depency of a 
 project on any particular networking framework.  You can build all of your networking code around 
 MMRecord and MMServer and freely interchange request frameworks under the hood as desired.  
 The intent here is to also allow the ability to use a local server or a live server interchangably 
 without needing to change any controller-level code.
 
 ## Subclassing Notes
 
 This class is designed and required to be subclassed.  Subclasses must implement the cancelRequests 
 and startRequestWithURN methods.  The intent is that you will subclass this class for every server 
 your app wishes to interact with, either local or live.  If you wish to support pagination you 
 should also implement pageManagerClass.  The session timeout methods should not need to be 
 implemented by subclasses.
 
 ## Methods to Override
 
 To allow your server to support pagination you should override pageManagerClass and return the 
 class of your MMServerPageManager subclass.
 */

@interface MMServer : NSObject

///--------------------------------------------
/// @name Starting and Stopping Server Requests
///--------------------------------------------

/**
 Cancels any requests in progress.  This method must be implemented by the subclass of MMServer.
 
 @param domain A domain value used to know which requests to cancel.  It is left to the subclass to 
 decide how to interpret this value.
 */
+ (void)cancelRequestsWithDomain:(id)domain;

/**
 Starts a request.  This method must be implemented by the subclass of MMServer.
 
 @param URN The base URN for the request endpoint.
 @param data A dictionary containing request parameters.
 @param paged A boolean value indicating whether or not the request should be paged.  The paged 
 request should request the first page by default.  You should only set a page size parameter if 
 this value is YES.
 @param domain A domain value used for request cancellation.  It is left to the subclass to decide 
 how to use this value.
 @param batched A boolean value indicating whether or not a request is intended to be batched.  
 Depending on your networking implementation this may or may not matter to you.  The default 
 implementation of MMRecord's batching support will use dispatch groups to fire a completion block 
 after all of the responseBlocks (which by default use this group) finish.  This property may be 
 useful to you in some cases, and if so, please contact the maintainers to tell them what this 
 use-case is :)  It is easily possible that this parameter will be deprecated in the future, 
 so plan accordingly.
 @param dispatchGroup A dispatch_group variable to be used for grouping batch requests.  
 All dispatch_async blocks in MMRecord are issued with a dispatch_group.  This property is 
 intended as a safe-guard should you need to dispatch any other blocks asynchronously.  In order to 
 gaurantee that batching will still work, you should use this dispatch group if you ever find 
 yourself in that situation.  Using this is not required in order for batching to work.
 @param responseBlock A block object to be executed when the request finishes successfully.  
 The block is called with the response object as a parameter.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully.  
 The block contains an error object that describes a request failure or a record parsing failure.
 */
+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)data
                      paged:(BOOL)paged
                     domain:(id)domain
                    batched:(BOOL)batched
              dispatchGroup:(dispatch_group_t)dispatchGroup
              responseBlock:(void(^)(id responseObject))responseBlock
               failureBlock:(void(^)(NSError *error))failureBlock;

///-----------------------------------------------
/// @name Handling API Request Response Pagination
///-----------------------------------------------

/** 
 Returns a subclass of MMServerPageManager configured to support your server's implementation of 
 pagination.  You should override this method if you want your server to support pagination.
 
 @return The page manager class.
 */
+ (Class)pageManagerClass;

///-------------------------------------------------
/// @name Handling a Session Timeout Request Failure
///-------------------------------------------------

/**
 Registers the session timeout block which will be called in the event of a session timeout.
 
 @param block A block of type MMServerSessionTimeoutBlock.
 */
+ (void)registerSessionTimeoutBlock:(MMServerSessionTimeoutBlock)block;

/**
 Accessor for the session timeout block.
 
 @return The registered session timeout block.
 */
+ (MMServerSessionTimeoutBlock)sessionTimeoutBlock;

///-------------------------------------------
/// @name Support for URL-based Record Caching
///-------------------------------------------

/**
 Returns an NSURLRequest properly configured as it would be for a call to startRequestWithURN:.  
 This method is required for an installation of MMRecord/MMServer that wishes to support caching.
 
 @param URN The base URN for the request endpoint.
 @param data A dictionary containing request parameters.
 @return A configured NSURLRequest.
 */
+ (NSURLRequest *)requestWithURN:(NSString *)URN
                            data:(NSDictionary *)data;

@end