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
#import "PLOperationMenu.h"
#import "PLContentViewModel.h"

@interface PLContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PLOperationMenuDelegate, PLContentViewModelDelegate>

@property (nonatomic, strong) UIBarButtonItem *editBBI;
@property (nonatomic, strong) UIBarButtonItem *allBBI;
@property (nonatomic, strong) UIBarButtonItem *trashBBI;
@property (nonatomic, strong) UIBarButtonItem *menuBBI;
@property (nonatomic, strong) UIBarButtonItem *sliderBBI;
@property (nonatomic, strong) UIBarButtonItem *jumpSwitchBBI; // 是否直接跳转到图片页

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) PLOperationMenu *operationMenu;
@property (nonatomic, assign) CGSize folderItemSize;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) PLContentViewModel *viewModel;

@property (nonatomic, assign) PLContentFolderType folderType;
@property (nonatomic, assign) PLContentCollectionViewCellType cellType;

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
    
    if (self.viewModel.foldersCount == 0 && self.viewModel.filesCount == 0) {
        [self.collectionView.mj_header beginRefreshing];
    } else {
        if (self.refreshFilesWhenViewDidAppear) {
            self.refreshFilesWhenViewDidAppear = NO;
            
            [self refreshFiles];
        }
    }
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 退出页面时清除内存中的图片
    [self.viewModel cleanSDWebImageCache];
}

