//
//  ADNLiveServer.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMLiveServer.h"

#import "IGHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import <objc/runtime.h>
#import "MMInstagramPageManager.h"

@interface AFJSONRequestOperation (MMLiveServer)

@property (nonatomic, retain) id requestOperationDomain;

- (id)requestOperationDomain;
- (void)setRequestOperationDomain:(id)domain;

@end

@implementation MMLiveServer

+ (void)cancelRequestsWithDomain:(id)domain {
    IGHTTPClient *client = [IGHTTPClient sharedClient];
    
    if (domain) {
        for (NSOperation *operation in [client.operationQueue operations]) {
            if (![operation isKindOfClass:[AFJSONRequestOperation class]]) {
                continue;
            }
            
            Class domainClass = [domain class];
            
            if ([[(AFJSONRequestOperation*)operation requestOperationDomain] isEqualToString:NSStringFromClass(domainClass)]) {
                [operation cancel];
            }
        }
    }
}

+ (void)startRequestWithURN:(NSString *)URN
                       data:(NSDictionary *)data
                      paged:(BOOL)paged
                     domain:(id)domain
                    batched:(BOOL)batched
              dispatchGroup:(dispatch_group_t)dispatchGroup
              responseBlock:(void (^)(id responseObject))responseBlock
               failureBlock:(void (^)(NSError *error))failureBlock {
    NSString* newURN = [URN stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *newData = [NSMutableDictionary dictionaryWithDictionary:data];
    
    [newData addEntriesFromDictionary:@{@"client_id" : [[IGHTTPClient sharedClient] clientID]}];
    
    if (paged) {
        
    }
    
    NSMutableURLRequest *baseRequest = [[IGHTTPClient sharedClient] requestWithMethod:@"GET" path:newURN parameters:newData];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:baseRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        responseBlock(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failureBlock(error);
    }];
    
    if (domain) {
        Class domainClass = [domain class];
        
        [operation setRequestOperationDomain:NSStringFromClass(domainClass)];
    }
    
    [[IGHTTPClient sharedClient] enqueueHTTPRequestOperation:operation];
}

+ (Class)pageManagerClass {
    return [MMInstagramPageManager class];
}

@end

@implementation AFJSONRequestOperation (MMLiveServer)

- (id)requestOperationDomain {
    return objc_getAssociatedObject(self, @"MMRecord_recordClassName");
}

- (void)setRequestOperationDomain:(id)domain {
    objc_setAssociatedObject(self,  @"MMRecord_recordClassName", domain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end