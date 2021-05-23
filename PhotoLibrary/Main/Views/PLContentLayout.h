//
//  PLContentLayout.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLContentLayout;
@protocol PLContentLayoutDelegate <NSObject>

- (CGFloat)layout:(PLContentLayout *)layout widthForLayoutAtIndexPath:(NSIndexPath *)indexPath withItemHeight:(CGFloat)itemHeight;

@end

@interface PLContentLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, assign) UIEdgeInsets sectionInsets;

@property (nonatomic, weak) id<PLContentLayoutDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
