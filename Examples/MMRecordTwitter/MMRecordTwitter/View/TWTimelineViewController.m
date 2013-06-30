//
//  MMViewController.m
//  MMRecordTwitter
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "TWTimelineViewController.h"

#import "Tweet.h"
#import "TweetCell.h"
#import "Tweet+MMRecord.h"
#import "MMAppDelegate.h"

@interface TWTimelineViewController ()

@property (nonatomic, copy) NSArray *tweets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TWTimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Timeline";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadTable:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:self.refreshControl];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"TweetCell"];
    
    [self getLatestTweets];
}

#pragma mark - Private

- (NSManagedObjectContext *)managedObjectContext {
    return [(MMAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)getLatestTweets {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    MMRecordOptions *options = [Tweet defaultOptions];
    options.deleteOrphanedRecordBlock = ^(MMRecord *orphan,
                                          NSArray *populatedRecords,
                                          id responseObject,
                                          BOOL *stop) {
        NSLog(@"%@%@%@", orphan, populatedRecords, responseObject);
        return NO;
    };
    [Tweet setOptions:options];
    
    [Tweet
     timelineTweetsWithContext:context
     domain:self
     resultBlock:^(NSArray *tweets, MMServerPageManager *pageManager, BOOL *requestNextPage) {
         self.tweets = tweets;
         [self.tableView reloadData];
         [self.refreshControl endRefreshing];
     }
     failureBlock:^(NSError *error) {
         
     }];
}

- (void)reloadTable:(id)sender {
    [self getLatestTweets];
}


#pragma mark - UITableViewDelegate and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweets count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    
    Tweet *tweet = [self.tweets objectAtIndex:indexPath.row];
    
    [cell populateWithTweet:tweet];
    
    return cell;
}

@end
