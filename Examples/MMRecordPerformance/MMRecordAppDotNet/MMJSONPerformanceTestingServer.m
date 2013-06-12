//
//  MMJSONPerformanceTestingServer.m
//  MMRecordPerformance
//
//  Created by Conrad Stoll on 6/12/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMJSONPerformanceTestingServer.h"

NSUInteger _resultSetSize = 1;

@implementation MMJSONPerformanceTestingServer

+ (void)setResultSetSize:(NSUInteger)resultSetSize {
    _resultSetSize = resultSetSize;
}

+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)data
                      paged:(BOOL)paged
                     domain:(id)domain
                    batched:(BOOL)batched
              dispatchGroup:(dispatch_group_t)dispatchGroup
              responseBlock:(void (^)(id))responseBlock
               failureBlock:(void (^)(NSError *))failureBlock {
    [self
     loadJSONResource:@"posts"
     responseBlock:^(NSDictionary *responseData) {
         NSArray *data = [responseData valueForKey:@"data"];
         NSDictionary *firstObject = [data objectAtIndex:0];
         
         NSMutableDictionary *newResponseData = [NSMutableDictionary dictionary];
         
         NSMutableArray *newDataArray = [NSMutableArray array];
         
         for (NSUInteger item = 0; item < _resultSetSize; ++item) {
             NSDictionary *dict = [firstObject mutableCopy];
             [dict setValue:@(item) forKey:@"id"];
             [newDataArray addObject:dict];
         }
         
         [newResponseData setValue:newDataArray forKey:@"data"];
         
         responseBlock(newResponseData);
     }
     failureBlock:failureBlock];
}

@end
