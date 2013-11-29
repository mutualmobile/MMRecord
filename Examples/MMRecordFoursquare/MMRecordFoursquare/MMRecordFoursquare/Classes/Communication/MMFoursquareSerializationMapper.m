//
//  MMFoursquareSerializationMapper.m
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/29/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMFoursquareSerializationMapper.h"

@implementation MMFoursquareSerializationMapper

- (NSEntityDescription *)recordResponseSerializer:(AFMMRecordResponseSerializer *)serializer
                                entityForResponse:(NSURLResponse *)response
                                   responseObject:(id)responseObject
                                          context:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:@"Venue" inManagedObjectContext:context];
}

@end
