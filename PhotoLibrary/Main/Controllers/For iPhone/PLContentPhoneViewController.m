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

@interface PLContentPhoneViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) CGSize folderItemSize;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray<NSString *> *folders;
@property (nonatomic, copy) NSArray<NSString *> *files;

@property (nonatomic, assign) BOOL bothFoldersAndFiles;
@property (nonatomic, assign) PLContentFolderType folderType;
@property (nonatomic, assign) PLContentCollectionViewCellType cellType;

@property (nonatomic, strong) NSMutableArray<NSString *> *selects;
@property (nonatomic, assign) BOOL opreatingFiles;

@property(nonatomic, assign) BOOL refreshFilesWhenViewDidAppear; // 当前Controller被展示时，是否刷新数据。只有跳转到PLPhotoViewController后返回才需要刷新

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
    
    if (self.folders.count == 0 && self.files.count == 0) {
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
    if (self.folders.count + self.files.count == 0) {
        self.title = self.folderPath.lastPathComponent;
    } else {
        self.title = [NSString stringWithFormat:@"%@(%ld)", self.folderPath.lastPathComponent, self.folders.count + self.files.count];
    }
}
- (void)setupUIAndData {
    // Data
    self.folders = @[];
    self.files = @[];
    self.bothFoldersAndFiles = NO;
    
    self.cellType = PLContentCollectionViewCellTypeNormal;
    
    self.selects = [NSMutableArray array];
    
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
    self.folders = [GYFileManager folderPathsInFolder:self.folderPath];
    self.folders = [self.folders sortedArrayUsingDescriptors:@[[PLUniversalManager fileAscendingSortDescriptorWithKey:@"self"]]];
    NSArray *imageFiles = [GYFileManager filePathsInFolder:self.folderPath extensions:[GYSettingManager defaultManager].mimeImageTypes];
    if (imageFiles.count > 0) {
        self.files = @[@"DefaultImage"];
    }
    self.bothFoldersAndFiles = (self.folders.count > 0 && self.files.count > 0);
    
    [self setupTitle];
    
    [self.collectionView.mj_header endRefreshing];
    
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
    
    if (self.cellType == PLContentCollectionViewCellTypeNormal) {
        cell.cellType = PLContentCollectionViewCellTypeNormal;
    } else {
        BOOL selected = [self.selects indexOfObject:cell.contentPath] != NSNotFound;
        cell.cellType = selected ? PLContentCollectionViewCellTypeEditSelect : PLContentCollectionViewCellTypeEdit;
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
        NSString *nextFolderPath = self.folders[indexPath.row];
        if ([GYFileManager folderPathsInFolder:nextFolderPath].count > 0) {
            PLContentPhoneViewController *vc = [[PLContentPhoneViewController alloc] initWithNibName:@"PLContentPhoneViewController" bundle:nil];
            vc.folderPath = nextFolderPath;
            vc.folderType = self.folderType;
            
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            PLPhotoPhoneViewController *vc = [[PLPhotoPhoneViewController alloc] initWithNibName:@"PLPhotoPhoneViewController" bundle:nil];
            vc.folderPath = nextFolderPath;

            [self.navigationController pushViewController:vc animated:YES];

            self.refreshFilesWhenViewDidAppear = YES; // 跳转到 PLPhotoViewController 后，返回需要刷新文件
        }
    } else {
        // 废纸篓目录下的文件，暂时不展示图片
        if (self.folderType != PLContentFolderTypeTrash) {
            PLPhotoPhoneViewController *vc = [[PLPhotoPhoneViewController alloc] initWithNibName:@"PLPhotoPhoneViewController" bundle:nil];
            vc.folderPath = self.folders[indexPath.row];

            [self.navigationController pushViewController:vc animated:YES];

            self.refreshFilesWhenViewDidAppear = YES; // 跳转到 PLPhotoViewController 后，返回需要刷新文件
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.bothFoldersAndFiles && indexPath.section == 0) {
        return self.folderItemSize;
    }
    if (!self.bothFoldersAndFiles && self.files.count == 0) {
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
    if (self.files.count == 0 && self.folders.count == 0) {
        return CGSizeMake(kScreenWidth, 0);
    } else {
        return self.flowLayout.headerReferenceSize;
    }
}

#pragma mark - Setter
- (void)setFolderPath:(NSString *)folderPath  {
    _folderPath = folderPath.copy;
    
    self.folderType = [folderPath isEqualToString:[GYSettingManager defaultManager].trashFolderPath] ? PLContentFolderTypeTrash : PLContentFolderTypeNormal;
}

@end
