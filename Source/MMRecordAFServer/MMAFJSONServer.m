// MMAFJSONServer.m
//
// Copyright (c) 2013 Mutual Mobile (http://www.mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MMAFJSONServer.h"

#import <objc/runtime.h>
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

static id MMAFHTTPServer_registeredAFHTTPClient;

@implementation MMAFJSONServer

+ (BOOL)registerAFHTTPClient:(id)client {
    if ([client isKindOfClass:[AFHTTPClient class]] ||
        [[client class] isSubclassOfClass:[AFHTTPClient class]]) {
        MMAFHTTPServer_registeredAFHTTPClient = client;
        return YES;
    }
    
    return NO;
}

+ (void)cancelRequestsWithDomain:(id)domain {
    id client = MMAFHTTPServer_registeredAFHTTPClient;
    
    if (domain) {
        for (NSOperation *operation in [[client performSelector:@selector(operationQueue)] operations]) {
            if (![operation isKindOfClass:[AFJSONRequestOperation class]]) {
                continue;
            }
            
            Class domainClass = [domain class];
            
            if ([[self requestOperationDomainForOperation:operation] isEqualToString:NSStringFromClass(domainClass)]) {
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
    NSDictionary *newData = data;
    id client = MMAFHTTPServer_registeredAFHTTPClient;
    
    if (paged) {
        
    }
    
    NSMutableURLRequest *baseRequest = [client requestWithMethod:@"GET" path:newURN parameters:newData];
    
    id operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:baseRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (responseBlock) {
            responseBlock(JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
    
    if (domain) {
        Class domainClass = [domain class];
        
        [self setRequestOperationDomain:NSStringFromClass(domainClass) onOperation:operation];
    }
    
    [client enqueueHTTPRequestOperation:operation];
}

+ (id)requestOperationDomainForOperation:(id)operation {
    return objc_getAssociatedObject(operation, @"MMRecord_recordClassName");
}

+ (void)setRequestOperationDomain:(id)domain onOperation:(id)operation {
    objc_setAssociatedObject(operation,  @"MMRecord_recordClassName", domain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end