//
//  TWUserManager.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "ADNUserManager.h"

@implementation ADNUserManager

- (NSFetchedResultsController *)usersFetchedResultsController {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    [controller performFetch:NULL];
    
    return controller;
}

- (NSFetchedResultsController *)postsFetchedResultsControllerForUser:(User *)user {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.user = %@", user];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    fetchRequest.predicate = predicate;
    
    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    [controller performFetch:NULL];
    
    return controller;
}

@end
