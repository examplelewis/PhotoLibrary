//
//  PLContentPhoneViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/30.
//

#import "PLContentPhoneViewController.h"

#import "PLContentView.h"

@interface PLContentPhoneViewController () <PLContentViewDelegate>

@property (nonatomic, strong) PLContentView *contentView;

@property (nonatomic, assign) BOOL selectingMode;

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
    
    [self.contentView refreshWhenViewDidAppear];
}

#pragma mark - Configure
- (void)setupTitle {
    if (self.contentView.viewModel.foldersCount + self.contentView.viewModel.filesCount == 0) {
        self.title = self.folderPath.lastPathComponent;
    } else {
        self.title = [NSString stringWithFormat:@"%@(%ld)", self.folderPath.lastPathComponent, self.contentView.viewModel.foldersCount + self.contentView.viewModel.filesCount];
    }
}
- (void)setupUIAndData {
    // Data
    self.selectingMode = NO;
    
    // UI
    [self setupContentView];
}
- (void)setupContentView {
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
}

#pragma mark - PLContentViewDelegate
- (void)didFinishRefreshingItemsInContentView:(PLContentView *)contentView {
    [self setupTitle];
}
- (void)contentView:(PLContentView *)contentView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.contentView.selectingMode) {
        [self setupTitle];
    }
}
- (void)contentViewModelDidFinishOperatingFiles:(PLContentView *)contentView {
    [self setupTitle];
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
