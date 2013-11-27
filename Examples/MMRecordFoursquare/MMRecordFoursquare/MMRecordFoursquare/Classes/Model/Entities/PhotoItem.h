//
//  PhotoItem.h
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/27/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "FSRecord.h"

@class PhotoGroup;

@interface PhotoItem : FSRecord

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * prefix;
@property (nonatomic, retain) NSString * suffix;
@property (nonatomic, retain) PhotoGroup *group;

@end
