//
//  PLContentViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import "PLContentViewController.h"

#import "PLNavigationItems.h"

#import "PLContentView.h"

@interface PLContentViewController () <PLOperationMenuDelegate, PLContentViewDelegate, PLNavigationItemsDatasource, PLNavigationItemsDelegate>

@property (nonatomic, strong) PLNavigationItems *navigationItems;

@property (nonatomic, strong) PLContentView *contentView;

@property (nonatomic, assign) BOOL selectingMode;

@end

@implementation PLContentViewController

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
    
    [self.contentView refreshWhenViewDidAppear];
}

#pragma mark - Configure
- (void)setupTitle {
    if (self.contentView.viewModel.foldersCount + self.contentView.viewModel.filesCount == 0) {
        self.title = self.folderPath.lastPathComponent;
    } else {
        if (!self.selectingMode) {
            self.title = [NSString stringWithFormat:@"%@(%ld)", self.folderPath.lastPathComponent, self.contentView.viewModel.foldersCount + self.contentView.viewModel.filesCount];
        } else {
            self.title = [NSString stringWithFormat:@"%@(%ld)(%ld)", self.folderPath.lastPathComponent, self.contentView.viewModel.foldersCount + self.contentView.viewModel.filesCount, self.contentView.viewModel.selectsCount];
        }
    }
}
- (void)setupUIAndData {
    // Data
    self.selectingMode = NO;
    
    // UI
    [self setupNavigationBar];
    [self setupContentView];
}
- (void)setupNavigationBar {
    BOOL needShowBBIs = (self.contentView.viewModel.folderType == PLContentFolderTypeNormal);
    self.navigationItem.rightBarButtonItems = needShowBBIs ? self.navigationItems.barButtonItems : @[];
}
- (void)setupAllBBI {
    BOOL selectAll = (self.contentView.viewModel.selectsCount == (self.contentView.viewModel.foldersCount + self.contentView.viewModel.filesCount)) && self.contentView.viewModel.selectsCount != 0; // 如果没有文件(夹)，就不算全选
    [self.navigationItems updateAllBarButtonItemTitle:selectAll ? @"取消全选" : @"全选"];
}
- (void)setupShiftBBI {
    [self.navigationItems updateShiftBarButtonItemTitle:self.contentView.viewModel.shiftMode ? @"SHIFT" : @"shift"];
}
- (void)setupContentView {
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
}

#pragma mark - PLNavigationItemsDatasource
- (PLOperationMenuAction)menuActionForForNavigationItems:(PLNavigationItems *)navigationItems {
    return PLOperationMenuActionMoveToTypes | PLOperationMenuActionDepart | PLOperationMenuActionMerge;
}
- (BOOL)selectingModeForNavigationItems:(PLNavigationItems *)navigationItems {
    return self.selectingMode;
}

#pragma mark - PLNavigationItemsDelegate
- (void)navigationItems:(PLNavigationItems *)navigationItems didTapEditBarButtonItem:(UIBarButtonItem *)item {
    self.selectingMode = !self.selectingMode;
    
    [self.contentView.viewModel removeAllSelectItems];
    [self.contentView reloadCollectionView];
    
    [self setupTitle];
    [self setupNavigationBar];
}
- (void)navigationItems:(PLNavigationItems *)navigationItems didTapShiftBarButtonItem:(UIBarButtonItem *)item shiftMode:(BOOL)shiftMode {
    self.contentView.viewModel.shiftMode = shiftMode;
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"已%@SHIFT模式", self.contentView.viewModel.shiftMode ? @"打开" : @"关闭"]];
    
    [self setupNavigationBar];
}
- (void)navigationItems:(PLNavigationItems *)navigationItems didTapSelectAllBarButtonItem:(UIBarButtonItem *)item selectAll:(BOOL)selectAll {
    [self.contentView.viewModel selectAllItems:selectAll];
    [self.contentView reloadCollectionView];
    
    [self setupTitle];
    [self setupNavigationBar];
}
- (void)navigationItems:(PLNavigationItems *)navigationItems didTapTrashBarButtonItem:(UIBarButtonItem *)item {
    [self.contentView.viewModel moveSelectItemsToTrash];
}
- (void)navigationItems:(PLNavigationItems *)navigationItems didChangeSliderValue:(StepSlider *)sender {
    // 更新flowLayout后刷新collectionView
    [self.contentView setupCollectionViewFlowLayout];
    [self.contentView reloadCollectionView];
}

#pragma mark - PLOperationMenuDelegate
- (void)operationMenu:(PLOperationMenu *)menu didTapAction:(PLOperationMenuAction)action {
    if (action & PLOperationMenuActionMoveToMix) {
        [self.contentView.viewModel moveSelectItemsToMixWorks];
    }
    
    if (action & PLOperationMenuActionMoveToEdit) {
        [self.contentView.viewModel moveSelectItemsToEditWorks];
    }
    
    if (action & PLOperationMenuActionMoveToOther) {
        [self.contentView.viewModel moveSelectItemsToOtherWorks];
    }
    
    if (action & PLOperationMenuActionMerge) {
        [self.contentView mergeFolder];
    }
    
    if (action & PLOperationMenuActionDepart) {
        [self.contentView departFolder];
    }
}

#pragma mark - PLContentViewDelegate
- (void)didFinishRefreshingItemsInContentView:(PLContentView *)contentView {
    [self setupTitle];
}
- (void)contentView:(PLContentView *)contentView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.contentView.selectingMode) {
        [self setupTitle];
        [self setupAllBBI];
        [self setupNavigationBar];
    }
}
- (void)contentViewModelDidFinishOperatingFiles:(PLContentView *)contentView {
    [self setupTitle];
    [self setupAllBBI];
    [self setupNavigationBar];
}
- (void)contentViewModelDidSwitchShiftMode:(PLContentView *)contentView {
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"已%@SHIFT模式", self.contentView.viewModel.shiftMode ? @"打开" : @"关闭"]];
    
    [self setupShiftBBI];
    [self setupNavigationBar];
}
- (void)contentViewModelDidFinishMerging:(PLContentView *)contentView {
    self.selectingMode = NO;
    
    [self.contentView.viewModel removeAllSelectItems];
    [self.contentView reloadCollectionView];
    
    [self.navigationItems switchSelectingMode:NO];
    
    [self setupTitle];
    [self setupNavigationBar];
}
- (void)contentViewModelDidFinishDeparting:(PLContentView *)contentView {
    self.selectingMode = NO;
    
    [self.contentView.viewModel removeAllSelectItems];
    [self.contentView reloadCollectionView];
    
    [self.navigationItems switchSelectingMode:NO];
    
    [self setupTitle];
    [self setupNavigationBar];
}

#pragma mark - Getter
- (PLNavigationItems *)navigationItems {
    if (!_navigationItems) {
        _navigationItems = [PLNavigationItems itemsFromActions:PLNavigationActionContentIPAD];
        _navigationItems.dataSource = self;
        _navigationItems.delegate = self;
        _navigationItems.menuDelegate = self;
        
        [_navigationItems setupNavigationItems];
    }
    
    return _navigationItems;
}
- (PLContentView *)contentView {
    if (!_contentView) {
        _contentView = [[PLContentView alloc] initWithFolderPath:self.folderPath];
        _contentView.delegate = self;
    }
    
    return _contentView;
}

#pragma mark - Setter
- (void)setSelectingMode:(BOOL)selectingMode {
    _selectingMode = selectingMode;
    
    self.contentView.selectingMode = selectingMode;
}

@end
