//
//  PLContentViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import "PLContentViewController.h"

#import <MJRefresh.h>

#import "PLContentCollectionViewCell.h"
#import "PLContentCollectionHeaderReusableView.h"

static CGFloat const kSpacing = 10.0f;
static NSInteger const kColumnsPerRow = 7;

@interface PLContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *editBBI;
@property (nonatomic, strong) UIBarButtonItem *trashBBI;

@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) NSInteger columnsPerRow;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<SMBFile *> *contents;
@property (nonatomic, strong) NSMutableArray<SMBFile *> *folders;
@property (nonatomic, strong) NSMutableArray<SMBFile *> *files;

@property (nonatomic, assign) BOOL bothFoldersAndFiles;

@end

@implementation PLContentViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.file.name;
    
    [self setupUIAndData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.contents.count == 0) {
        [self.collectionView.mj_header beginRefreshing];
    }
}


#pragma mark - Configure
- (void)setupUIAndData {
    // Data
    self.spacing = kSpacing;
    self.columnsPerRow = kColumnsPerRow;
    self.contents = [NSMutableArray array];
    self.folders = [NSMutableArray array];
    self.files = [NSMutableArray array];
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
    
    self.navigationItem.rightBarButtonItems = @[self.editBBI, self.trashBBI];
}
- (void)setupCollectionViewFlowLayout {
    self.flowLayout = [UICollectionViewFlowLayout new];
    self.flowLayout.minimumInteritemSpacing = self.spacing;
    self.flowLayout.minimumLineSpacing = self.spacing;
    
    CGFloat screenWidth = MAX(kScreenWidth, kScreenHeight);
    CGFloat itemWidth = (screenWidth - (self.columnsPerRow + 1) * self.spacing) / self.columnsPerRow;
    self.flowLayout.itemSize = CGSizeMake(floorf(itemWidth), floorf(itemWidth));
    
    self.flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 44);
    self.flowLayout.sectionInset = UIEdgeInsetsMake(self.spacing, self.spacing, self.spacing, self.spacing); // 设置每个分区的 上左下右 的内边距
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
    @weakify(self);
    [self.file listFilesUsingFilter:^BOOL(SMBFile * _Nonnull file) {
        BOOL isHiddenFile = [file.name hasPrefix:@"."];
        BOOL isImageFile = [[GYSettingManager defaultManager].mimeImageTypes indexOfObject:file.name.pathExtension.lowercaseString] != NSNotFound;
        BOOL isFolder = file.isDirectory;
        
        return !isHiddenFile && (isFolder || isImageFile);
    } completion:^(NSArray<SMBFile *> * _Nullable files, NSError * _Nullable error) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"刷新文件列表出现错误: %@", error.localizedDescription]];
        } else {
            if (files && files.count > 0) {
                [self.contents removeAllObjects];
                [self.folders removeAllObjects];
                [self.files removeAllObjects];
                
                [self.contents addObjectsFromArray:files];
                [self.folders addObjectsFromArray:[files bk_select:^BOOL(SMBFile *obj) {
                    return obj.isDirectory;
                }]];
                [self.files addObjectsFromArray:[files bk_select:^BOOL(SMBFile *obj) {
                    return !obj.isDirectory;
                }]];
//                [self.files removeFirstObject];
//                [self.files removeFirstObject];
                
                self.bothFoldersAndFiles = (self.folders.count > 0 && self.files.count > 0);
                
                [self.collectionView reloadData];
            } else {
                [SVProgressHUD showErrorWithStatus:@"没有获取到新文件"];
            }
        }
    }];
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
            cell.file = self.folders[indexPath.row];
        } else {
            cell.file = self.files[indexPath.row];
        }
    } else {
        if (self.folders.count > 0) {
            cell.file = self.folders[indexPath.row];
        } else if (self.files.count > 0) {
            cell.file = self.files[indexPath.row];
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
}

#pragma mark - Action
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

@end
