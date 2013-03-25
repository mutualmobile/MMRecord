//
//  Counts.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "ADNRecord.h"

@class User;

@interface Counts : ADNRecord

@property (nonatomic, retain) NSNumber * followers;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSNumber * posts;
@property (nonatomic, retain) NSNumber * stars;
@property (nonatomic, retain) User *user;

- (NSString *)formattedCountString;

@end
