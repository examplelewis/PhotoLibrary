//
//  ViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/22.
//

#import "ViewController.h"

#import "PLShareFolderViewController.h"
#import "PLWebViewController.h"
#import "PLContentViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SMB服务器列表";
    
    [self setupUIAndData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 回到服务器列表就断开已有的连接
    [[PLSMBManager defaultManager] disconnectFileServer];
    
    // Find
    @weakify(self);
    [[PLSMBManager defaultManager] startDiscoveryWithCompletion:^{
        @strongify(self);
        [self.tableView reloadData];
    }];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[PLSMBManager defaultManager] stopDiscovery];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // UI
    [self setupNavigationBar];
    [self setupTableView];
}
- (void)setupNavigationBar {
    UIBarButtonItem *rightBBI = [[UIBarButtonItem alloc] initWithTitle:@"测试" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemDidPress:)];
    self.navigationItem.rightBarButtonItems = @[rightBBI];
}
- (void)setupTableView {
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PLSMBManager defaultManager].devices.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [PLSMBManager defaultManager].devices[indexPath.row].netbiosName;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    @weakify(self);
    [[PLSMBManager defaultManager] loginWithDeviceAtIndex:indexPath.row completion:^{
        @strongify(self);
        
        PLShareFolderViewController *vc = [[PLShareFolderViewController alloc] initWithNibName:@"PLShareFolderViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - Action
- (void)barButtonItemDidPress:(UIBarButtonItem *)sender {
    PLContentViewController *vc = [[PLContentViewController alloc] initWithNibName:@"PLContentViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    
//    // 通过打开一个网页，请求无线网络访问权限
//    PLWebViewController *vc = [[PLWebViewController alloc] initWithNibName:@"PLWebViewController" bundle:nil];
//    [self presentViewController:vc animated:YES completion:nil];
}


@end
