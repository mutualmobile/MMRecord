//
//  ADNPostManager.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADNPageManager;

// This class manages the pagination logic of retrieving pages worth of posts.
@interface ADNPostManager : NSObject

// Designated Initializer
- (id)initWithPosts:(NSArray *)posts pageManager:(ADNPageManager *)pageManager;

// Request to check for and obtain more recent posts.
- (void)getMoreRecentPosts:(void (^)(NSArray *posts))resultBlock;

// Request to obtain the next set of previous posts, if any.
- (void)getPreviousPosts:(void (^)(NSArray *posts))resultBlock;

@end
