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

@end
