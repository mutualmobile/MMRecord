//
//  MMFoursquareResponseMapper.m
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/5/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMFoursquareResponseSerializer.h"

@implementation MMFoursquareResponseSerializer

- (NSEntityDescription *)recordResponseSerializer:(MMRecordResponseSerializer *)serializer
                                entityForResponse:(NSURLResponse *)response
                                   responseObject:(id)responseObject {
    return [NSEntityDescription entityForName:@"Venue" inManagedObjectContext:self.context];
}

@end
