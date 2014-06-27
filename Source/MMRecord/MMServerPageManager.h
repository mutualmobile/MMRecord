// MMServerPageManager.h
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


/**
 `MMServerPageManager` encapsulates the logic for representing the current page from a given 
 request's response.  Further, it provides access to the next and previous pages via the URN's to 
 those resources.  This class should be treated as an interface and subclassed for a server's 
 specific implementation of pagination
 
 ## Pagination Best Practice
 
 The best practice for pagination is considered to be that the server will return the URN's for the
 next and previous page.  This removes the need for additional logic on the client side to determine 
 the next URN they should call to retrieve more data.
 
 ## Subclassing Notes
 
 This class is required to be subclassed.  There is no default implementation.  It is completely up 
 to the user to implement functionality that conforms to the below interface.  You are responsible 
 for maintaining the internal structure of this object such that the methods below will function as
 desired when they are called.  You must override the designated initializer.
 */

@interface MMServerPageManager : NSObject 

///--------------------------------
/// @name Server Request Properties
///--------------------------------

/**
 The data used to make the request which the page manager will represent
 */
@property (nonatomic, copy, readonly) NSDictionary *requestData;

/**
 The URN used to make the request which the page manager will represent
 */
@property (nonatomic, copy, readonly) NSString *requestURN;

/**
 The record class which started the request which the page manager will represent
 */
@property (nonatomic, strong, readonly) Class recordClass;

///-----------------------------
/// @name Designated Initializer
///-----------------------------

/**
 Initializes a page manager object to represent the current page of a request's response.
 
 @warning You must be sure to call super of this initializer to make sure you set the server request
 properties correctly on initialization.
 @warning You must also override this initializer to implement any custom properties or other data 
 structures that will support your implementation of this class.
 
 @param dict The response object dictionary.  This will be used to obtain the relevent pagination 
 data.
 @param requestURN The URN used to make the request.
 @param requestData The data parameters used to make the request.
 @param recordClass The MMRecord class which started the request.
 @return The newly-initialized MMServerPageManager subclass instance.
 */
- (instancetype)initWithResponseObject:(NSDictionary *)dict
                            requestURN:(NSString *)requestURN
                           requestData:(NSDictionary *)requestData
                           recordClass:(Class)recordClass;


///---------------------------------------------
/// @name Defining the Request for the Next Page
///---------------------------------------------

/**
 This method should return YES if there is a next page to request and NO if there is not a next page
 to request.  The default implementation of this method returns NO if the nextPageURN is nil or NULL
 and otherwise returns YES.
 
 @return YES if there is a next page
 */
- (BOOL)canRequestNextPage;

/**
 This method should be implemented one of two ways.  In the best case it will simply return the next
 page URN as returned by the server.  Alternatively, if you wish to use request parameters, then you 
 should return the original request URN and then modify the requestData object and return it in 
 nextPageData.
 
 @return the URN for the next page
 */
- (NSString *)nextPageURN;

/**
 This method should be implemented one of two ways.  If your API gives you the next page URN in the
 response then simply return nil.  Otherwise it may be easier to modify the original request's 
 requestData object to change the page index parameter to request the next page.
 
 @return the dictionary containing parameters for requesting the next page
 */
- (NSDictionary *)nextPageData;


///-------------------------------------------
/// @name Metadata Describing the Current Page
///-------------------------------------------

/**
 The total number of results.  This should be the same regardless of which page you're on for a 
 given set of results.
 
 @return The total number of results.
 */
- (NSInteger)totalResultsCount;

/**
 The number of results per page.  This should also be the same regardless of which page you're on,
 except possibly for the last page.
 
 @return The number of results per page.
 */
- (NSInteger)resultsPerPage;

/**
 The index of the current page.  The value returned by this method may need to be computed in some 
 cases from the number of results and size per page depending on the values returned by the API.
 
 @return The current page index.
 */
- (NSInteger)currentPageIndex;


///------------------------------------
/// @name Next Page Request Convenience
///------------------------------------

/**
 This method starts a request for the next page.  This is intended to be used in two ways.  
 MMRecord's pagination support provides a convenience variable for starting the request for the next
 page after a given page's request has finished.  If that convenience variable is set then this 
 method will be called.  The other common case is that the first page of results are used to 
 populate a list and the list scrolls down and the next set of results need to be fetched.  If the
 caller of the original request holds a reference to this page manager object then it is then simple 
 for them to lazily start the next page request to get the next set of data to populate the list.  
 This method should be implemented by calling the startPagedRequest method on the MMRecord class
 property of the page manager.  The best case implementation would be to pass through the following 
 parameters to the startPagedRequest method as well as the nextPageURN/nextPageData from the page 
 manager.
 
 @param context The context with which to start the request.  This should be passed to MMRecord's 
 startPagedRequest method.
 @param domain The domain that this request should be associated with.
 @param resultBlock A block object to be executed when the request finishes successfully.  
 This should be passed to MMRecord's startPagedRequest method.
 @param failureBlock A block object to be executed when the request finishes unsuccessfully.  
 This should be passed to MMRecord's startPagedRequest method.
 */
- (void)startNextPageRequestWithContext:(NSManagedObjectContext *)context
                                 domain:(id)domain
                            resultBlock:(void(^)(NSArray *objects, id pageManager, BOOL *requestNextPage))resultBlock
                           failureBlock:(void(^)(NSError *error))failureBlock;

@end