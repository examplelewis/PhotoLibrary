//
//  PLSMBManager.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/22.
//

#import <Foundation/Foundation.h>

#import "SMBClient.h"

// SMBClient 只支持 SMB1 协议，需要在群晖中文件服务→SMB→高级设置→最小SMB协议，设置为SMB1

NS_ASSUME_NONNULL_BEGIN

@interface PLSMBManager : NSObject

@property (nonatomic, strong, nullable) SMBDevice *device; // 当前设备
@property (nonatomic, strong, nullable) SMBFileServer *fileServer; // 当前设备登录后的文件服务器
@property (nonatomic, strong, nullable) SMBShare *share; // 当前共享文件夹

@property (nonatomic, strong) NSMutableArray<SMBDevice *> *devices;
@property (nonatomic, strong) NSMutableArray<SMBShare *> *shares;

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Discovery
- (void)startDiscoveryWithCompletion:(void (^)(void))completion;
- (void)stopDiscovery;

#pragma mark - Login
- (void)loginWithDeviceAtIndex:(NSInteger)index completion:(void (^)(void))completion;

#pragma mark - File Server
- (void)disconnectFileServer;

#pragma mark - Share Folders
- (void)listShareFoldersWithSuccess:(void (^)(void))success failure:(void (^)(void))failure;
- (void)openShareFolderAtIndex:(NSInteger)index success:(void (^)(void))success failure:(void (^)(void))failure;
- (void)closeShare;

@end

NS_ASSUME_NONNULL_END
