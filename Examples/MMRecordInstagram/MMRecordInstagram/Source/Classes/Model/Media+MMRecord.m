//
//  Media+MMRecord.m
//  MMRecordInstagram
//
//  Created by Rene S Cacheaux on 3/20/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "Media+MMRecord.h"

#import "MMAppDelegate.h"

typedef void (^MMRecordResultBlock)(NSArray *records);
typedef void (^MMRecordFailureBlock)(NSError *error);


@implementation Media (MMRecord)

+ (void)getMediaWithSearchText:(NSString *)text resultBlock:(void (^)(NSArray *, id, BOOL *))resultBlock {
    NSString *URN = [NSString stringWithFormat:@"tags/%@/media/recent", text];
    
    MMAppDelegate *appDelegate = (MMAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    [Media
     startPagedRequestWithURN:URN
     data:nil
     context:context
     domain:self
     resultBlock:^(NSArray *records, id pageManager, BOOL *requestNextPage) {
         if (resultBlock) {
             resultBlock(records, pageManager, requestNextPage);
         };
     }
     failureBlock:nil];
}

@end
