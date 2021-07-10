//
//  PLContentView.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/3.
//

#import <UIKit/UIKit.h>

#import "PLContentViewModel.h"

@class PLContentView;

NS_ASSUME_NONNULL_BEGIN

@protocol PLContentViewDelegate <NSObject>

@optional
// 刷新项目成功后的回调，这个时候应该刷新VC的Title
- (void)didFinishRefreshingItemsInContentView:(PLContentView *)contentView;
// 选择了某个项目之后的回调，这个时候应该刷新VC的Title和NavigationBar
- (void)contentView:(PLContentView *)contentView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
// viewModel完成文件操作的回调
- (void)contentViewModelDidFinishOperatingFiles:(PLContentView *)contentView;

@end

@interface PLContentView : UIView

@property (nonatomic, strong, readonly) PLContentViewModel *viewModel;
@property (nonatomic, weak) id<PLContentViewDelegate> delegate;

@property (nonatomic, assign) BOOL selectingMode;

#pragma mark - Lifecycle
- (instancetype)initWithFolderPath:(NSString *)folderPath;

#pragma mark - Refresh
- (void)setupCollectionViewFlowLayout;
- (void)refreshWhenViewDidAppear;
- (void)reloadCollectionView;

@end

NS_ASSUME_NONNULL_END
