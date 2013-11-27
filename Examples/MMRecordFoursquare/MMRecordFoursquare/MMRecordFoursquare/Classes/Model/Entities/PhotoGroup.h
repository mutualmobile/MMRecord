//
//  PhotoGroup.h
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/27/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "FSRecord.h"

@class PhotoItem, Venue;

@interface PhotoGroup : FSRecord

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSOrderedSet *items;
@property (nonatomic, retain) Venue *venue;
@end

@interface PhotoGroup (CoreDataGeneratedAccessors)

- (void)insertObject:(PhotoItem *)value inItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx;
- (void)insertItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(PhotoItem *)value;
- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)values;
- (void)addItemsObject:(PhotoItem *)value;
- (void)removeItemsObject:(PhotoItem *)value;
- (void)addItems:(NSOrderedSet *)values;
- (void)removeItems:(NSOrderedSet *)values;
@end
