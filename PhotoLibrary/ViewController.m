//
//  ViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/22.
//

#import "ViewController.h"
#import <MJRefresh.h>

#import "PLContentViewController.h"
#import "PLContentPhoneViewController.h"
#import "PLPhotoViewController.h"
#import "PLPhotoPhoneViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray *ignoreFolders;
}

@property (nonatomic, strong) NSArray<NSString *> *folders;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UISwitch *jumpSwitch;
@property (nonatomic, strong) UILabel *jumpLabel;

@end

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"文件列表";
    
    [self setupUIAndData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.folders.count == 0) {
        [self.tableView.mj_header beginRefreshing];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[SDImageCache sharedImageCache] clearMemory];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // Data
    ignoreFolders = @[@"~~Test", @"~~废纸篓", @"~~混合作品", @"~~编辑作品"];
    self.folders = @[];
    
    // UI
#if TARGET_IPHONE_SIMULATOR
    [self setupNavigationBar];
#endif
    [self setupJumpUI];
    [self setupTableView];
}
- (void)setupNavigationBar {
    UIBarButtonItem *rightBBI = [[UIBarButtonItem alloc] initWithTitle:@"测试" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemDidPress:)];
    self.navigationItem.rightBarButtonItems = @[rightBBI];
}
- (void)setupJumpUI {
    self.jumpSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 6.5, 47, 31)];
    self.jumpSwitch.tag = 100;
    self.jumpSwitch.on = [PLUniversalManager defaultManager].directlyJumpPhoto;
    [self.jumpSwitch addTarget:self action:@selector(jumpSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.jumpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 21)];
    self.jumpLabel.font = [UIFont systemFontOfSize:17];
    self.jumpLabel.text = @"是";
}
- (void)setupTableView {
    self.tableView.tableFooterView = [UIView new];
    
    @weakify(self);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self refreshRootRolders];
    }];
}

#pragma mark - Data
- (void)refreshRootRolders {
    [self.tableView.mj_header endRefreshing];
    
    self.folders = [GYFileManager folderPathsInFolder:[GYSettingManager defaultManager].documentPath];
    self.folders = [self.folders sortedArrayUsingDescriptors:@[[PLUniversalManager fileAscendingSortDescriptorWithKey:@"self"]]];
    self.folders = [self.folders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable folderPath, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [self->ignoreFolders indexOfObject:folderPath.lastPathComponent] == NSNotFound;
    }]];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.folders.count;
    } else if (section == 1) {
        return 2;
    } else {
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.folders[indexPath.row].lastPathComponent;
        cell.accessoryView = nil;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"混合作品";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"编辑作品";
        }
        cell.accessoryView = nil;
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"直接查看图片";
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                cell.accessoryView = self.jumpSwitch;
            } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                cell.accessoryView = self.jumpLabel;
            } else {
                cell.accessoryView = nil;
            }
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [PLNavigationManager navigateToContentAtFolderPath:self.folders[indexPath.row]];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [PLNavigationManager navigateToContentAtFolderPath:[GYSettingManager defaultManager].mixWorksFolderPath];
        } else if (indexPath.row == 1) {
            [PLNavigationManager navigateToContentAtFolderPath:[GYSettingManager defaultManager].editWorksEditFolderPath];
        }
    } else {
        if (indexPath.row == 0) {
            // do nothing...
        }
    }
}

#pragma mark - Action
- (void)barButtonItemDidPress:(UIBarButtonItem *)sender {
    [PLNavigationManager navigateToPhotoAtFolderPath:[[GYSettingManager defaultManager] pathOfContentInDocumentFolder:@"~~Test"] index:0];
}
- (void)jumpSwitchValueChanged:(UISwitch *)sender {
    [PLUniversalManager defaultManager].directlyJumpPhoto = sender.isOn;
    
    // NSUserDefaults 必须在主线程上跑才回正确存储数据
    dispatch_main_async_safe(^{
        [[NSUserDefaults standardUserDefaults] setBool:[PLUniversalManager defaultManager].directlyJumpPhoto forKey:PLDirectlyJumpUserDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

@end
