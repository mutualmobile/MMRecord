//
//  Tweet+MMRecord.h
//  MMRecordTwitter
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "Tweet.h"

@interface Tweet (MMRecord)

+ (void)timelineTweetsWithContext:(NSManagedObjectContext *)context
                           domain:(id)domain
                      resultBlock:(void (^)(NSArray *tweets, MMServerPageManager *pageManager, BOOL *requestNextPage))resultBlock
                     failureBlock:(void (^)(NSError *error))failureBlock;

+ (void)favoriteTweetsWithContext:(NSManagedObjectContext *)context
                           domain:(id)domain
                      resultBlock:(void (^)(NSArray *tweets, MMServerPageManager *pageManager, BOOL *requestNextPage))resultBlock
                     failureBlock:(void (^)(NSError *error))failureBlock;

@end
