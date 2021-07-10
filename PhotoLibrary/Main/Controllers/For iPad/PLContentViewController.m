//
//  PLContentViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import "PLContentViewController.h"

#import <StepSlider.h>

#import "PLOperationMenu.h"
#import "PLContentView.h"

@interface PLContentViewController () <PLOperationMenuDelegate, PLContentViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *editBBI;
@property (nonatomic, strong) UIBarButtonItem *allBBI;
@property (nonatomic, strong) UIBarButtonItem *trashBBI;
@property (nonatomic, strong) UIBarButtonItem *menuBBI;
@property (nonatomic, strong) UIBarButtonItem *sliderBBI;
@property (nonatomic, strong) UIBarButtonItem *jumpSwitchBBI; // 是否直接跳转到图片页

@property (nonatomic, strong) PLOperationMenu *operationMenu;

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
    if (self.contentView.viewModel.folderType == PLContentFolderTypeNormal) {
        self.navigationItem.rightBarButtonItems = @[self.editBBI, self.allBBI, self.trashBBI, self.menuBBI, self.jumpSwitchBBI, self.sliderBBI];
    } else {
        self.navigationItem.rightBarButtonItems = @[];
    }
}
- (void)setupAllBBI {
    BOOL selectAll = (self.contentView.viewModel.selectsCount == (self.contentView.viewModel.foldersCount + self.contentView.viewModel.filesCount)) && self.contentView.viewModel.selectsCount != 0; // 如果没有文件(夹)，就不算全选
    self.allBBI = [[UIBarButtonItem alloc] initWithTitle:selectAll ? @"取消全选" : @"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
}
- (void)setupContentView {
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
}

#pragma mark - Actions
- (void)editBarButtonItemDidPress:(UIBarButtonItem *)sender {
    if (!self.selectingMode) {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editBarButtonItemDidPress:)];
        self.trashBBI.enabled = YES;
        self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
        self.allBBI.enabled = YES;
        self.menuBBI.enabled = YES;
        
        self.selectingMode = YES;
    } else {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemDidPress:)];
        self.trashBBI.enabled = NO;
        self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
        self.allBBI.enabled = NO;
        self.menuBBI.enabled = NO;
        
        self.selectingMode = NO;
    }
    
    [self.contentView.viewModel removeAllSelectItems];
    [self.contentView reloadCollectionView];
    
    [self setupTitle];
    [self setupNavigationBarItems];
}
- (void)trashBarButtonItemDidPress:(UIBarButtonItem *)sender {
    [self.contentView.viewModel moveSelectItemsToTrash];
}
- (void)allBarButtonItemDidPress:(UIBarButtonItem *)sender {
    BOOL selectAll = [self.allBBI.title isEqualToString:@"全选"];
    
    [self.contentView.viewModel selectAllItems:selectAll];
    [self.contentView reloadCollectionView];
    
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
    [self.contentView setupCollectionViewFlowLayout];
    [self.contentView reloadCollectionView];
}
- (void)jumpSwitchValueChanged:(UISwitch *)sender {
    [PLUniversalManager defaultManager].directlyJumpPhoto = ![PLUniversalManager defaultManager].directlyJumpPhoto;
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
}

#pragma mark - PLContentViewDelegate
- (void)didFinishRefreshingItemsInContentView:(PLContentView *)contentView {
    [self setupTitle];
}
- (void)contentView:(PLContentView *)contentView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self setupTitle];
    [self setupAllBBI];
    [self setupNavigationBarItems];
}
- (void)contentViewModelDidFinishOperatingFiles:(PLContentView *)contentView {
    [self.contentView reloadCollectionView];

    [self setupTitle];
    [self setupAllBBI];
    [self setupNavigationBarItems];
}

#pragma mark - Getter
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
