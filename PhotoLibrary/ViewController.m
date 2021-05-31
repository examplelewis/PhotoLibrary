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
    ignoreFolders = @[@"~~Test", @"废纸篓"];
    self.folders = @[];
    
    // UI
#if TARGET_IPHONE_SIMULATOR
    [self setupNavigationBar];
#endif
    [self setupTableView];
}
- (void)setupNavigationBar {
    UIBarButtonItem *rightBBI = [[UIBarButtonItem alloc] initWithTitle:@"测试" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemDidPress:)];
    self.navigationItem.rightBarButtonItems = @[rightBBI];
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
    self.folders = [self.folders sortedArrayUsingDescriptors:@[[PLUniversalManager defaultManager].fileAscendingSortDescriptor]];
    self.folders = [self.folders filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable folderPath, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [self->ignoreFolders indexOfObject:folderPath.lastPathComponent] == NSNotFound;
    }]];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.folders.count;
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
    } else {
        cell.textLabel.text = @"废纸篓";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        PLContentViewController *vc = [[PLContentViewController alloc] initWithNibName:@"PLContentViewController" bundle:nil];
        if (indexPath.section == 0) {
            vc.folderPath = self.folders[indexPath.row];
            vc.folderType = PLContentFolderTypeNormal;
        } else {
            if (indexPath.row == 0) {
                vc.folderPath = [GYSettingManager defaultManager].trashFolderPath;
                vc.folderType = PLContentFolderTypeTrash;
            }
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        PLContentPhoneViewController *vc = [[PLContentPhoneViewController alloc] initWithNibName:@"PLContentPhoneViewController" bundle:nil];
        if (indexPath.section == 0) {
            vc.folderPath = self.folders[indexPath.row];
            vc.folderType = PLContentFolderTypeNormal;
        } else {
            if (indexPath.row == 0) {
                vc.folderPath = [GYSettingManager defaultManager].trashFolderPath;
                vc.folderType = PLContentFolderTypeTrash;
            }
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Action
- (void)barButtonItemDidPress:(UIBarButtonItem *)sender {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        PLPhotoViewController *vc = [[PLPhotoViewController alloc] initWithNibName:@"PLPhotoViewController" bundle:nil];
        vc.folderPath = [[GYSettingManager defaultManager] pathOfContentInDocumentFolder:@"~~Test"];
        vc.currentIndex = 0;
        
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        PLPhotoPhoneViewController *vc = [[PLPhotoPhoneViewController alloc] initWithNibName:@"PLPhotoPhoneViewController" bundle:nil];
        vc.folderPath = [[GYSettingManager defaultManager] pathOfContentInDocumentFolder:@"~~Test"];

        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
