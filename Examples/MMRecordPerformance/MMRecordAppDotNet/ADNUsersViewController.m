//
//  ADNUsersViewController.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "ADNUsersViewController.h"

#import "ADNUserManager.h"
#import "ADNUserPostsViewController.h"
#import "UserCell.h"

@interface ADNUsersViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) ADNUserManager *userManager;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation ADNUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userManager = [[ADNUserManager alloc] init];
    self.resultsController = [self.userManager usersFetchedResultsController];
    self.resultsController.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserCell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
}


#pragma mark - Private Methods

- (User *)userForIndexPath:(NSIndexPath *)indexPath {
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
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    User *user = [self userForIndexPath:indexPath];
    
    [cell populateWithUser:user];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"userPosts" sender:self];
}


#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"userPosts"]) {
        User *user = [self userForIndexPath:self.selectedIndexPath];
        
        ADNUserPostsViewController *controller = [segue destinationViewController];
        controller.user = user;
    }
}


#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

@end
