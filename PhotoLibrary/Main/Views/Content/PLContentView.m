//
//  PLContentView.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/3.
//

#import "PLContentView.h"

#import <MJRefresh.h>

#import "PLContentCollectionViewCell.h"
#import "PLContentCollectionHeaderReusableView.h"

@interface PLContentView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PLContentViewModelDelegate>

@property (nonatomic, copy) NSString *folderPath;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) CGSize folderItemSize;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) BOOL refreshFilesWhenViewDidAppear; // 当前Controller被展示时，是否刷新数据。只有跳转到PLPhotoViewController后返回才需要刷新

@end

@implementation PLContentView

@synthesize viewModel = _viewModel;

#pragma mark - Lifecycle
- (instancetype)initWithFolderPath:(NSString *)folderPath {
    self = [super init];
    if (self) {
        self.folderPath = folderPath.copy;
        
        [self setupNotifications];
        [self setupUIAndData];
    }
    
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 退出页面时清除内存中的图片
    [self.viewModel cleanSDWebImageCache];
}

#pragma mark - Configure
- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(columnPerRowSliderValueChanged:) name:PLColumnPerRowSliderValueChanged object:nil];
}
- (void)setupUIAndData {
    // Data
    
    // UI
    [self setupCollectionViewFlowLayout];
    [self setupCollectionView];
}
- (void)setupCollectionViewFlowLayout {
    self.flowLayout = [UICollectionViewFlowLayout new];
    self.flowLayout.minimumInteritemSpacing = [PLUniversalManager defaultManager].rowColumnSpacing;
    self.flowLayout.minimumLineSpacing = [PLUniversalManager defaultManager].rowColumnSpacing;
    
    CGFloat itemWidth = (screenWidth - ([PLUniversalManager defaultManager].columnsPerRow + 1) * [PLUniversalManager defaultManager].rowColumnSpacing) / [PLUniversalManager defaultManager].columnsPerRow;
    self.flowLayout.itemSize = CGSizeMake(floorf(itemWidth), floorf(itemWidth));
    
    self.flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 44);
    self.flowLayout.sectionInset = [PLUniversalManager defaultManager].flowLayoutSectionInset; // 设置每个分区的 上左下右 的内边距
    self.flowLayout.sectionFootersPinToVisibleBounds = YES; // 设置分区的头视图和尾视图 是否始终固定在屏幕上边和下边
    
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    // Folder Item Size
    CGFloat folderItemWidth = (screenWidth - (PLFolderColumnsPerRow + 1) * [PLUniversalManager defaultManager].rowColumnSpacing) / PLFolderColumnsPerRow;
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
        [self.viewModel refreshItems];
    }];
    
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self);
    }];
}

#pragma mark - Refresh
- (void)refreshWhenViewDidAppear {
    if (self.viewModel.foldersCount == 0 && self.viewModel.filesCount == 0) {
        [self.collectionView.mj_header beginRefreshing];
    } else {
        if (self.refreshFilesWhenViewDidAppear) {
            self.refreshFilesWhenViewDidAppear = NO;
            
            [self.viewModel refreshItems];
        }
    }
}
- (void)reloadCollectionView {
    [self.collectionView reloadData];
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
    if (cell.cellType == PLContentCollectionViewCellTypeNormal) {
        if (cell.model.isFolder) {
            PLNavigationType type = [PLNavigationManager navigateToContentAtFolderPath:[self.viewModel folderModelAtIndex:indexPath.row].itemPath];
            self.refreshFilesWhenViewDidAppear = type == PLNavigationTypePhoto; // 跳转到 PLPhotoViewController 后，返回需要刷新文件
        } else {
            if (self.viewModel.folderType == PLContentFolderTypeNormal) {
                PLNavigationType type = [PLNavigationManager navigateToPhotoAtFolderPath:self.folderPath index:indexPath.row];
                self.refreshFilesWhenViewDidAppear = type == PLNavigationTypePhoto; // 跳转到 PLPhotoViewController 后，返回需要刷新文件
            } else if (self.viewModel.folderType == PLContentFolderTypeEditWorks) {
                
            }
        }
    } else {
        if (self.viewModel.shiftMode) {
            [self.viewModel shiftModeTapIndexPath:indexPath withModel:cell.model];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else {
            if ([self.viewModel isSelectedForModel:cell.model]) {
                [self.viewModel removeSelectItem:cell.model];
            } else {
                [self.viewModel addSelectItem:cell.model];
            }
            
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(contentView:didSelectItemAtIndexPath:)]) {
        [self.delegate contentView:self didSelectItemAtIndexPath:indexPath];
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
    if (self.viewModel.filesCount == 0 && self.viewModel.foldersCount == 0) {
        return CGSizeMake(kScreenWidth, 0);
    } else {
        return self.flowLayout.headerReferenceSize;
    }
}

#pragma mark - PLContentViewModelDelegate
- (void)viewModelDidFinishOperatingFiles {
    @weakify(self);
    dispatch_main_async_safe(^{
        @strongify(self);
        
        [self.collectionView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(contentViewModelDidFinishOperatingFiles:)]) {
            [self.delegate contentViewModelDidFinishOperatingFiles:self];
        }
    });
}
- (void)viewModelDidFinishRefreshingItems {
    @weakify(self);
    dispatch_main_async_safe(^{
        @strongify(self);
        
        if ([self.delegate respondsToSelector:@selector(didFinishRefreshingItemsInContentView:)]) {
            [self.delegate didFinishRefreshingItemsInContentView:self];
        }
        
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
    });
}
- (void)viewModelDidSwitchShiftMode {
    [self.collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(contentViewModelDidSwitchShiftMode:)]) {
        [self.delegate contentViewModelDidSwitchShiftMode:self];
    }
}

#pragma mark - Notifications
- (void)columnPerRowSliderValueChanged:(NSNotification *)sender {
    // 更新flowLayout后刷新collectionView
    [self setupCollectionViewFlowLayout];
    [self.collectionView reloadData];
}

#pragma mark - Getter
- (PLContentViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[PLContentViewModel alloc] initWithFolderPath:self.folderPath];
        _viewModel.delegate = self;
    }
    
    return _viewModel;
}

@end
