//
//  GYSettingManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "GYSettingManager.h"

@implementation GYSettingManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static GYSettingManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self updatePaths];
        [self updatePreferences];
    }
    
    return self;
}

#pragma mark - Configure
- (void)updateAppDelegate:(AppDelegate *)appDelegate {
    _appDelegate = appDelegate;
}
- (void)updateViewController:(ViewController *)viewController {
    _viewController = viewController;
}
- (void)updateNavigationController:(UINavigationController *)navigationController {
    _navigationController = navigationController;
}
- (void)updatePaths {
    _homePath = NSHomeDirectory();
    _documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    _libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    _cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    _applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
    _preferencePath = NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES).firstObject;
    _tempPath = NSTemporaryDirectory();
    
    _trashFolderPath = [self pathOfContentInDocumentFolder:@"~~废纸篓"];
    NSLog(@"trashFolderPath: %@", self.trashFolderPath);
    
    _mixWorksFolderPath = [self pathOfContentInDocumentFolder:@"~~混合作品"];
    _editWorksFolderPath = [self pathOfContentInDocumentFolder:@"~~编辑作品"];
    _editWorksEditFolderPath = [self.editWorksFolderPath stringByAppendingPathComponent:@"编辑文件"];
    _editWorksOriginFolderPath = [self.editWorksFolderPath stringByAppendingPathComponent:@"源文件"];
}
- (void)updatePreferences {
    _mimeImageTypes = @[@"jpg", @"jpeg", @"png", @"gif"];
    _mimeVideoTypes = @[];
    _mimeImageAndVideoTypes = [self.mimeImageTypes arrayByAddingObjectsFromArray:self.mimeVideoTypes];
}

#pragma mark - Types
- (BOOL)isImageAtFilePath:(NSString *)filePath {
    BOOL isImage = NO;
    for (NSString *extension in self.mimeImageTypes) {
        isImage = [filePath.pathExtension caseInsensitiveCompare:extension];
        if (isImage) {
            break;
        }
    }
    
    return isImage;
}
- (BOOL)isVideoAtFilePath:(NSString *)filePath {
    BOOL isVideo = NO;
    for (NSString *extension in self.mimeVideoTypes) {
        isVideo = [filePath.pathExtension caseInsensitiveCompare:extension];
        if (isVideo) {
            break;
        }
    }
    
    return isVideo;
}

#pragma mark - Paths
- (NSString *)pathOfContentInDocumentFolder:(NSString *)component {
    return [self.documentPath stringByAppendingPathComponent:component];
}
- (NSString *)pathOfContentInCachesFolder:(NSString *)component {
    return [self.cachesPath stringByAppendingPathComponent:component];
}

@end
