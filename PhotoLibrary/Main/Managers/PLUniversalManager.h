//
//  PLUniversalManager.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/24.
//

#import <Foundation/Foundation.h>

static CGFloat const PLRowColumnSpacing = 12.0f;
static NSInteger const PLColumnsPerRow = 4;
static NSInteger const PLFolderColumnsPerRow = 8;

NS_ASSUME_NONNULL_BEGIN

@interface PLUniversalManager : NSObject

@property (nonatomic, assign) CGFloat rowColumnSpacing;
@property (nonatomic, assign) NSInteger columnsPerRow;
@property (nonatomic, assign) UIEdgeInsets flowLayoutSectionInset;
@property (nonatomic, assign) BOOL directlyJumpPhoto;

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - File Ops
+ (void)createFolders;
- (void)trashContentsAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion;
- (void)restoreContentsAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion;
- (void)deleteContentsAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion;
- (void)moveContentsToMixWorksAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion;
- (void)moveContentsToEditWorksAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion;
- (void)moveContentsToOtherWorksAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion;
+ (NSSortDescriptor *)fileAscendingSortDescriptorWithKey:(NSString *)key;

#pragma mark - Tools
+ (CGSize)imageSizeOfFilePath:(NSString *)filePath;
+ (NSString *)nonConflictFilePathForFilePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
