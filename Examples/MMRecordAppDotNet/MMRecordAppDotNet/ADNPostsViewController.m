//
//  ADNPostsViewController.m
//  MMRecordAppDotNet
//
//  Created by Conrad Stoll on 11/20/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "ADNPostsViewController.h"

#import "ADNPageManager.h"
#import "MMDataManager.h"
#import "Post.h"
#import "PostCell.h"
#import "ADNPostManager.h"
#import "Counts.h"

#import "FBTweakViewController.h"
#import "FBTweakStore.h"

@interface ADNPostsViewController () <FBTweakViewControllerDelegate>

@property (nonatomic, strong) ADNPostManager *postManager;
@property (nonatomic, copy) NSArray *posts;

@end

@implementation ADNPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(getMoreRecentPosts)
                  forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:self.refreshControl];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"PostCell"];
        
    [self getPosts];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Tweaks" style:UIBarButtonItemStyleBordered target:self action:@selector(showTweaks)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)showTweaks {
    FBTweakViewController *viewController = [[FBTweakViewController alloc] initWithStore:[FBTweakStore sharedInstance]];
    viewController.tweaksDelegate = self;
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)tweakViewControllerPressedDone:(FBTweakViewController *)tweakViewController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Posts Request Methods

- (void)getPosts {
    NSManagedObjectContext *context = [[MMDataManager sharedDataManager] managedObjectContext];
    
    MMRecordOptions *options = [Post defaultOptions];
    
    options.entityPrimaryKeyInjectionBlock = ^id(NSEntityDescription *entity,
                                                 NSDictionary *dictionary,
                                                 MMRecordProtoRecord *parentProtoRecord){
        if ([[entity name] isEqualToString:@"CoverImage"]) {
            if ([[parentProtoRecord.entity name] isEqualToString:@"User"]) {
                if (parentProtoRecord.primaryKeyValue != nil) {
                    return parentProtoRecord.primaryKeyValue;
                }
            }
        }
        
        return nil;
    };
    
    options.recordPrePopulationBlock = ^(MMRecordProtoRecord *protoRecord){
        if (protoRecord.primaryKeyValue) {
            NSLog(@"Entity: %@ Value Key: %@", protoRecord.entity.name, protoRecord.primaryKeyValue);
        } else {
            NSLog(@"Entity: %@ Relationship Key: %@", protoRecord.entity.name, protoRecord.relationshipPrimaryKeyProto.primaryKeyValue);
        }
    };
    
    options.deleteOrphanedRecordBlock = ^BOOL(MMRecord *orphan,
                                              NSArray *populatedRecords,
                                              id responseObject,
                                              BOOL *stop) {
        if ([orphan isKindOfClass:[Counts class]]) {
            if ([(Counts *)orphan user] == nil) {
                return YES;
            }
        }
        
        return NO;
    };
    
    [Post setOptions:options];

    [Post
     getStreamPostsWithContext:context
     domain:self
     resultBlock:^(NSArray *posts, ADNPageManager *pageManager, BOOL *requestNextPage) {
         [self populatePostsTableWithPosts:posts];
         
         if (pageManager != nil) {
             self.postManager = [[ADNPostManager alloc] initWithPosts:posts pageManager:pageManager];
         }
     }
     failureBlock:^(NSError *error) {
         [self endRequestingPosts];
     }];
}

- (void)getPreviousPosts {
    [self.postManager getPreviousPosts:^(NSArray *posts) {
        [self populatePostsTableWithPosts:posts];
    }];
}

- (void)getMoreRecentPosts {
    if (self.postManager) {
        [self.postManager getMoreRecentPosts:^(NSArray *posts) {
            [self populatePostsTableWithPosts:posts];
            [self endRequestingPosts];
        }];
    } else {
        [self endRequestingPosts];
    }
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


#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    NSIndexPath *indexPath = [indexPaths lastObject];
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    
    if (indexPath.row >= (numberOfRows - 3)) {
        [self getPreviousPosts];
    }
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
