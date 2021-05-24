//
//  PLContentViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import "PLContentViewController.h"

#import <MJRefresh.h>
#import <StepSlider.h>

#import "PLContentCollectionViewCell.h"
#import "PLContentCollectionHeaderReusableView.h"

@interface PLContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIBarButtonItem *editBBI;
@property (nonatomic, strong) UIBarButtonItem *trashBBI;
@property (nonatomic, strong) UIBarButtonItem *sliderBBI;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray<NSString *> *folders;
@property (nonatomic, strong) NSArray<NSString *> *files;

@property (nonatomic, assign) BOOL bothFoldersAndFiles;

@end

@implementation PLContentViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.folderPath.lastPathComponent;
    
    [self setupNotifications];
    [self setupUIAndData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.folders.count == 0 && self.files.count == 0) {
        [self.collectionView.mj_header beginRefreshing];
    }
}

#pragma mark - Configure
- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(columnPerRowSliderValueChanged:) name:PLColumnPerRowSliderValueChanged object:nil];
}
- (void)setupUIAndData {
    // Data
    self.folders = @[];
    self.files = @[];
    self.bothFoldersAndFiles = NO;
    
    // UI
    [self setupNavigationBar];
    [self setupCollectionViewFlowLayout];
    [self setupCollectionView];
}
- (void)setupNavigationBar {
    self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemDidPress:)];
    self.editBBI.tag = 101;
    
    self.trashBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashBarButtonItemDidPress:)];
    self.trashBBI.enabled = NO;
    
    UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    StepSlider *slider = [[StepSlider alloc] initWithFrame:CGRectMake(0, 9, 300, 26)];
    slider.tag = 100;
    slider.maxCount = 6;
    slider.index = [PLUniversalManager defaultManager].columnsPerRow - 4;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [sliderView addSubview:slider];
    self.sliderBBI = [[UIBarButtonItem alloc] initWithCustomView:sliderView];
    
    self.navigationItem.rightBarButtonItems = @[self.editBBI, self.trashBBI, self.sliderBBI];
}
- (void)setupCollectionViewFlowLayout {
    self.flowLayout = [UICollectionViewFlowLayout new];
    self.flowLayout.minimumInteritemSpacing = [PLUniversalManager defaultManager].rowColumnSpacing;
    self.flowLayout.minimumLineSpacing = [PLUniversalManager defaultManager].rowColumnSpacing;
    
    CGFloat screenWidth = MAX(kScreenWidth, kScreenHeight);
    CGFloat itemWidth = (screenWidth - ([PLUniversalManager defaultManager].columnsPerRow + 1) * [PLUniversalManager defaultManager].rowColumnSpacing) / [PLUniversalManager defaultManager].columnsPerRow;
    self.flowLayout.itemSize = CGSizeMake(floorf(itemWidth), floorf(itemWidth));
    
    self.flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 44);
    self.flowLayout.sectionInset = [PLUniversalManager defaultManager].flowLayoutSectionInset; // 设置每个分区的 上左下右 的内边距
    self.flowLayout.sectionFootersPinToVisibleBounds = YES; // 设置分区的头视图和尾视图 是否始终固定在屏幕上边和下边
    
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
}
- (void)setupCollectionView {
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PLContentCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"PLContentCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PLContentCollectionHeaderReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PLContentHeaderView"];
    
    @weakify(self);
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self refreshFiles];
    }];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
}

#pragma mark - Refresh
- (void)refreshFiles {
    [self.collectionView.mj_header endRefreshing];
    
    self.folders = [GYFileManager folderPathsInFolder:self.folderPath];
    self.folders = [self.folders sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    self.files = [GYFileManager filePathsInFolder:self.folderPath extensions:[GYSettingManager defaultManager].mimeImageTypes];
    self.files = [self.files sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    self.bothFoldersAndFiles = (self.folders.count > 0 && self.files.count > 0);
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.bothFoldersAndFiles ? 2 : 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.bothFoldersAndFiles) {
        if (section == 0) {
            return self.folders.count;
        } else {
            return self.files.count;
        }
    } else {
        if (self.folders.count > 0) {
            return self.folders.count;
        } else if (self.files.count > 0) {
            return self.files.count;
        } else {
            return 0;
        }
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLContentCollectionViewCell *cell = (PLContentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PLContentCell" forIndexPath:indexPath];
    
    if (self.bothFoldersAndFiles) {
        if (indexPath.section == 0) {
            cell.contentPath = self.folders[indexPath.row];
        } else {
            cell.contentPath = self.files[indexPath.row];
        }
    } else {
        if (self.folders.count > 0) {
            cell.contentPath = self.folders[indexPath.row];
        } else if (self.files.count > 0) {
            cell.contentPath = self.files[indexPath.row];
        } else {
            return [UICollectionViewCell new];
        }
    }

    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        PLContentCollectionHeaderReusableView *headerView = (PLContentCollectionHeaderReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PLContentHeaderView" forIndexPath:indexPath];
        if (self.bothFoldersAndFiles) {
            if (indexPath.section == 0) {
                headerView.header = @"文件夹";
            } else {
                headerView.header = @"文件";
            }
        } else {
            if (self.folders.count > 0) {
                headerView.header = @"文件夹";
            } else if (self.files.count > 0) {
                headerView.header = @"文件";
            } else {
                headerView.header = @"未知错误";
            }
        }
        
        return headerView;
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    PLContentCollectionViewCell *cell = (PLContentCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isFolder) {
        PLContentViewController *vc = [[PLContentViewController alloc] initWithNibName:@"PLContentViewController" bundle:nil];
        vc.folderPath = self.folders[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.flowLayout.itemSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.flowLayout.sectionInset;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.flowLayout.minimumLineSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.flowLayout.minimumInteritemSpacing;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return self.flowLayout.headerReferenceSize;
}

#pragma mark - Actions
- (void)editBarButtonItemDidPress:(UIBarButtonItem *)sender {
    if (sender.tag == 101) {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editBarButtonItemDidPress:)];
        self.editBBI.tag = 102;
        self.trashBBI.enabled = YES;
        self.navigationItem.rightBarButtonItems = @[self.editBBI, self.trashBBI];
        
    } else {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemDidPress:)];
        self.editBBI.tag = 101;
        self.trashBBI.enabled = NO;
        self.navigationItem.rightBarButtonItems = @[self.editBBI, self.trashBBI];
        
    }
}
- (void)trashBarButtonItemDidPress:(UIBarButtonItem *)sender {
    
}
- (void)sliderValueChanged:(StepSlider *)sender {
    [PLUniversalManager defaultManager].columnsPerRow = sender.index + 4;
    
    // 更新flowLayout后刷新collectionView
    [self setupCollectionViewFlowLayout];
    [self.collectionView reloadData];
}

#pragma mark - Notifications
- (void)columnPerRowSliderValueChanged:(NSNotification *)sender {
    UIView *sliderView = self.sliderBBI.customView;
    StepSlider *slider = (StepSlider *)[sliderView viewWithTag:100];
    slider.index = [PLUniversalManager defaultManager].columnsPerRow - 4;
    
    // 更新flowLayout后刷新collectionView
    [self setupCollectionViewFlowLayout];
    [self.collectionView reloadData];
}

@end
