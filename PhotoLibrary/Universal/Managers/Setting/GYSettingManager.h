//
//  GYSettingManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate;
@class ViewController;

NS_ASSUME_NONNULL_BEGIN

@interface GYSettingManager : NSObject

@property (nonatomic, strong, readonly) AppDelegate *appDelegate;
//@property (nonatomic, strong, readonly) UIWindow *keyWindow;
@property (nonatomic, strong, readonly) UINavigationController *navigationController;
@property (nonatomic, strong, readonly) ViewController *viewController;

@property (nonatomic, strong, readonly) NSString *homePath;
@property (nonatomic, strong, readonly) NSString *documentPath;
@property (nonatomic, strong, readonly) NSString *libraryPath;
@property (nonatomic, strong, readonly) NSString *cachesPath;
@property (nonatomic, strong, readonly) NSString *applicationSupportPath;
@property (nonatomic, strong, readonly) NSString *preferencePath;
@property (nonatomic, strong, readonly) NSString *tempPath;

@property (nonatomic, strong, readonly) NSString *trashFolderPath;
@property (nonatomic, strong, readonly) NSString *mixWorksFolderPath; // 混合作品文件夹
@property (nonatomic, strong, readonly) NSString *editWorksFolderPath; // 编辑作品文件夹
@property (nonatomic, strong, readonly) NSString *editWorksOriginFolderPath; // 编辑作品[源文件]文件夹
@property (nonatomic, strong, readonly) NSString *editWorksEditFolderPath; // 编辑作品[编辑文件]文件夹

@property (nonatomic, strong, readonly) NSArray *mimeImageTypes;
@property (nonatomic, strong, readonly) NSArray *mimeVideoTypes;
@property (nonatomic, strong, readonly) NSArray *mimeImageAndVideoTypes;

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Configure
- (void)updateAppDelegate:(AppDelegate *)appDelegate;
- (void)updateViewController:(ViewController *)viewController;
- (void)updateNavigationController:(UINavigationController *)navigationController;

#pragma mark - Types
- (BOOL)isImageAtFilePath:(NSString *)filePath;
- (BOOL)isVideoAtFilePath:(NSString *)filePath;

#pragma mark - Paths
- (NSString *)pathOfContentInDocumentFolder:(NSString *)component;
- (NSString *)pathOfContentInCachesFolder:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
