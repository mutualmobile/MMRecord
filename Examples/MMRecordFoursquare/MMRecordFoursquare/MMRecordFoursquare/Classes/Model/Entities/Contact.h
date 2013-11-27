//
//  Contact.h
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/27/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "FSRecord.h"

@class Venue;

@interface Contact : FSRecord

@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * formattedPhone;
@property (nonatomic, retain) Venue *venue;

@end
