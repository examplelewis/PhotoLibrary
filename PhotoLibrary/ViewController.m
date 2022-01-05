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

#import "GYTapAlertManager.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, GYTapAlertDelegate> {
    NSArray *ignoreFolders;
}

@property (nonatomic, strong) NSArray<NSString *> *folders;
@property (nonatomic, strong) NSArray<NSString *> *folderContentCounts;

@property (nonatomic, copy) NSString *sdWebImageCacheFolderSize; // SDWebImage创建的缓存文件夹大小
@property (nonatomic, copy) NSString *fileAppCreatdTrashFolderSize; // 由“文件”App创建的.Trash文件夹的大小
@property (nonatomic, copy) NSString *documentsFolderSize; // SandBox文稿文件夹的大小

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UISwitch *jumpSwitch;

@property (nonatomic, strong) GYTapAlertManager *cleanTapManager;

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
    ignoreFolders = @[@"~~Test", @"~~废纸篓", @"~~混合作品", @"~~编辑作品", @"~~其他作品"];
    self.folders = @[];
    
    self.sdWebImageCacheFolderSize = @"0 B";
    self.fileAppCreatdTrashFolderSize = @"0 B";
    self.documentsFolderSize = @"0 B";
    
    self.cleanTapManager = [GYTapAlertManager.alloc initWithAction:[GYTapAlertAction tapActionWithCount:3 timeInterval:0.5 eventName:@"点击" actionName:@"清空所有文件"]];
    self.cleanTapManager.delegate = self;
    
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
}
- (void)setupTableView {
    self.tableView.tableFooterView = [UIView new];
    
    @weakify(self);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self refreshRootRolders];
        [self refreshOthers];
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - Data
- (void)refreshRootRolders {
    self.folders = [GYFileManager folderPathsInFolder:[PLAppManager defaultManager].documentPath];
    self.folders = [self.folders sortedArrayUsingDescriptors:@[[PLUniversalManager fileAscendingSortDescriptorWithKey:@"self"]]];
    self.folders = [self.folders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable folderPath, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [self->ignoreFolders indexOfObject:folderPath.lastPathComponent] == NSNotFound;
    }]];
    
    self.folderContentCounts = @[];
    for (NSInteger i = 0; i < self.folders.count; i++) {
        NSInteger foldersCount = [GYFileManager folderPathsInFolder:self.folders[i]].count;
        NSInteger filesCount = [GYFileManager filePathsInFolder:self.folders[i]].count;
        self.folderContentCounts = [self.folderContentCounts arrayByAddingObject:[NSString stringWithFormat:@"%ld / %ld", foldersCount, filesCount]];
    }
}
- (void)refreshOthers {
    self.sdWebImageCacheFolderSize = [GYFileManager sizeDescriptionFromSize:[[SDImageCache sharedImageCache] totalDiskSize]];
    if ([GYFileManager fileExistsAtPath:[PLAppManager defaultManager].fileAppCreatedTrashFolderPath]) {
        self.fileAppCreatdTrashFolderSize = [GYFileManager folderSizeDescriptionAtPath:[PLAppManager defaultManager].fileAppCreatedTrashFolderPath];
    }
    self.documentsFolderSize = [PLUniversalManager neededFoldersSizeDescription];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.folders.count;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return 3;
    } else {
        return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.folders[indexPath.row].lastPathComponent;
        cell.accessoryView = nil;
        cell.detailTextLabel.text = self.folderContentCounts[indexPath.row];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"混合作品";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"编辑作品";
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"其他作品";
        }
        cell.accessoryView = nil;
        cell.detailTextLabel.text = nil;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"清空SDWebImage的图片缓存";
            cell.accessoryView = nil;
            cell.detailTextLabel.text = self.sdWebImageCacheFolderSize;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"清空“文件”App创建的.Trash文件夹";
            cell.accessoryView = nil;
            cell.detailTextLabel.text = self.fileAppCreatdTrashFolderSize;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"清空所有文件";
            cell.accessoryView = nil;
            cell.detailTextLabel.text = self.documentsFolderSize;
        } else {
            cell.textLabel.text = @"";
            cell.accessoryView = nil;
            cell.detailTextLabel.text = nil;
        }
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"直接查看图片";
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                cell.accessoryView = self.jumpSwitch;
                cell.detailTextLabel.text = nil;
            } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                cell.accessoryView = nil;
                cell.detailTextLabel.text = @"是";
            } else {
                cell.accessoryView = nil;
                cell.detailTextLabel.text = nil;
            }
        }
    }
    
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"所有文件夹均应表示当前处于的阶段";
    } else {
        return @"";
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [PLNavigationManager navigateToContentAtFolderPath:self.folders[indexPath.row]];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [PLNavigationManager navigateToContentAtFolderPath:[PLAppManager defaultManager].mixWorksFolderPath];
        } else if (indexPath.row == 1) {
            [PLNavigationManager navigateToContentAtFolderPath:[PLAppManager defaultManager].editWorksEditFolderPath];
        } else if (indexPath.row == 2) {
            [PLNavigationManager navigateToContentAtFolderPath:[PLAppManager defaultManager].otherWorksFolderPath];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self cleanSDWebImageCahce];
        } else if (indexPath.row == 1) {
            [self cleanFileAppCreatedTrashFolder];
        } else if (indexPath.row == 2) {
            [self.cleanTapManager triggerTap];
        }
    } else {
        if (indexPath.row == 0) {
            // do nothing...
        }
    }
}

