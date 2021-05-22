//
//  ViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/22.
//

#import "ViewController.h"
#import "PLServerModel.h"

#import <WebKit/WebKit.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<SMBDevice *> *devices;
@property (nonatomic, strong) SMBFileServer *fileServer;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SMB服务器列表";
    
    [self setupUIAndData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 回到服务器列表就断开连接
    [self.fileServer disconnect:nil];
    
    // Find
    @weakify(self);
    [[SMBDiscovery sharedInstance] startDiscoveryOfType:SMBDeviceTypeAny added:^(SMBDevice *device) {
        @strongify(self);
        
        [self.devices addObject:device];
        [self.tableView reloadData];
    } removed:^(SMBDevice *device) {
        [self.devices removeObject:device];
        [self.tableView reloadData];
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[SMBDiscovery sharedInstance] stopDiscovery];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // data
    self.devices = [NSMutableArray array];
    
    // UI
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.devices[indexPath.row].netbiosName;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [SVProgressHUD showWithStatus:@"连接中"];
    
    SMBDevice *device = self.devices[indexPath.row];
    self.fileServer = [[SMBFileServer alloc] initWithHost:device.host netbiosName:device.netbiosName group:device.group];
    [self.fileServer connectAsUser:@"examplelewis" password:@"Example@163.COM" completion:^(BOOL guest, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"连接失败: %@", error.localizedDescription]];
        } else if (guest) {
            [SVProgressHUD showErrorWithStatus:@"连接成功，当前为游客，无法使用本App"];
        } else {
            [SVProgressHUD dismiss];
        }
    }];
}

// 通过打开一个网页，请求无线网络访问权限
- (void)askWirelessAuthorization {
    
}


@end
