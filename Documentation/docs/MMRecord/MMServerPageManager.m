// MMServerPageManager.m
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

#import "MMServerPageManager.h"


@implementation MMServerPageManager

@synthesize requestData = requestData_;
@synthesize requestURN = requestURN_;
@synthesize recordClass = recordClass_;

- (id)initWithResponseObject:(NSDictionary *)dict
                  requestURN:(NSString *)requestURN
                 requestData:(NSDictionary *)requestData
                 recordClass:(Class)recordClass {
    if ((self = [super init])) {
        requestURN_ = requestURN;
        requestData_ = requestData;
        recordClass_ = recordClass;
    }
    
    return self;
}

+ (id)pageManagerWithResponseObject:(NSDictionary *)dict
                         requestURN:(NSString *)requestURN
                        requestData:(NSDictionary *)requestData
                        recordClass:(Class)recordClass {
    return [[self alloc] initWithResponseObject:dict
                                     requestURN:requestURN
                                    requestData:requestData
                                    recordClass:recordClass];
}

- (BOOL)canRequestNextPage {
    return (self.nextPageURN != nil &&
            self.nextPageURN != (id)[NSNull null]);
}

- (NSString*)nextPageURN {
    return nil;
}

- (NSDictionary*)nextPageData {
    return nil;
}

- (NSInteger)totalResultsCount {
    [self doesNotRecognizeSelector:_cmd];
    
    return 0;
}

- (NSInteger)resultsPerPage {
    [self doesNotRecognizeSelector:_cmd];
    
    return 0;
}

- (NSInteger)currentPageIndex {
    [self doesNotRecognizeSelector:_cmd];
    
    return 0;
}

- (void)startNextPageRequestWithContext:(NSManagedObjectContext*)context
                                 domain:(id)domain
                            resultBlock:(void(^)(NSArray *objects, id pageManager, BOOL *requestNextPage))resultBlock
                           failureBlock:(void(^)(NSError *error))failureBlock {
    if ([self canRequestNextPage]) {
        [self.recordClass startPagedRequestWithURN:[self nextPageURN]
                                              data:[self nextPageData]
                                           context:context
                                            domain:domain
                                       resultBlock:resultBlock
                                      failureBlock:failureBlock];
    }
}

@end