//
//  PLNavigationManager.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/6/5.
//

#import "PLNavigationManager.h"

#import "PLContentViewController.h"
#import "PLContentPhoneViewController.h"
#import "PLPhotoViewController.h"
#import "PLPhotoPhoneViewController.h"

@implementation PLNavigationManager

+ (PLNavigationType)navigateToContentAtFolderPath:(NSString *)folderPath {
    return [PLNavigationManager navigateToContentAtFolderPath:folderPath recursivelyReading:NO];
}
+ (PLNavigationType)navigateToContentAtFolderPath:(NSString *)folderPath recursivelyReading:(BOOL)recursivelyReading {
    NSInteger imageFilesCount = 0;
    NSInteger folderCount = 0;
    if (recursivelyReading) {
        imageFilesCount = [GYFileManager allFilePathsInFolder:folderPath extensions:[PLAppManager defaultManager].mimeImageTypes].count;
        folderCount = [GYFileManager allFolderPathsInFolder:folderPath].count;
    } else {
        imageFilesCount = [GYFileManager filePathsInFolder:folderPath extensions:[PLAppManager defaultManager].mimeImageTypes].count;
        folderCount = [GYFileManager folderPathsInFolder:folderPath].count;
    }
    
    // 啥都没有，不跳转
    if (imageFilesCount == 0 && folderCount == 0) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@ 内没有可用项目", folderPath.lastPathComponent]];
        return PLNavigationTypeNone;
    }
    
    // 如果没有文件夹只有图片
    if (folderCount == 0) {
        // 如果是平板 并且 需要直接跳转到图片页，那么直接跳转到图片页
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && [PLUniversalManager defaultManager].directlyJumpPhoto) {
            return [PLNavigationManager navigateToPhotoAtFolderPath:folderPath index:0];
        }
        
        // 如果是手机，那么直接跳转到图片页
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            return [PLNavigationManager navigateToPhotoAtFolderPath:folderPath index:0];
        }
    }
    
    UIViewController *vc = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        vc = [[PLContentViewController alloc] initWithNibName:@"PLContentViewController" bundle:nil];
        ((PLContentViewController *)vc).folderPath = folderPath;
        ((PLContentViewController *)vc).recursivelyReading = recursivelyReading;
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        vc = [[PLContentPhoneViewController alloc] initWithNibName:@"PLContentPhoneViewController" bundle:nil];
        ((PLContentPhoneViewController *)vc).folderPath = folderPath;
    }
    
    if (vc) {
        [[self currentNavigationController] pushViewController:vc animated:YES];
        return PLNavigationTypeContent;
    } else {
        [SVProgressHUD showInfoWithStatus:@"设备类型不正确"];
        return PLNavigationTypeNone;
    }
}
+ (PLNavigationType)navigateToPhotoAtFolderPath:(NSString *)folderPath index:(NSInteger)index {
    // 啥都没有，不跳转
    NSInteger imageFilesCount = [GYFileManager filePathsInFolder:folderPath extensions:[PLAppManager defaultManager].mimeImageTypes].count;
    if (imageFilesCount == 0) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@ 内没有可用项目", folderPath.lastPathComponent]];
        return PLNavigationTypeNone;
    }
    
    UIViewController *vc = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        vc = [[PLPhotoViewController alloc] initWithNibName:@"PLPhotoViewController" bundle:nil];
        ((PLPhotoViewController *)vc).folderPath = folderPath;
        ((PLPhotoViewController *)vc).currentIndex = index;
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        vc = [[PLPhotoPhoneViewController alloc] initWithNibName:@"PLPhotoPhoneViewController" bundle:nil];
        ((PLPhotoPhoneViewController *)vc).folderPath = folderPath;
        ((PLPhotoPhoneViewController *)vc).currentIndex = index;
    }
    
    if (vc) {
        [[self currentNavigationController] pushViewController:vc animated:YES];
        return PLNavigationTypePhoto;
    } else {
        [SVProgressHUD showInfoWithStatus:@"设备类型不正确"];
        return PLNavigationTypeNone;
    }
}
+ (PLNavigationType)navigateToPhotoAtFolderPath:(NSString *)folderPath recursivelyReading:(BOOL)recursivelyReading {
    // 啥都没有，不跳转
    NSInteger imageFilesCount = 0;
    if (recursivelyReading) {
        imageFilesCount = [GYFileManager allFilePathsInFolder:folderPath extensions:[PLAppManager defaultManager].mimeImageTypes].count;
    } else {
        imageFilesCount = [GYFileManager filePathsInFolder:folderPath extensions:[PLAppManager defaultManager].mimeImageTypes].count;
    }
    if (imageFilesCount == 0) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@ 内没有可用项目", folderPath.lastPathComponent]];
        return PLNavigationTypeNone;
    }
    
    UIViewController *vc = nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        vc = [[PLPhotoViewController alloc] initWithNibName:@"PLPhotoViewController" bundle:nil];
        ((PLPhotoViewController *)vc).folderPath = folderPath;
        ((PLPhotoViewController *)vc).recursivelyReading = recursivelyReading;
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        vc = [[PLPhotoPhoneViewController alloc] initWithNibName:@"PLPhotoPhoneViewController" bundle:nil];
        ((PLPhotoPhoneViewController *)vc).folderPath = folderPath;
    }
    
    if (vc) {
        [[self currentNavigationController] pushViewController:vc animated:YES];
        return PLNavigationTypePhoto;
    } else {
        [SVProgressHUD showInfoWithStatus:@"设备类型不正确"];
        return PLNavigationTypeNone;
    }
}

#pragma mark - Tools
+ (nullable UIWindow *)currentWindow {
    NSArray<__kindof UIWindow *> *windows = [UIApplication sharedApplication].windows;
    if (windows.count > 0) {
        if ([windows.firstObject isMemberOfClass:[UIWindow class]]) {
            return windows.firstObject;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}
+ (nullable UINavigationController *)currentNavigationController {
    UIWindow *window = [self currentWindow];
    if (!window) {
        return nil;
    }
    
    if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)window.rootViewController;
    } else {
        return nil;
    }
}

@end
