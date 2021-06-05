//
//  PLUniversalManager.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/24.
//

#import "PLUniversalManager.h"

@implementation PLUniversalManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static PLUniversalManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[PLUniversalManager alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _rowColumnSpacing = PLRowColumnSpacing;
        _columnsPerRow = PLColumnsPerRow;
        _directlyJumpPhoto = [[NSUserDefaults standardUserDefaults] boolForKey:PLDirectlyJumpUserDefaultsKey]; // 是否直接跳转到图片页从UserDefaults里读取
    }
    
    return self;
}

#pragma mark - Getter
- (UIEdgeInsets)flowLayoutSectionInset {
    _flowLayoutSectionInset = UIEdgeInsetsMake(self.rowColumnSpacing, self.rowColumnSpacing, self.rowColumnSpacing, self.rowColumnSpacing);
    return _flowLayoutSectionInset;
}

#pragma mark - Setter
- (void)setColumnsPerRow:(NSInteger)columnsPerRow {
    if (_columnsPerRow == columnsPerRow) {
        return;
    }
    
    _columnsPerRow = columnsPerRow;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PLColumnPerRowSliderValueChanged object:nil];
}

#pragma mark - File Ops
+ (void)createFolders {
    // 创建废纸篓文件夹
    [GYFileManager createFolderAtPath:[GYSettingManager defaultManager].trashFolderPath];
    
    // 创建混合作品文件夹
    [GYFileManager createFolderAtPath:[GYSettingManager defaultManager].mixWorksFolderPath];
    
    // 创建编辑作品文件夹及其子文件夹
    [GYFileManager createFolderAtPath:[GYSettingManager defaultManager].editWorksFolderPath];
    [GYFileManager createFolderAtPath:[GYSettingManager defaultManager].editWorksEditFolderPath];
    [GYFileManager createFolderAtPath:[GYSettingManager defaultManager].editWorksOriginFolderPath];
}
- (void)trashContentsAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < contentPaths.count; i++) {
            NSString *contentPath = contentPaths[i];
            NSString *targetPath = [contentPath stringByReplacingOccurrencesOfString:[GYSettingManager defaultManager].documentPath withString:[GYSettingManager defaultManager].trashFolderPath];
            NSString *targetFolderPath = targetPath.stringByDeletingLastPathComponent;
            
            [GYFileManager createFolderAtPath:targetFolderPath];
            [GYFileManager moveItemFromPath:contentPath toPath:targetPath];
        }
        
        if (completion) {
            completion();
        }
    });
}
- (void)restoreContentsAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < contentPaths.count; i++) {
            NSString *contentPath = contentPaths[i];
            NSString *targetPath = [contentPath stringByReplacingOccurrencesOfString:[GYSettingManager defaultManager].trashFolderPath withString:[GYSettingManager defaultManager].documentPath];
            NSString *targetFolderPath = targetPath.stringByDeletingLastPathComponent;
            
            [GYFileManager createFolderAtPath:targetFolderPath];
            [GYFileManager moveItemFromPath:contentPath toPath:targetPath];
        }
        
        if (completion) {
            completion();
        }
    });
}
- (void)deleteContentsAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < contentPaths.count; i++) {
            [GYFileManager removeFilePath:contentPaths[i]];
        }
        
        if (completion) {
            completion();
        }
    });
}
- (void)moveContentsToMixWorksAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < contentPaths.count; i++) {
            NSString *contentPath = contentPaths[i];
            NSString *targetPath = [contentPath stringByReplacingOccurrencesOfString:[GYSettingManager defaultManager].documentPath withString:[GYSettingManager defaultManager].mixWorksFolderPath];
            NSString *targetFolderPath = targetPath.stringByDeletingLastPathComponent;
            
            [GYFileManager createFolderAtPath:targetFolderPath];
            [GYFileManager moveItemFromPath:contentPath toPath:targetPath];
        }
        
        if (completion) {
            completion();
        }
    });
}
+ (NSSortDescriptor *)fileAscendingSortDescriptorWithKey:(NSString *)key {
    return [NSSortDescriptor sortDescriptorWithKey:key ascending:YES selector:@selector(localizedStandardCompare:)];
}

#pragma mark - Tools
+ (CGSize)imageSizeOfFilePath:(NSString *)filePath {
    NSURL *imageFileURL = [NSURL fileURLWithPath:filePath];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageFileURL, NULL);
    if (imageSource == NULL) {
        return CGSizeZero;
    }
    
    CGFloat width = 0.0f, height = 0.0f;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
    
    CFRelease(imageSource);
    
    if (imageProperties != NULL) {
        CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        if (widthNum != NULL) {
            CFNumberGetValue(widthNum, kCFNumberCGFloatType, &width);
        }
        CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        if (heightNum != NULL) {
            CFNumberGetValue(heightNum, kCFNumberCGFloatType, &height);
        }

        // Check orientation and flip size if required
        CFNumberRef orientationNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyOrientation);
        if (orientationNum != NULL) {
            int orientation;
            CFNumberGetValue(orientationNum, kCFNumberIntType, &orientation);
            if (orientation > 4) {
                CGFloat temp = width;
                width = height;
                height = temp;
            }
        }

        CFRelease(imageProperties);
    }
    
    return CGSizeMake(width, height);
}

@end
