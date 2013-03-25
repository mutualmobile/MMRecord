//
//  Tweet+MMRecord.m
//  MMRecordTwitter
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "Tweet+MMRecord.h"

@implementation Tweet (MMRecord)

+ (void)timelineTweetsWithContext:(NSManagedObjectContext *)context
                           domain:(id)domain
                      resultBlock:(void (^)(NSArray *tweets, MMServerPageManager *pageManager, BOOL *requestNextPage))resultBlock
                     failureBlock:(void (^)(NSError *))failureBlock {
    [Tweet startPagedRequestWithURN:@"statuses/home_timeline.json"
                          data:nil
                       context:context
                        domain:self
                   resultBlock:resultBlock
                  failureBlock:failureBlock];
}

+ (void)favoriteTweetsWithContext:(NSManagedObjectContext *)context
                           domain:(id)domain
                      resultBlock:(void (^)(NSArray *tweets, MMServerPageManager *pageManager, BOOL *requestNextPage))resultBlock
                     failureBlock:(void (^)(NSError *))failureBlock {
    [Tweet startPagedRequestWithURN:@"favorites/list.json"
                               data:nil
                            context:context
                             domain:self
                        resultBlock:resultBlock
                       failureBlock:failureBlock];
}

@end
