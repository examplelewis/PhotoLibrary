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
#import "PLPhotoViewController.h"

@interface PLContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIBarButtonItem *editBBI;
@property (nonatomic, strong) UIBarButtonItem *trashBBI;
@property (nonatomic, strong) UIBarButtonItem *restoreBBI;
@property (nonatomic, strong) UIBarButtonItem *sliderBBI;
@property (nonatomic, strong) UIBarButtonItem *deleteBBI;
@property (nonatomic, strong) UIBarButtonItem *allBBI;
@property (nonatomic, strong) UIBarButtonItem *jumpSwitchBBI; // 是否直接跳转到图片页

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) CGSize folderItemSize;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray<NSString *> *folders;
@property (nonatomic, copy) NSArray<NSString *> *files;

@property (nonatomic, assign) BOOL bothFoldersAndFiles;

@property (nonatomic, assign) PLContentCollectionViewCellType cellType;

@property (nonatomic, strong) NSMutableArray<NSString *> *selects;
@property (nonatomic, assign) BOOL opreatingFiles;

@property(nonatomic, assign) BOOL refreshFilesWhenViewDidAppear; // 当前Controller被展示时，是否刷新数据。只有跳转到PLPhotoViewController后返回才需要刷新

@end

@implementation PLContentViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTitle];
    [self setupNotifications];
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
        if (self.cellType == PLContentCollectionViewCellTypeNormal) {
            self.title = [NSString stringWithFormat:@"%@(%ld)", self.folderPath.lastPathComponent, self.folders.count + self.files.count];
        } else {
            self.title = [NSString stringWithFormat:@"%@(%ld)(%ld)", self.folderPath.lastPathComponent, self.folders.count + self.files.count, self.selects.count];
        }
    }
}
- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(columnPerRowSliderValueChanged:) name:PLColumnPerRowSliderValueChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpSwitchValueChanged:) name:PLJumpSwitchValueChanged object:nil];
}
- (void)setupUIAndData {
    // Data
    self.folders = @[];
    self.files = @[];
    self.bothFoldersAndFiles = NO;
    
    self.cellType = PLContentCollectionViewCellTypeNormal;
    
    self.selects = [NSMutableArray array];
    
    // UI
    [self setupNavigationBar];
    [self setupCollectionViewFlowLayout];
    [self setupCollectionView];
}
- (void)setupNavigationBar {
    self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemDidPress:)];
    
    self.trashBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashBarButtonItemDidPress:)];
    self.trashBBI.enabled = NO;
    
    self.restoreBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(restoreBarButtonItemDidPress:)];
    self.restoreBBI.enabled = NO;
    
    self.deleteBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteBarButtonItemDidPress:)];
    self.deleteBBI.enabled = NO;
    
    self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
    self.allBBI.enabled = NO;
    
    UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    StepSlider *slider = [[StepSlider alloc] initWithFrame:CGRectMake(0, 9, 300, 26)];
    slider.tag = 100;
    slider.maxCount = 6;
    slider.index = [PLUniversalManager defaultManager].columnsPerRow - 4;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [sliderView addSubview:slider];
    self.sliderBBI = [[UIBarButtonItem alloc] initWithCustomView:sliderView];
    
    UIView *jumpSwitchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 47, 44)];
    UISwitch *jumpSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 6.5, 47, 31)];
    jumpSwitch.tag = 100;
    jumpSwitch.on = [PLUniversalManager defaultManager].directlyJumpPhoto;
    [jumpSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [jumpSwitchView addSubview:jumpSwitch];
    self.jumpSwitchBBI = [[UIBarButtonItem alloc] initWithCustomView:jumpSwitchView];
    
    [self setupNavigationBarItems];
}
- (void)setupNavigationBarItems {
    if (self.folderType == PLContentFolderTypeNormal) {
        self.navigationItem.rightBarButtonItems = @[self.editBBI, self.trashBBI, self.sliderBBI, self.allBBI, self.jumpSwitchBBI];
    } else {
        self.navigationItem.rightBarButtonItems = @[self.editBBI, self.restoreBBI, self.sliderBBI, self.allBBI, self.deleteBBI];
    }
}
- (void)setupAllBBI {
    BOOL selectAll = (self.selects.count == (self.folders.count + self.files.count)) && self.selects.count != 0; // 如果没有文件(夹)，就不算全选
    self.allBBI = [[UIBarButtonItem alloc] initWithTitle:selectAll ? @"取消全选" : @"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
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
    self.folders = [self.folders sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    self.files = [GYFileManager filePathsInFolder:self.folderPath extensions:[GYSettingManager defaultManager].mimeImageTypes];
    self.files = [self.files sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    self.bothFoldersAndFiles = (self.folders.count > 0 && self.files.count > 0);
    
    [self setupTitle];
    
    [self.collectionView.mj_header endRefreshing];
    
    [self.collectionView reloadData];
}
- (void)refreshAfterOperatingFiles {
    @weakify(self);
    
    NSMutableArray *folders = [self.folders mutableCopy];
    [folders removeObjectsInArray:self.selects];
    self.folders = folders.copy;
    
    NSMutableArray *files = [self.files mutableCopy];
    [files removeObjectsInArray:self.selects];
    self.files = files.copy;
    
    dispatch_main_async_safe(^{
        @strongify(self);
        [self.collectionView reloadData];
        
        [self setupTitle];
        [self setupNavigationBarItems];
    });
    
    self.opreatingFiles = NO;
    [self.selects removeAllObjects];
    
    dispatch_main_async_safe(^{
        @strongify(self);
        [self setupAllBBI];
        [self setupNavigationBarItems];
    });
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
    if (cell.cellType == PLContentCollectionViewCellTypeNormal) {
        if (cell.isFolder) {
            NSString *nextFolderPath = self.folders[indexPath.row];
            // 如果一个文件都没有，那么即便打开了directlyJumpPhoto开关，也跳转文件夹列表
            if ([PLUniversalManager defaultManager].directlyJumpPhoto && [GYFileManager filePathsInFolder:nextFolderPath].count > 0) {
                PLPhotoViewController *vc = [[PLPhotoViewController alloc] initWithNibName:@"PLPhotoViewController" bundle:nil];
                vc.folderPath = nextFolderPath;
                vc.currentIndex = 0;
                
                [self.navigationController pushViewController:vc animated:YES];
                
                self.refreshFilesWhenViewDidAppear = YES; // 跳转到 PLPhotoViewController 后，返回需要刷新文件
            } else {
                PLContentViewController *vc = [[PLContentViewController alloc] initWithNibName:@"PLContentViewController" bundle:nil];
                vc.folderPath = nextFolderPath;
                vc.folderType = self.folderType;
                
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else {
            // 废纸篓目录下的文件，暂时不展示图片
            if (self.folderType != PLContentFolderTypeTrash) {
                PLPhotoViewController *vc = [[PLPhotoViewController alloc] initWithNibName:@"PLPhotoViewController" bundle:nil];
                vc.folderPath = self.folderPath;
                vc.currentIndex = indexPath.row;
                
                [self.navigationController pushViewController:vc animated:YES];
                
                self.refreshFilesWhenViewDidAppear = YES; // 跳转到 PLPhotoViewController 后，返回需要刷新文件		
            }
        }
    } else {
        BOOL selected = [self.selects indexOfObject:cell.contentPath] != NSNotFound;
        if (selected) {
            [self.selects removeObject:cell.contentPath];
        } else {
            [self.selects addObject:cell.contentPath];
        }
        
        [self setupTitle];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        [self setupAllBBI];
        [self setupNavigationBarItems];
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

#pragma mark - Actions
- (void)editBarButtonItemDidPress:(UIBarButtonItem *)sender {
    if (self.cellType == PLContentCollectionViewCellTypeNormal) {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editBarButtonItemDidPress:)];
        self.trashBBI.enabled = YES;
        self.restoreBBI.enabled = YES;
        self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
        self.allBBI.enabled = YES;
        self.deleteBBI.enabled = YES;
        
        self.cellType = PLContentCollectionViewCellTypeEdit;
    } else {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemDidPress:)];
        self.trashBBI.enabled = NO;
        self.restoreBBI.enabled = NO;
        self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
        self.allBBI.enabled = NO;
        self.deleteBBI.enabled = NO;
        
        self.cellType = PLContentCollectionViewCellTypeNormal;
    }
    
    [self.selects removeAllObjects];
    [self.collectionView reloadData];
    
    [self setupTitle];
    [self setupNavigationBarItems];
}
- (void)trashBarButtonItemDidPress:(UIBarButtonItem *)sender {
    if (self.opreatingFiles) {
        return;
    }
    if (self.selects.count == 0) {
        return;
    }
    
    [SVProgressHUD show];
    self.opreatingFiles = YES;
    @weakify(self);
    [[PLUniversalManager defaultManager] trashContentsAtPaths:self.selects completion:^{
        @strongify(self);
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"已将%ld个项目移动到废纸篓", self.selects.count]];
        [self refreshAfterOperatingFiles];
    }];
}
- (void)restoreBarButtonItemDidPress:(UIBarButtonItem *)sender {
    if (self.opreatingFiles) {
        return;
    }
    if (self.selects.count == 0) {
        return;
    }
    
    [SVProgressHUD show];
    self.opreatingFiles = YES;
    @weakify(self);
    [[PLUniversalManager defaultManager] restoreContentsAtPaths:self.selects completion:^{
        @strongify(self);
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"已将%ld个项目还原", self.selects.count]];
        [self refreshAfterOperatingFiles];
    }];
}
- (void)deleteBarButtonItemDidPress:(UIBarButtonItem *)sender {
    if (self.opreatingFiles) {
        return;
    }
    if (self.selects.count == 0) {
        return;
    }
    
    [SVProgressHUD show];
    self.opreatingFiles = YES;
    @weakify(self);
    [[PLUniversalManager defaultManager] deleteContentsAtPaths:self.selects completion:^{
        @strongify(self);
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"已删除%ld个项目", self.selects.count]];
        [self refreshAfterOperatingFiles];
    }];
}
- (void)allBarButtonItemDidPress:(UIBarButtonItem *)sender {
    [self.selects removeAllObjects];
    if ([self.allBBI.title isEqualToString:@"全选"]) {
        [self.selects addObjectsFromArray:self.folders];
        [self.selects addObjectsFromArray:self.files];
    }
    [self.collectionView reloadData];
    
    if ([self.allBBI.title isEqualToString:@"全选"]) {
        self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
    } else {
        self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
    }
    
    [self setupTitle];
    [self setupNavigationBarItems];
}
- (void)sliderValueChanged:(StepSlider *)sender {
    [PLUniversalManager defaultManager].columnsPerRow = sender.index + 4;
    
    // 更新flowLayout后刷新collectionView
    [self setupCollectionViewFlowLayout];
    [self.collectionView reloadData];
}
- (void)switchValueChanged:(StepSlider *)sender {
    [PLUniversalManager defaultManager].directlyJumpPhoto = ![PLUniversalManager defaultManager].directlyJumpPhoto;
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
- (void)jumpSwitchValueChanged:(NSNotification *)sender {
    UIView *jumpSwitchView = self.jumpSwitchBBI.customView;
    UISwitch *jumpSwitch = (UISwitch *)[jumpSwitchView viewWithTag:100];
    jumpSwitch.on = [PLUniversalManager defaultManager].directlyJumpPhoto;
}

@end
