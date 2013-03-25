//
//  Post.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "Post.h"

#import "ADNPageManager.h"
#import "User.h"

@implementation Post

@dynamic text;
@dynamic date;
@dynamic thread_id;
@dynamic id;
@dynamic user;
@dynamic source;

+ (void)getStreamPostsWithContext:(NSManagedObjectContext *)context
                           domain:(id)domain
                      resultBlock:(void (^)(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage))resultBlock
                     failureBlock:(void (^)(NSError *error))failureBlock {
    [self startPagedRequestWithURN:@"stream/0/posts/stream/global"
                              data:nil
                           context:context
                            domain:self
                       resultBlock:resultBlock
                      failureBlock:failureBlock];
}

+ (void)getPostsForUser:(User *)user
                context:(NSManagedObjectContext *)context
                 domain:(id)domain
            resultBlock:(void (^)(NSArray *, ADNPageManager *, BOOL *))resultBlock
           failureBlock:(void (^)(NSError *))failureBlock {
    NSString *URN = [NSString stringWithFormat:@"stream/0/users/%@/posts", user.id];
    
    [self startPagedRequestWithURN:URN
                              data:nil
                           context:context
                            domain:self
                       resultBlock:resultBlock
                      failureBlock:failureBlock];
}

@end
