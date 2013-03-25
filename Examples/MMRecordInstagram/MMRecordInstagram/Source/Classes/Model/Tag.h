//
//  Tag.h
//  MMRecordInstagram
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "MMInstagramRecord.h"

@class Media;

@interface Tag : MMInstagramRecord

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *media;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addMediaObject:(Media *)value;
- (void)removeMediaObject:(Media *)value;
- (void)addMedia:(NSSet *)values;
- (void)removeMedia:(NSSet *)values;

@end
