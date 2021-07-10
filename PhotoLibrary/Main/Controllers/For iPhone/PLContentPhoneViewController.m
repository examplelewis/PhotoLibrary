//
//  PLContentPhoneViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/30.
//

#import "PLContentPhoneViewController.h"

#import <MJRefresh.h>

#import "PLContentCollectionViewCell.h"
#import "PLContentCollectionHeaderReusableView.h"
#import "PLPhotoPhoneViewController.h"
#import "PLContentViewModel.h"

@interface PLContentPhoneViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) CGSize folderItemSize;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) PLContentViewModel *viewModel;

@property (nonatomic, assign) BOOL selectingMode;

@property (nonatomic, assign) BOOL refreshFilesWhenViewDidAppear; // 当前Controller被展示时，是否刷新数据。只有跳转到PLPhotoViewController后返回才需要刷新

@end

@implementation PLContentPhoneViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTitle];
    [self setupUIAndData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.viewModel.foldersCount == 0 && self.viewModel.filesCount == 0) {
        [self.collectionView.mj_header beginRefreshing];
    } else {
        if (self.refreshFilesWhenViewDidAppear) {
            self.refreshFilesWhenViewDidAppear = NO;
            
            [self refreshFiles];
        }
    }
}

#pragma mark - Configure
- (void)setupTitle {
    if (self.viewModel.foldersCount + self.viewModel.filesCount == 0) {
        self.title = self.folderPath.lastPathComponent;
    } else {
        self.title = [NSString stringWithFormat:@"%@(%ld)", self.folderPath.lastPathComponent, self.viewModel.foldersCount + self.viewModel.filesCount];
    }
}
- (void)setupUIAndData {
    // Data
    self.selectingMode = NO;
    
    // UI
    [self setupCollectionViewFlowLayout];
    [self setupCollectionView];
}
- (void)setupCollectionViewFlowLayout {
    self.flowLayout = [UICollectionViewFlowLayout new];
    self.flowLayout.minimumInteritemSpacing = PLRowColumnSpacing;
    self.flowLayout.minimumLineSpacing = PLRowColumnSpacing;
    
    NSInteger columnsPerRow = 3;
    CGFloat itemWidth = (kScreenWidth - (columnsPerRow + 1) * PLRowColumnSpacing) / columnsPerRow;
    self.flowLayout.itemSize = CGSizeMake(floorf(itemWidth), floorf(itemWidth));
    
    self.flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 44);
    self.flowLayout.sectionInset = UIEdgeInsetsMake(PLRowColumnSpacing, PLRowColumnSpacing, PLRowColumnSpacing, PLRowColumnSpacing); // 设置每个分区的 上左下右 的内边距
    self.flowLayout.sectionFootersPinToVisibleBounds = YES; // 设置分区的头视图和尾视图 是否始终固定在屏幕上边和下边
    
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    // Folder Item Size
    NSInteger folderColumnsPerRow = 3;
    CGFloat folderItemWidth = (kScreenWidth - (folderColumnsPerRow + 1) * PLRowColumnSpacing) / folderColumnsPerRow;
    self.folderItemSize = CGSizeMake(floorf(folderItemWidth), floorf(folderItemWidth));
}
- (void)setupCollectionView {
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
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
    [self.viewModel refreshItems];
    
    [self setupTitle];
    
    [self.collectionView reloadData];
    
    [self.collectionView.mj_header endRefreshing];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.viewModel.bothFoldersAndFiles ? 2 : 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.viewModel.bothFoldersAndFiles) {
        if (section == 0) {
            return self.viewModel.foldersCount;
        } else {
            return self.viewModel.filesCount;
        }
    } else {
        if (self.viewModel.foldersCount > 0) {
            return self.viewModel.foldersCount;
        } else if (self.viewModel.filesCount > 0) {
            return self.viewModel.filesCount;
        } else {
            return 0;
        }
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLContentCollectionViewCell *cell = (PLContentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PLContentCell" forIndexPath:indexPath];
    
    if (self.viewModel.bothFoldersAndFiles) {
        if (indexPath.section == 0) {
            cell.model = [self.viewModel folderModelAtIndex:indexPath.row];
        } else {
            cell.model = [self.viewModel fileModelAtIndex:indexPath.row];
        }
    } else {
        if (self.viewModel.foldersCount > 0) {
            cell.model = [self.viewModel folderModelAtIndex:indexPath.row];
        } else if (self.viewModel.filesCount > 0) {
            cell.model = [self.viewModel fileModelAtIndex:indexPath.row];
        } else {
            return [UICollectionViewCell new];
        }
    }
    
    if (!self.selectingMode) {
        cell.cellType = PLContentCollectionViewCellTypeNormal;
    } else {
        cell.cellType = [self.viewModel isSelectedForModel:cell.model] ? PLContentCollectionViewCellTypeEditSelect : PLContentCollectionViewCellTypeEdit;
    }

    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        PLContentCollectionHeaderReusableView *headerView = (PLContentCollectionHeaderReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PLContentHeaderView" forIndexPath:indexPath];
        if (self.viewModel.bothFoldersAndFiles) {
            if (indexPath.section == 0) {
                headerView.header = @"文件夹";
            } else {
                headerView.header = @"文件";
            }
        } else {
            if (self.viewModel.foldersCount > 0) {
                headerView.header = @"文件夹";
            } else if (self.viewModel.filesCount > 0) {
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
    if (cell.model.isFolder) {
        PLNavigationType type = [PLNavigationManager navigateToContentAtFolderPath:[self.viewModel folderModelAtIndex:indexPath.row].itemPath];
        self.refreshFilesWhenViewDidAppear = type == PLNavigationTypePhoto; // 跳转到 PLPhotoViewController 后，返回需要刷新文件
    } else {
        PLNavigationType type = [PLNavigationManager navigateToPhotoAtFolderPath:self.folderPath index:indexPath.row];
        self.refreshFilesWhenViewDidAppear = type == PLNavigationTypePhoto; // 跳转到 PLPhotoViewController 后，返回需要刷新文件
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.bothFoldersAndFiles && indexPath.section == 0) {
        return self.folderItemSize;
    }
    if (!self.viewModel.bothFoldersAndFiles && self.viewModel.filesCount == 0) {
        return self.folderItemSize;
    }
    
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
    if (self.viewModel.foldersCount == 0 && self.viewModel.filesCount == 0) {
        return CGSizeMake(kScreenWidth, 0);
    } else {
        return self.flowLayout.headerReferenceSize;
    }
}

#pragma mark - Getter
- (PLContentViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[PLContentViewModel alloc] initWithFolderPath:self.folderPath];
    }
    
    return _viewModel;
}

@end
