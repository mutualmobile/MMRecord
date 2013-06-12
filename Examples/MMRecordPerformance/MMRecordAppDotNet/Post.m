//
//  Post.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "Post.h"

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
                      resultBlock:(void (^)(NSArray *posts))resultBlock
                     failureBlock:(void (^)(NSError *error))failureBlock {
    [self startRequestWithURN:@"stream/0/posts/stream/global"
                         data:nil
                      context:context
                       domain:self
                  resultBlock:resultBlock
                 failureBlock:failureBlock];
}

@end
