//
//  ViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/22.
//

#import "ViewController.h"
#import "PLServerModel.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, copy) NSArray<PLServerModel *> *servers;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"SMB服务器服务器列表";
    
    [self setupUIAndData];
}

#pragma mark - Configure
- (void)setupUIAndData {
    // data
    self.servers = @[
        [PLServerModel modelWithHostName:@"DS1621+" ipAddress:@"http://192.168.31.74"],
        [PLServerModel modelWithHostName:@"DS1621Virtual" ipAddress:@"http://192.168.31.67"],
        [PLServerModel modelWithHostName:@"DS216Play" ipAddress:@"http://192.168.31.185"],
    ];
    
    // UI
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.servers.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.servers[indexPath.row].hostName;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [SVProgressHUD showWithStatus:@"连接中"];
    
    
}


@end
