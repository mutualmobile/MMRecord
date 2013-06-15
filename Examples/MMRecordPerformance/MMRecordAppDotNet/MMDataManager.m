//
//  MMDataManager.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMDataManager.h"

static MMDataManager* MM_sharedDataManager;

@implementation MMDataManager

- (id)init {
	assert(MM_sharedDataManager == nil);
	
	if ((self = [super init])) {
		
	}
	
	return self;
}

- (BOOL)save {
	NSError* error = nil;
	if (![self.managedObjectContext save:&error]) {
		[self handleFatalCoreDataError:error];
		return NO;
	}
	
	return YES;
}

- (void)cleanupPersistantStoresWithCoordinator:(NSPersistentStoreCoordinator *)persistantStoreCoordinator {
    NSError *error = nil;
    NSArray *persistantStores = persistantStoreCoordinator.persistentStores;
    for (NSPersistentStore *store in persistantStores) {
        [persistantStoreCoordinator removePersistentStore:store error:nil];
        
        // Delete file
        if ([[NSFileManager defaultManager] fileExistsAtPath:store.URL.path]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:&error]) {
                [self handleFatalCoreDataError:error];
            }
        }
    }
    
    MM_managedObjectContext = nil;
    MM_persistentStoreCoordinator = nil;
}

- (void)reset {
    [MM_managedObjectContext reset];
    
    [self cleanupPersistantStoresWithCoordinator:MM_persistentStoreCoordinator];
}

- (NSManagedObjectContext*)managedObjectContext {
	if (MM_managedObjectContext != nil) {
		return MM_managedObjectContext;
	}
	
	MM_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	MM_managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
	
	return MM_managedObjectContext;
}

- (NSURL*)databaseURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *homeDirectory = [paths objectAtIndex:0];
    
    NSString* databaseFilename = [homeDirectory stringByAppendingPathComponent:@"Test"];
    return [NSURL fileURLWithPath:databaseFilename];
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	if (MM_persistentStoreCoordinator != nil) {
		return MM_persistentStoreCoordinator;
	}
	
    BOOL memory = NO;
    
    if (memory) {
        MM_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError* error = nil;
        if (![MM_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                         configuration:nil
                                                                   URL:nil
                                                               options:nil error:&error])
        {
            [self handleFatalCoreDataError:error];
            return nil;
        }
    } else {
        MM_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError* error = nil;
        if (![MM_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                         configuration:nil
                                                                   URL:[self databaseURL]
                                                               options:nil error:&error])
        {
            [self handleFatalCoreDataError:error];
            return nil;
        }
    }
    
	return MM_persistentStoreCoordinator;
}
- (NSManagedObjectModel*)managedObjectModel {
	if (MM_managedObjectModel != nil) {
		return MM_managedObjectModel;
	}
	
	MM_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	
	return MM_managedObjectModel;
}

- (void)handleFatalCoreDataError:(NSError*)error {
	NSLog(@"Core data error:");
	NSLog(@"%@", error);
	NSLog(@"%@", [error userInfo]);
}

#pragma mark static
+ (MMDataManager*)sharedDataManager {
	if (MM_sharedDataManager == nil) {
		MM_sharedDataManager = [[MMDataManager alloc] init];
	}
	
	return MM_sharedDataManager;
}

@end
