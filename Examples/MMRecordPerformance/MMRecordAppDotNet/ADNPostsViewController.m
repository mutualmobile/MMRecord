//
//  ADNPostsViewController.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "ADNPostsViewController.h"

#import "MMDataManager.h"
#import "Post.h"
#import "PostCell.h"

@interface ADNPostsViewController ()

@property (nonatomic, copy) NSArray *posts;

@end

@implementation ADNPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PostCell"];
        
    [self getPosts];
}


#pragma mark - Posts Request Methods

- (void)getPosts {
    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];

    [Post
     getStreamPostsWithContext:context
     domain:self
     resultBlock:^(NSArray *posts) {
         [self populatePostsTableWithPosts:posts];
         [Post
          getStreamPostsWithContext:context
          domain:self
          resultBlock:^(NSArray *posts) {
              [self populatePostsTableWithPosts:posts];
          }
          failureBlock:^(NSError *error) {
              [self endRequestingPosts];
          }];
     }
     failureBlock:^(NSError *error) {
         [self endRequestingPosts];
     }];
}


#pragma mark - UITableViewDelegate and DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.posts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PostCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = (PostCell *)[tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Post *post = [self postForIndexPath:indexPath];
    
    [cell populateWithPost:post];
    
    return cell;
}


#pragma mark - Utility Methods

- (Post *)postForIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    return [self.posts objectAtIndex:row];
}

- (void)populatePostsTableWithPosts:(NSArray *)posts {
    self.posts = posts;
    [self.tableView reloadData];
}

- (void)endRequestingPosts {
    [self.refreshControl endRefreshing];
}

@end
