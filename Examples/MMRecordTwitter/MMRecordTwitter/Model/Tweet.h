//
//  Tweet.h
//  MMRecordTwitter
//
//  Created by Conrad Stoll on 3/22/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "TWRecord.h"

@class User;

@interface Tweet : TWRecord

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) User *user;

@property (nonatomic, readonly) BOOL isFavorite;

@end
