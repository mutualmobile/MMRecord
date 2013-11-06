//
//  Venue.h
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/5/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "FSRecord.h"

@interface Venue : FSRecord

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *name;

@end
