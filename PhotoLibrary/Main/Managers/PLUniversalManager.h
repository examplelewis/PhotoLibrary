//
//  PLUniversalManager.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/24.
//

#import <Foundation/Foundation.h>

static CGFloat const PLRowColumnSpacing = 8.0f;
static NSInteger const PLColumnsPerRow = 7;

NS_ASSUME_NONNULL_BEGIN

@interface PLUniversalManager : NSObject

@property (nonatomic, assign) CGFloat rowColumnSpacing;
@property (nonatomic, assign) NSInteger columnsPerRow;
@property(nonatomic, assign) UIEdgeInsets flowLayoutSectionInset;

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

@end

NS_ASSUME_NONNULL_END
