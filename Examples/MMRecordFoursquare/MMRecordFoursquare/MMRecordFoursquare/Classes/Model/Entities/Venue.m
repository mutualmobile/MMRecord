//
//  Venue.m
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/27/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "Venue.h"
#import "Contact.h"
#import "FSCategory.h"
#import "Location.h"
#import "Menu.h"
#import "PhotoGroup.h"


@implementation Venue

@dynamic id;
@dynamic name;
@dynamic menu;
@dynamic photoGroups;
@dynamic location;
@dynamic contact;
@dynamic categories;

+ (NSString *)keyPathForResponseObject {
    return @"response.venues";
}

@end
