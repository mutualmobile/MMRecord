//
//  Location.h
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/27/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "FSRecord.h"

@class Venue;

@interface Location : FSRecord

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * crossStreet;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * cc;
@property (nonatomic, retain) NSString * postalCode;
@property (nonatomic, retain) Venue *venue;

@end
