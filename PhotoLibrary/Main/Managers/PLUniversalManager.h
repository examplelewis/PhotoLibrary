//
//  PLUniversalManager.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/24.
//

#import <Foundation/Foundation.h>

static CGFloat const PLRowColumnSpacing = 12.0f;
static NSInteger const PLColumnsPerRow = 5;

NS_ASSUME_NONNULL_BEGIN

@interface PLUniversalManager : NSObject

@property (nonatomic, assign) CGFloat rowColumnSpacing;
@property (nonatomic, assign) NSInteger columnsPerRow;
@property(nonatomic, assign) UIEdgeInsets flowLayoutSectionInset;

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - File Ops
- (void)trashContentsAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion;
- (void)restoreContentsAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion;
- (void)deleteContentsAtPaths:(NSArray<NSString *> *)contentPaths completion:(nullable void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
