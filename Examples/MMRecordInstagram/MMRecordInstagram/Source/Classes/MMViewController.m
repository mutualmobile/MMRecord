#import "MMViewController.h"

#import "Media.h"
#import "Media+MMRecord.h"
#import "MediaCell.h"
#import "MMSearchManager.h"

@interface MMViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@property (nonatomic, strong) MMSearchManager *searchManager;

@end

@implementation MMViewController

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor orangeColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureCollectionView];
    [self configureSearch];
}


#pragma mark - UITableViewDelegate and DataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.resultsController fetchedObjects] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
    
    Media *media = [self.resultsController objectAtIndexPath:indexPath];
    
    [cell populateWithMedia:media];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(95, 95);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.row >= (numItems - 3)) {
            [self.searchManager getNextPageOfResults];
        }
    }
}


#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}


#pragma mark - Private Methods

- (void)configureCollectionView {
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MediaCell" bundle:nil] forCellWithReuseIdentifier:@"MediaCell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.collectionView];
}

- (void)configureSearch {
    self.searchManager = [[MMSearchManager alloc] initWithSearchString:@"snow"];
    self.resultsController = [self.searchManager fetchedResultsController];
    self.resultsController.delegate = self;
}

@end
