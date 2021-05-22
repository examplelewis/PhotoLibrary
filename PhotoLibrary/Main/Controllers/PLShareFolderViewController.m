//
//  PLShareFolderViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/22.
//

#import "PLShareFolderViewController.h"

@interface PLShareFolderViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PLShareFolderViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ 的共享文件夹", [PLSMBManager defaultManager].device.netbiosName];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 没有共享文件夹数据的时候，再加载共享文件夹
    if ([PLSMBManager defaultManager].shares.count == 0) {
        @weakify(self);
        [[PLSMBManager defaultManager] listShareFoldersWithSuccess:^{
            @strongify(self);
            [self.tableView reloadData];
        } failure:^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

#pragma mark - Configure
- (void)setupUIAndData {
    // UI
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PLSMBManager defaultManager].shares.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [PLSMBManager defaultManager].shares[indexPath.row].name;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    @weakify(self);
//    [[PLSMBManager defaultManager] loginWithDeviceAtIndex:indexPath.row completion:^{
//        @strongify(self);
//        
//        PLShareFolderViewController *vc = [[PLShareFolderViewController alloc] initWithNibName:@"PLShareFolderViewController" bundle:nil];
//        [self.navigationController pushViewController:vc animated:YES];
//    }];
}

@end