#pragma mark - Ops
- (void)cleanSDWebImageCahce {
    if ([[SDImageCache sharedImageCache] totalDiskSize] == 0) {
        [SVProgressHUD showInfoWithStatus:@"SDWebImage没有图片缓存"];
        return;
    }
    
    [SVProgressHUD show];
    @weakify(self);
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        [SVProgressHUD dismiss];
        
        @strongify(self);
        [self refreshOthers];
        [self.tableView reloadData];
    }];
}
- (void)cleanFileAppCreatedTrashFolder {
    if ([GYFileManager folderSizeAtPath:[PLAppManager defaultManager].fileAppCreatedTrashFolderPath] == 0) {
        [SVProgressHUD showInfoWithStatus:@"“文件”App创建的.Trash文件夹内没有内容"];
        return;
    }
    
    [SVProgressHUD show];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [GYFileManager removeFilePath:[PLAppManager defaultManager].fileAppCreatedTrashFolderPath];
        [GYFileManager createFolderAtPath:[PLAppManager defaultManager].fileAppCreatedTrashFolderPath];
        
        dispatch_main_async_safe(^{
            [SVProgressHUD dismiss];
            
            @strongify(self);
            [self refreshOthers];
            [self.tableView reloadData];
        });
    });
}
- (void)showCleanDocumentsFolderAlert {
    if ([self.documentsFolderSize isEqualToString:@"0 B"]) {
        return;
    }
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"是否清理所有文件夹" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    @weakify(self);
    UIAlertAction *confirmAA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self _cleanDocumentsFolder];
    }];
    
    [ac addAction:cancelAA];
    [ac addAction:confirmAA];
    
    [self presentViewController:ac animated:YES completion:nil];
}
- (void)_cleanDocumentsFolder {
    [SVProgressHUD show];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PLUniversalManager removeNeededFolders];
        [PLUniversalManager createNeededFolders];
        
        dispatch_main_async_safe(^{
            [SVProgressHUD dismiss];
            
            @strongify(self);
            [self.tableView.mj_header beginRefreshing];
        });
    });
}

#pragma mark - GYTapAlertDelegate
- (void)manager:(GYTapAlertManager *)tapManager didTriggerAction:(GYTapAlertAction *)action {
    if (tapManager == self.cleanTapManager) {
        [self showCleanDocumentsFolderAlert];
    }
}

#pragma mark - Action
- (void)barButtonItemDidPress:(UIBarButtonItem *)sender {
    [PLNavigationManager navigateToPhotoAtFolderPath:[[PLAppManager defaultManager] pathOfContentInDocumentFolder:@"~~Test"] index:0];
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
