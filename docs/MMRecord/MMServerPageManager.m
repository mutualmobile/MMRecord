//
//  MMServerPageManager.m
//  MMRecord
//
//  TODO: Replace with License Header
//

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