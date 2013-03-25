//
//  MMInstagramPageManager.m
//  MMRecordInstagram
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMInstagramPageManager.h"

@interface MMInstagramPageManager ()

@property (nonatomic, copy) NSDictionary *pagination;
@property (nonatomic, copy) NSString *nextMaxTagID;

@end

@implementation MMInstagramPageManager

- (id)initWithResponseObject:(NSDictionary *)dict
                  requestURN:(NSString *)requestURN
                 requestData:(NSDictionary *)requestData
                 recordClass:(Class)recordClass {
    if ((self = [super initWithResponseObject:dict
                                   requestURN:requestURN
                                  requestData:requestData
                                  recordClass:recordClass])) {
        self.pagination = [dict objectForKey:@"pagination"];
        self.nextMaxTagID = [self.pagination objectForKey:@"next_max_tag_id"];
    }
    
    return self;
}
- (BOOL)canRequestNextPage {
    return (self.nextMaxTagID != nil &&
            self.nextMaxTagID != (id)[NSNull null]);
}

- (NSString*)nextPageURN {
    return self.requestURN;
}

- (NSDictionary*)nextPageData {
    return @{@"max_tag_id" : self.nextMaxTagID};
}

- (NSInteger)totalResultsCount {
    return 0;
}

- (NSInteger)resultsPerPage {
    return 0;
}

- (NSInteger)currentPageIndex {
    return 0;
}

@end
