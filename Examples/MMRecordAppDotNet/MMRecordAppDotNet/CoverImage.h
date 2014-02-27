//
//  CoverImage.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 2/27/14.
//  Copyright (c) 2014 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "ADNRecord.h"

@class User;

@interface CoverImage : ADNRecord

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) User *user;

@end
