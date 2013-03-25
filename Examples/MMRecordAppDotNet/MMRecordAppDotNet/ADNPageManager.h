//
//  ADNPageManager.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMServerPageManager.h"

@interface ADNPageManager : MMServerPageManager

/* 
 Request more recent posts for a given page request. By default, this method will automatically 
 request every new page of posts up to the last post you have downloaded. The result block will be 
 called once per page repeatedly until all pages are downloaded. To disable this functionality, 
 set requestNextPage to NO.
 */
- (void)getMoreRecentPageWithContext:(NSManagedObjectContext*)context
                              domain:(id)domain
                         resultBlock:(void(^)(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage))resultBlock
                        failureBlock:(void(^)(NSError *error))failureBlock;

/* 
 Request the previous set of posts for a given page request. By default this method will ONLY 
 request one new page of previous posts. To request multiple pages you can set requestNextPage to 
 YES. If requestNextPage is set to YES, then the resultBlock will be called once per page of results
 returned. Using the requestNextPage automatic functionality is not recommended on this method 
 because you are likely to exceed your quota of API requests due to the size of the global stream 
 of posts.
 */
- (void)getPreviousPageWithContext:(NSManagedObjectContext*)context
                            domain:(id)domain
                       resultBlock:(void(^)(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage))resultBlock
                      failureBlock:(void(^)(NSError *error))failureBlock;

@end
