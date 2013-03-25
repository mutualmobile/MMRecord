//
//  MMSearchManager.m
//  MMRecordInstagram
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "MMSearchManager.h"

#import "Media.h"
#import "Media+MMRecord.h"
#import "MMAppDelegate.h"
#import "MMInstagramPageManager.h"
#import "Tag.h"

@interface MMSearchManager ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) MMInstagramPageManager *pageManager;
@property (nonatomic) BOOL requestingNextPage;

@end

@implementation MMSearchManager

- (id)initWithSearchString:(NSString *)text {
    if ((self = [super init])) {
        _text = text;
    }
    
    [self performRequest];
    
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
    NSFetchedResultsController *controller = [super fetchedResultsController];
    
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
//    NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"SELF.text contains[c] %@", self.text];
//    fetchRequest.predicate = tagPredicate;
//    NSArray *tags = [controller.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
//    
//    NSMutableArray *predicates = [NSMutableArray array];
//    
//    for (Tag *tag in tags) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.tags contains %@", tag];
//        [predicates addObject:predicate];
//    }
//    
//    if ([predicates count] > 0) {
//        NSCompoundPredicate *compoundPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:predicates];
//        controller.fetchRequest.predicate = compoundPredicate;
//    }
//    
//    [controller performFetch:NULL];
    
    return controller;
}

- (void)performRequest {
    [Media
     getMediaWithSearchText:self.text
     resultBlock:^(NSArray *media, id pageManager, BOOL *requestNextPage) {
         self.pageManager = pageManager;
    }];
}

- (void)getNextPageOfResults {
    if (self.requestingNextPage) {
        return;
    }
    
    self.requestingNextPage = YES;
    
    MMAppDelegate *appDelegate = (MMAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    if (self.pageManager) {
        [self.pageManager
         startNextPageRequestWithContext:context
         domain:self
         resultBlock:^(NSArray *objects, id pageManager, BOOL *requestNextPage) {
             self.pageManager = pageManager;
             self.requestingNextPage = NO;
         }
         failureBlock:^(NSError *error) {
             self.requestingNextPage = NO;
         }];
    }
}

@end
