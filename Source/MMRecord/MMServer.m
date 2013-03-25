//
//  MMServer.m
//  MMRecord
//
//  TODO: Replace with License Header
//

#import "MMServer.h"

static MMServerSessionTimeoutBlock MM_ServerSessionTimeoutBlock;

@implementation MMServer

+ (void)registerSessionTimeoutBlock:(MMServerSessionTimeoutBlock)block {
    MM_ServerSessionTimeoutBlock = [block copy];
}

+ (void)cancelRequestsWithDomain:(id)domain {
    [self doesNotRecognizeSelector:_cmd];
}

+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)data
                      paged:(BOOL)paged
                     domain:(id)domain
                    batched:(BOOL)batched
              dispatchGroup:(dispatch_group_t)dispatchGroup
              responseBlock:(void(^)(id responseObject))responseBlock
               failureBlock:(void(^)(NSError *error))failureBlock { 
    [self doesNotRecognizeSelector:_cmd];
}

+ (NSURLRequest *)requestWithURN:URN data:(NSDictionary *)data {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (MMServerSessionTimeoutBlock)sessionTimeoutBlock {
    return MM_ServerSessionTimeoutBlock;
}

#pragma mark - Paging

+ (Class)pageManagerClass {
    return nil;
}

@end

