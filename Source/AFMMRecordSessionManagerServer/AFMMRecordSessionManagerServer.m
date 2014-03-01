// AFMMRecordSessionManagerServer.m
//
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
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

#import "AFMMRecordSessionManagerServer.h"

#import <objc/runtime.h>
#import "AFHTTPSessionManager.h"

static id AFServer_registeredAFSessionManager;

@implementation AFMMRecordSessionManagerServer

+ (BOOL)registerAFHTTPSessionManager:(id)sessionManager {
    if ([sessionManager isKindOfClass:[AFHTTPSessionManager class]] ||
        [[sessionManager class] isSubclassOfClass:[AFHTTPSessionManager class]]) {
        AFServer_registeredAFSessionManager = sessionManager;
        return YES;
    }
    
    return NO;
}

+ (void)cancelRequestsWithDomain:(id)domain {
    id sessionManager = AFServer_registeredAFSessionManager;
    
    if (domain) {
        NSArray *allTasks = [sessionManager dataTasks];
        
        for (NSURLSessionDataTask *task in allTasks) {
            Class domainClass = [domain class];
            
            if ([[self taskDomainFortask:task] isEqualToString:NSStringFromClass(domainClass)]) {
                [task cancel];
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
    id sessionManager = AFServer_registeredAFSessionManager;
    
    if (paged) {
        
    }
    
    NSURLSessionDataTask *task =
    [sessionManager
     GET:newURN
     parameters:newData
     success:^(NSURLSessionDataTask *task, id responseObject) {
         if (responseBlock) {
             responseBlock(responseObject);
         }
     }
     failure:^(NSURLSessionDataTask *task, NSError *error) {
         if (failureBlock) {
             failureBlock(error);
         }
     }];
    
    if (domain) {
        Class domainClass = [domain class];
        
        [self setTaskDomain:NSStringFromClass(domainClass) onTask:task];
    }
}

+ (id)taskDomainFortask:(id)task {
    return objc_getAssociatedObject(task, @"MMRecord_recordClassName");
}

+ (void)setTaskDomain:(id)domain onTask:(id)task {
    objc_setAssociatedObject(task,  @"MMRecord_recordClassName", domain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end