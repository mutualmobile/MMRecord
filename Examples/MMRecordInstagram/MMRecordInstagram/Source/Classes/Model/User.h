//
//  User.h
//  MMRecordInstagram
//
//  Created by Rene S Cacheaux on 3/20/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMInstagramRecord.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media;

@interface User : MMInstagramRecord

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) id user;
@property (nonatomic, retain) NSSet *media;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addMediaObject:(Media *)value;
- (void)removeMediaObject:(Media *)value;
- (void)addMedia:(NSSet *)values;
- (void)removeMedia:(NSSet *)values;

@end
