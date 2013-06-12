//
//  ADNUserPostsViewController.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "ADNUserPostsViewController.h"

#import "ADNUserManager.h"
#import "AFNetworking.h"
#import "Counts.h"
#import "MMDataManager.h"
#import "Post.h"
#import "PostCell.h"
#import "User.h"

@interface ADNUserPostsViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *coverImageView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) ADNUserManager *userManager;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation ADNUserPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userManager = [[ADNUserManager alloc] init];
    self.resultsController = [self.userManager postsFetchedResultsControllerForUser:self.user];
    self.resultsController.delegate = self;
    
    [self.coverImageView setImageWithURL:self.user.coverURL placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    self.title = self.user.name;

    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PostCell"];
}


#pragma mark - Private Methods

- (Post *)postForIndexPath:(NSIndexPath *)indexPath {
    return [self.resultsController objectAtIndexPath:indexPath];
}



#pragma mark - UITableViewDelegate and DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.resultsController fetchedObjects] count];
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


#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}


@end
