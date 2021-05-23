//
//  PLSMBManager.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/22.
//

#import "PLSMBManager.h"

@implementation PLSMBManager

#pragma mark - Lifecycle
static PLSMBManager *defaultManager = nil;
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[PLSMBManager alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.devices = [NSMutableArray array];
        self.shares = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Discovery
- (void)startDiscoveryWithCompletion:(void (^)(void))completion {
    @weakify(self);
    [[SMBDiscovery sharedInstance] startDiscoveryOfType:SMBDeviceTypeAny added:^(SMBDevice *device) {
        @strongify(self);
        [self.devices addObject:device];
        
        if (completion) {
            completion();
        }
    } removed:^(SMBDevice *device) {
        @strongify(self);
        [self.devices removeObject:device];
        
        if (completion) {
            completion();
        }
    }];
}
- (void)stopDiscovery {
    [[SMBDiscovery sharedInstance] stopDiscovery];
    [self.devices removeAllObjects];
}

#pragma mark - Login
- (void)loginWithDeviceAtIndex:(NSInteger)index completion:(void (^)(void))completion {
    [SVProgressHUD showWithStatus:@"连接中"];
    
    self.device = self.devices[index];
    self.fileServer = [[SMBFileServer alloc] initWithHost:self.device.host netbiosName:self.device.netbiosName group:self.device.group];
    
    @weakify(self);
    [self.fileServer connectAsUser:@"examplelewis" password:@"Example@163.COM" completion:^(BOOL guest, NSError *error) {
        @strongify(self);
        
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"连接失败: %@", error.localizedDescription]];
            
            [self disconnectFileServer];
        } else if (guest) {
            [SVProgressHUD showErrorWithStatus:@"连接成功，当前为游客，无法使用本App"];
            
            [self disconnectFileServer];
        } else {
            [SVProgressHUD dismiss];
            
            if (completion) {
                completion();
            }
        }
    }];
}

#pragma mark - File Server
- (void)disconnectFileServer {
    @weakify(self);
    [self.fileServer disconnect:^{
        @strongify(self);
        
        // 断开连接后，需要重置 device、fileServer、share，并且清空已存储的共享文件夹列表
        self.device = nil;
        self.fileServer = nil;
        self.share = nil;
        [self.shares removeAllObjects];
    }];
}

#pragma mark - Share Folders
- (void)listShareFoldersWithSuccess:(void (^)(void))success failure:(void (^)(void))failure {
    [SVProgressHUD showWithStatus:@"加载中"];
    
    @weakify(self);
    [self.fileServer listShares:^(NSArray<SMBShare *> *shares, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"加载共享文件夹遇到错误: %@", error.localizedDescription]];
            
            if (failure) {
                failure();
            }
        } else {
            [SVProgressHUD dismiss];
            
            @strongify(self);
            self.shares = [NSMutableArray arrayWithArray:shares];
            
            if (success) {
                success();
            }
        }
    }];
}
- (void)openShareFolderAtIndex:(NSInteger)index success:(void (^)(void))success failure:(void (^)(void))failure {
    [SVProgressHUD showWithStatus:@"加载中"];
    
    self.share = self.shares[index];
    
    @weakify(self);
    [self.share open:^(NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"打开共享文件夹遇到错误: %@", error.localizedDescription]];
            
            @strongify(self);
            self.share = nil; // 重置 share
            
            if (failure) {
                failure();
            }
        } else {
            [SVProgressHUD dismiss];
            
            if (success) {
                success();
            }
        }
    }];
}
- (void)closeShare {
    @weakify(self);
    [self.share close:^(NSError * _Nullable error) {
        @strongify(self);
        self.share = nil; // 重置 share
    }];
}

@end
