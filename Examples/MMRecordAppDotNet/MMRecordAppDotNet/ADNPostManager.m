//
//  ADNPostManager.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "ADNPostManager.h"

#import "ADNPageManager.h"
#import "MMDataManager.h"

@interface ADNPostManager ()

@property (nonatomic, strong) ADNPageManager *pageManager;

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSMutableArray *recentPosts;

@property (nonatomic, strong) ADNPageManager *recentPageManager;
@property (nonatomic, strong) ADNPageManager *previousPageManager;

@property (nonatomic) BOOL previousPostsRequestInProgress;
@property (nonatomic) BOOL moreRecentPostsRequestInProgress;

@end

@implementation ADNPostManager

- (id)initWithPosts:(NSArray *)posts pageManager:(ADNPageManager *)pageManager {
    if ((self = [super init])) {
        _pageManager = pageManager;
        _posts = [NSMutableArray array];
        _recentPosts = [NSMutableArray array];
        [_posts addObjectsFromArray:posts];
        
        self.recentPageManager = pageManager;
        self.previousPageManager = pageManager;
    }
    
    return self;
}

- (void)getMoreRecentPosts:(void (^)(NSArray *posts))resultBlock {
    if ([self shouldRequestMoreRecentPosts]) {
        NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
        
        [self.recentPageManager
         getMoreRecentPageWithContext:context
         domain:self
         resultBlock:^(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage) {
             [self populatePostsTableWithMoreRecentPosts:posts pageManager:pageManager];
             if (resultBlock != nil) {
                 resultBlock([self allPosts]);
             }
         }
         failureBlock:^(NSError *error) {
             [self endRequestingMoreRecentPosts];
             if (resultBlock != nil) {
                 resultBlock([self allPosts]);
             }
         }];
    }
}

- (void)getPreviousPosts:(void (^)(NSArray *posts))resultBlock {
    if ([self shouldRequestPreviousPosts]) {
        NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
        
        [self.previousPageManager
         getPreviousPageWithContext:context
         domain:self
         resultBlock:^(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage) {
             [self populatePostsTableWithPreviousPosts:posts pageManager:pageManager];
             if (resultBlock != nil) {
                 resultBlock([self allPosts]);
             }
         }
         failureBlock:^(NSError *error) {
             [self endRequestingPreviousPosts];
             if (resultBlock != nil) {
                 resultBlock([self allPosts]);
             }
         }];
    }
}


#pragma mark Private Methods

- (NSArray *)allPosts {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.recentPosts];
    [array addObjectsFromArray:self.posts];
    return array;
}


#pragma mark Initial Posts Request Utility Methods

- (void)populatePostsTableWithPosts:(NSArray *)posts pageManager:(ADNPageManager *)pageManager {
    self.previousPageManager = pageManager;
    self.recentPageManager = pageManager;
    [self.posts removeAllObjects];
    [self.posts addObjectsFromArray:posts];
}


#pragma mark - Recent Posts Utility Methods

- (BOOL)shouldRequestMoreRecentPosts {
    if (self.moreRecentPostsRequestInProgress) {
        return NO;
    }
    
    if (self.recentPageManager == nil) {
        return NO;
    }
    
    self.moreRecentPostsRequestInProgress = YES;
    
    return YES;
}

- (void)populatePostsTableWithMoreRecentPosts:(NSArray *)posts pageManager:(ADNPageManager *)pageManager {
    self.recentPageManager = pageManager;
    
    if ([pageManager canRequestNextPage]) {
        [self.recentPosts addObjectsFromArray:posts];
    } else {
        [self.recentPosts addObjectsFromArray:posts];
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.recentPosts];
        [array addObjectsFromArray:self.posts];
        self.posts = array;
        [self.recentPosts removeAllObjects];
    }
    
    [self endRequestingMoreRecentPosts];
}

- (void)endRequestingMoreRecentPosts {
    self.moreRecentPostsRequestInProgress = NO;
}


#pragma mark - Previous Posts Utility Methods

- (BOOL)shouldRequestPreviousPosts {
    if (self.previousPostsRequestInProgress) {
        return NO;
    }
    
    if (self.previousPageManager == nil) {
        return NO;
    }
    
    self.previousPostsRequestInProgress = YES;
    
    return YES;
}

- (void)populatePostsTableWithPreviousPosts:(NSArray *)posts pageManager:(ADNPageManager *)pageManager {
    self.previousPageManager = pageManager;
    [self.posts addObjectsFromArray:posts];
    self.previousPostsRequestInProgress = NO;
}

- (void)endRequestingPreviousPosts {
    self.previousPostsRequestInProgress = NO;
}


@end
