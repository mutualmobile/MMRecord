//
//  ADNUserSearchViewController.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 3/23/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "ADNUserSearchViewController.h"

#import "ADNUserManager.h"
#import "ADNUserPostsViewController.h"
#import "MMDataManager.h"
#import "User.h"
#import "UserCell.h"

@interface ADNUserSearchViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSArray *users;

@property (nonatomic, strong) ADNUserManager *userManager;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation ADNUserSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserCell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
}

- (IBAction)closeSearch:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private Methods

- (void)searchForUsersWithText:(NSString *)text {
    [self.searchBar resignFirstResponder];
    
    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
    
    [User cancelRequestsWithDomain:self];
    
    [User
     searchForUsersWithName:text
     context:context
     domain:self
     resultBlock:^(NSArray *users, BOOL requestComplete) {
         self.users = users;
         [self.tableView reloadData];
     }
     failureBlock:^(NSError *error) {
         
     }];
}

- (User *)userForIndexPath:(NSIndexPath *)indexPath {
    return [self.users objectAtIndex:indexPath.row];
}


#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchForUsersWithText:searchBar.text];
}


#pragma mark - UITableViewDelegate and DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
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