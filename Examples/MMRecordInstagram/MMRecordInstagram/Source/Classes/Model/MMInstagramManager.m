//
//  MMInstagramManager.m
//  MMRecordInstagram
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMInstagramManager.h"

#import "MMAppDelegate.h"

@implementation MMInstagramManager

- (NSFetchedResultsController *)fetchedResultsController {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Media"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_time" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    MMAppDelegate *appDelegate = (MMAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    [controller performFetch:NULL];
    
    return controller;
}

@end
