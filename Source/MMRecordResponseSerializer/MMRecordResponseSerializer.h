//
//  MMRecordResponseSerializer.h
//  AFNetworking iOS Example
//
//  Created by Conrad Stoll on 10/17/13.
//  Copyright (c) 2013 Gowalla. All rights reserved.
//

#import "AFURLResponseSerialization.h"

#import <CoreData/CoreData.h>

@interface MMRecordResponseSerializer : AFHTTPResponseSerializer <AFURLResponseSerialization>

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;
@property (nonatomic, strong, readonly) AFHTTPResponseSerializer *HTTPResponseSerializer;

+ (instancetype)serializerWithManagedObjectContext:(NSManagedObjectContext *)context
                            HTTPResponseSerializer:(AFHTTPResponseSerializer *)HTTPResponseSerializer;

// Required Subclass Methods

- (NSEntityDescription *)recordResponseSerializer:(MMRecordResponseSerializer *)serializer
                                entityForResponse:(NSURLResponse *)response
                                   responseObject:(id)responseObject;

@end