//
//  Media.h
//  MMRecordInstagram
//
//  Created by Rene S Cacheaux on 3/20/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMInstagramRecord.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Media : MMInstagramRecord

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * created_time;
@property (nonatomic, retain) id media;
@property (nonatomic, retain) NSManagedObject *user;
@property (nonatomic, retain) NSSet * tags;

@end
