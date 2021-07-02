//
//  AppDelegate.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/22.
//

#import "AppDelegate.h"
#import "GYExceptionManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [self setupLogger];
    
    // 每次App启动，清空所有SDImageCache的缓存
    [[SDImageCache sharedImageCache] clearWithCacheType:SDImageCacheTypeDisk completion:nil];
    // 删除“文件”App的生成的.Trash文件
    [GYFileManager removeFilePath:[GYSettingManager defaultManager].fileAppCreatedTrashFolderPath];
    // 创建必须的文件夹
    [PLUniversalManager createNeededFolders];
    
    [SVProgressHUD setMinimumDismissTimeInterval:1.0f];
    [SVProgressHUD setMaximumDismissTimeInterval:1.0f];
    
    return YES;
}

#pragma mark - AppDelegate
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

#pragma mark - UISceneSession lifecycle
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}
- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

#pragma mark - Setup
- (void)setupLogger {
    // 在系统上保持一周的日志文件
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:[GYSettingManager defaultManager].documentPath];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24 * 7;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    fileLogger.maximumFileSize = 10 * 1024 * 1024;
    [DDLog addLogger:fileLogger];
    
    // RELEASE 的时候不需要添加 console 日志，只保留文件日志
#ifdef DEBUG
    [DDLog addLogger:[DDOSLogger sharedInstance]]; // console 日志
#endif
}

@end
