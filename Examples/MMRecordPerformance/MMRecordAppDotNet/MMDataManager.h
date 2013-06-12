//
//  MMDataManager.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MMDataManager : NSObject {
	NSManagedObjectModel            * MM_managedObjectModel;
	NSManagedObjectContext          * MM_managedObjectContext;
	NSPersistentStoreCoordinator    * MM_persistentStoreCoordinator;
}

@property (nonatomic, readonly) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, readonly) NSManagedObjectContext* managedObjectContext;

- (BOOL)save;

- (void)reset;

- (void)handleFatalCoreDataError:(NSError*)error;

+ (MMDataManager*)sharedDataManager;

@end
