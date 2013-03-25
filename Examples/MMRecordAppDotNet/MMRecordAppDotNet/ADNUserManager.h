//
//  TWUserManager.h
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMDataManager.h"

@class User;

@interface ADNUserManager : NSObject

- (NSFetchedResultsController *)usersFetchedResultsController;
- (NSFetchedResultsController *)postsFetchedResultsControllerForUser:(User *)user;

@end