#pragma mark - Configure
- (void)setupTitle {
    if (self.viewModel.foldersCount + self.viewModel.filesCount == 0) {
        self.title = self.folderPath.lastPathComponent;
    } else {
        if (self.cellType == PLContentCollectionViewCellTypeNormal) {
            self.title = [NSString stringWithFormat:@"%@(%ld)", self.folderPath.lastPathComponent, self.viewModel.foldersCount + self.viewModel.filesCount];
        } else {
            self.title = [NSString stringWithFormat:@"%@(%ld)(%ld)", self.folderPath.lastPathComponent, self.viewModel.foldersCount + self.viewModel.filesCount, self.viewModel.selectsCount];
        }
    }
}
- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(columnPerRowSliderValueChanged:) name:PLColumnPerRowSliderValueChanged object:nil];
}
- (void)setupUIAndData {
    // Data
    self.cellType = PLContentCollectionViewCellTypeNormal;
    
    // UI
    [self setupNavigationBar];
    [self setupCollectionViewFlowLayout];
    [self setupCollectionView];
}
- (void)setupNavigationBar {
    self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemDidPress:)];
    
    self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
    self.allBBI.enabled = NO;
    
    self.trashBBI = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(trashBarButtonItemDidPress:)];
    self.trashBBI.enabled = NO;
    
    self.operationMenu = [[PLOperationMenu alloc] initWithAction:PLOperationMenuActionMoveToTypes];
    self.operationMenu.delegate = self;
    self.menuBBI = [[UIBarButtonItem alloc] initWithTitle:@"操作" menu:self.operationMenu.menu];
    self.menuBBI.enabled = NO;
    
    UIView *jumpSwitchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 44)];
    UISwitch *jumpSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 6.5, 47, 31)];
    jumpSwitch.tag = 100;
    jumpSwitch.on = [PLUniversalManager defaultManager].directlyJumpPhoto;
    [jumpSwitch addTarget:self action:@selector(jumpSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [jumpSwitchView addSubview:jumpSwitch];
    self.jumpSwitchBBI = [[UIBarButtonItem alloc] initWithCustomView:jumpSwitchView];
    
    UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 44)];
    StepSlider *slider = [[StepSlider alloc] initWithFrame:CGRectMake(0, 9, 270, 26)];
    slider.tag = 100;
    slider.maxCount = 6;
    slider.index = [PLUniversalManager defaultManager].columnsPerRow - 4;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [sliderView addSubview:slider];
    self.sliderBBI = [[UIBarButtonItem alloc] initWithCustomView:sliderView];
    
    [self setupNavigationBarItems];
}
- (void)setupNavigationBarItems {
    if (self.folderType == PLContentFolderTypeNormal) {
        self.navigationItem.rightBarButtonItems = @[self.editBBI, self.allBBI, self.trashBBI, self.menuBBI, self.jumpSwitchBBI, self.sliderBBI];
    } else {
        self.navigationItem.rightBarButtonItems = @[];
    }
}
- (void)setupAllBBI {
    BOOL selectAll = (self.viewModel.selectsCount == (self.viewModel.foldersCount + self.viewModel.filesCount)) && self.viewModel.selectsCount != 0; // 如果没有文件(夹)，就不算全选
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
            cell.contentPath = [self.viewModel folderPathAtIndex:indexPath.row];
        } else {
            cell.contentPath = [self.viewModel filePathAtIndex:indexPath.row];
        }
    } else {
        if (self.viewModel.foldersCount > 0) {
            cell.contentPath = [self.viewModel folderPathAtIndex:indexPath.row];
        } else if (self.viewModel.filesCount > 0) {
            cell.contentPath = [self.viewModel filePathAtIndex:indexPath.row];
        } else {
            return [UICollectionViewCell new];
        }
    }
    
    if (self.cellType == PLContentCollectionViewCellTypeNormal) {
        cell.cellType = PLContentCollectionViewCellTypeNormal;
    } else {
        cell.cellType = [self.viewModel isSelectedAtItemPath:cell.contentPath] ? PLContentCollectionViewCellTypeEditSelect : PLContentCollectionViewCellTypeEdit;
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
        if (cell.isFolder) {
            PLNavigationType type = [PLNavigationManager navigateToContentAtFolderPath:[self.viewModel folderPathAtIndex:indexPath.row]];
            self.refreshFilesWhenViewDidAppear = type == PLNavigationTypePhoto; // 跳转到 PLPhotoViewController 后，返回需要刷新文件
        } else {
            if (self.folderType == PLContentFolderTypeNormal) {
                PLNavigationType type = [PLNavigationManager navigateToPhotoAtFolderPath:self.folderPath index:indexPath.row];
                self.refreshFilesWhenViewDidAppear = type == PLNavigationTypePhoto; // 跳转到 PLPhotoViewController 后，返回需要刷新文件
            } else if (self.folderType == PLContentFolderTypeEditWorks) {
                
            }
        }
    } else {
        if ([self.viewModel isSelectedAtItemPath:cell.contentPath]) {
            [self.viewModel removeSelectItem:cell.contentPath];
        } else {
            [self.viewModel addSelectItem:cell.contentPath];
        }
        
        [self setupTitle];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        [self setupAllBBI];
        [self setupNavigationBarItems];
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

#pragma mark - Actions
- (void)editBarButtonItemDidPress:(UIBarButtonItem *)sender {
    if (self.cellType == PLContentCollectionViewCellTypeNormal) {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editBarButtonItemDidPress:)];
        self.trashBBI.enabled = YES;
        self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
        self.allBBI.enabled = YES;
        self.menuBBI.enabled = YES;
        
        self.cellType = PLContentCollectionViewCellTypeEdit;
    } else {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemDidPress:)];
        self.trashBBI.enabled = NO;
        self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
        self.allBBI.enabled = NO;
        self.menuBBI.enabled = NO;
        
        self.cellType = PLContentCollectionViewCellTypeNormal;
    }
    
    [self.viewModel removeAllSelectItems];
    [self.collectionView reloadData];
    
    [self setupTitle];
    [self setupNavigationBarItems];
}
- (void)trashBarButtonItemDidPress:(UIBarButtonItem *)sender {
    [self.viewModel moveSelectItemsToTrash];
}
- (void)allBarButtonItemDidPress:(UIBarButtonItem *)sender {
    BOOL selectAll = [self.allBBI.title isEqualToString:@"全选"];
    
    [self.viewModel selectAllItems:selectAll];
    [self.collectionView reloadData];
    
    if (selectAll) {
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
- (void)jumpSwitchValueChanged:(UISwitch *)sender {
    [PLUniversalManager defaultManager].directlyJumpPhoto = ![PLUniversalManager defaultManager].directlyJumpPhoto;
}

#pragma mark - PLOperationMenuDelegate
- (void)operationMenu:(PLOperationMenu *)menu didTapAction:(PLOperationMenuAction)action {
    if (action & PLOperationMenuActionMoveToMix) {
        [self.viewModel moveSelectItemsToMixWorks];
    }
    
    if (action & PLOperationMenuActionMoveToEdit) {
        [self.viewModel moveSelectItemsToEditWorks];
    }
    
    if (action & PLOperationMenuActionMoveToOther) {
        [self.viewModel moveSelectItemsToOtherWorks];
    }
}

#pragma mark - PLContentViewModelDelegate
- (void)viewModelDidFinishOperatingFiles {
    @weakify(self);
    dispatch_main_async_safe(^{
        @strongify(self);
        
        [self.collectionView reloadData];

        [self setupTitle];
        [self setupAllBBI];
        [self setupNavigationBarItems];
    });
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

#pragma mark - Setter
- (void)setFolderPath:(NSString *)folderPath {
    _folderPath = folderPath.copy;
    
    if ([folderPath hasPrefix:[GYSettingManager defaultManager].trashFolderPath]) {
        self.folderType = PLContentFolderTypeTrash;
    } else if ([folderPath hasPrefix:[GYSettingManager defaultManager].mixWorksFolderPath]) {
        self.folderType = PLContentFolderTypeMixWorks;
    } else if ([folderPath hasPrefix:[GYSettingManager defaultManager].editWorksFolderPath]) {
        self.folderType = PLContentFolderTypeEditWorks;
    } else {
        self.folderType = PLContentFolderTypeNormal;
    }
}

@end
