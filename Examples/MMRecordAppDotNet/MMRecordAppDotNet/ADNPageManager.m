//
//  ADNPageManager.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "ADNPageManager.h"

@interface ADNPageManager ()

@property (nonatomic, copy) NSDictionary *meta;
@property (nonatomic, strong) NSNumber *maxID;
@property (nonatomic, strong) NSNumber *minID;
@property (nonatomic, strong) NSNumber *more;

@property (nonatomic, strong) NSMutableDictionary *privateRequestData;
@property (nonatomic, strong) NSNumber *originalMaxID;

@property (nonatomic, readonly) BOOL hasMoreResults;

@end

@implementation ADNPageManager

- (id)initWithResponseObject:(NSDictionary *)dict
                  requestURN:(NSString *)requestURN
                 requestData:(NSDictionary *)requestData
                 recordClass:(Class)recordClass {
    if ((self = [super initWithResponseObject:dict
                                   requestURN:requestURN
                                  requestData:requestData
                                  recordClass:recordClass])) {
        self.privateRequestData = [NSMutableDictionary dictionaryWithDictionary:requestData];
        [self configurePageForDict:dict];
    }
    
    return self;
}

- (void)configurePageForDict:(NSDictionary *)dict {
    NSDictionary *meta = [dict objectForKey:@"meta"];
    self.meta = meta;
    self.maxID = [meta objectForKey:@"max_id"];
    self.minID = [meta objectForKey:@"min_id"];
    self.more = [meta objectForKey:@"more"];
}

- (BOOL)canRequestNextPage {
    return [self.more boolValue];
}

- (BOOL)canRequestRecentPage {
    if (self.maxID == nil) {
        // You can always request more recent results.
    }
    
    return (self.maxID != nil);
}

- (NSString*)nextPageURN {
    return self.requestURN;
}

- (NSDictionary*)nextPageData {
    NSMutableDictionary *dict = [self.requestData mutableCopy];
    
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
    }
    
    if (self.minID != nil) {
        [dict setObject:self.minID forKey:@"before_id"];
    }
    
    return dict;
}

- (NSDictionary *)moreRecentPageData {    
    if (self.maxID != nil) {
        [self.privateRequestData setObject:self.maxID forKey:@"since_id"];
    }
    return self.privateRequestData;
}

- (NSInteger)totalResultsCount {    
    return 0;
}

- (NSInteger)resultsPerPage {
    return 20;
}

- (NSInteger)currentPageIndex {
    return 0;
}

- (void)getMoreRecentPageWithContext:(NSManagedObjectContext*)context
                              domain:(id)domain
                         resultBlock:(void(^)(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage))resultBlock
                        failureBlock:(void(^)(NSError *error))failureBlock {
    if ([self canRequestRecentPage]) {
        [self.recordClass
         startPagedRequestWithURN:[self nextPageURN ]
         data:[self moreRecentPageData]
         context:context
         domain:domain
         resultBlock:^(NSArray *objects, MMServerPageManager *pageManager, BOOL *requestNextPage) {
             if ([objects count] == 0) {
                 resultBlock(objects, (ADNPageManager *)self, requestNextPage);
                 return;
             }
             
             ADNPageManager *manager = (ADNPageManager *)pageManager;
             
             if ([[manager.meta valueForKey:@"more"] boolValue]) {
                 *requestNextPage = YES;
                 if (self.originalMaxID == nil) {
                     self.originalMaxID = manager.maxID;
                 }
                 
                 manager.originalMaxID = self.originalMaxID;
             } else {
                 *requestNextPage = NO;
                 [manager.privateRequestData removeObjectForKey:@"before_id"];
                 if (self.originalMaxID != nil) {
                     manager.maxID = self.originalMaxID;
                     self.originalMaxID = nil;
                 }
             }
             
             if (manager.maxID == nil) {
                 manager.maxID = self.maxID;
             }
             
             resultBlock(objects, (ADNPageManager *)pageManager, requestNextPage);
         }
         failureBlock:failureBlock];
    } else {
        if (failureBlock != nil) {
            failureBlock(nil);
        }
    }
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
    } else {
        if (failureBlock != nil) {
            failureBlock(nil);
        }
    }
}

- (void)getPreviousPageWithContext:(NSManagedObjectContext*)context
                            domain:(id)domain
                       resultBlock:(void(^)(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage))resultBlock
                      failureBlock:(void(^)(NSError *error))failureBlock {
    if ([self canRequestNextPage]) {
        [self.recordClass startPagedRequestWithURN:[self nextPageURN ]
                                              data:[self nextPageData]
                                           context:context
                                            domain:domain
                                       resultBlock:resultBlock
                                      failureBlock:failureBlock];
    } else {
        if (failureBlock != nil) {
            failureBlock(nil);
        }
    }
}

@end
