//
//  Venue.m
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/5/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "Venue.h"

@implementation Venue

@dynamic id;
@dynamic name;

+ (NSString *)keyPathForResponseObject {
    return @"response.venue";
}

@end
