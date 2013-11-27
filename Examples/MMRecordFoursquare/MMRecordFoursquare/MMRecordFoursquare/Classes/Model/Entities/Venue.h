//
//  Venue.h
//  MMRecordFoursquare
//
//  Created by Conrad Stoll on 11/27/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "FSRecord.h"

@class Contact, FSCategory, Location, Menu, PhotoGroup;

@interface Venue : FSRecord

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Menu *menu;
@property (nonatomic, retain) NSOrderedSet *photoGroups;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) Contact *contact;
@property (nonatomic, retain) NSOrderedSet *categories;
@end

@interface Venue (CoreDataGeneratedAccessors)

- (void)insertObject:(PhotoGroup *)value inPhotoGroupsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhotoGroupsAtIndex:(NSUInteger)idx;
- (void)insertPhotoGroups:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePhotoGroupsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPhotoGroupsAtIndex:(NSUInteger)idx withObject:(PhotoGroup *)value;
- (void)replacePhotoGroupsAtIndexes:(NSIndexSet *)indexes withPhotoGroups:(NSArray *)values;
- (void)addPhotoGroupsObject:(PhotoGroup *)value;
- (void)removePhotoGroupsObject:(PhotoGroup *)value;
- (void)addPhotoGroups:(NSOrderedSet *)values;
- (void)removePhotoGroups:(NSOrderedSet *)values;
- (void)insertObject:(FSCategory *)value inCategoriesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCategoriesAtIndex:(NSUInteger)idx;
- (void)insertCategories:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCategoriesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCategoriesAtIndex:(NSUInteger)idx withObject:(FSCategory *)value;
- (void)replaceCategoriesAtIndexes:(NSIndexSet *)indexes withCategories:(NSArray *)values;
- (void)addCategoriesObject:(FSCategory *)value;
- (void)removeCategoriesObject:(FSCategory *)value;
- (void)addCategories:(NSOrderedSet *)values;
- (void)removeCategories:(NSOrderedSet *)values;
@end
