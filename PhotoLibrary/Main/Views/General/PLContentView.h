//
//  PLContentView.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/3.
//

#import <UIKit/UIKit.h>

#import "PLContentViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLContentViewDelegate <NSObject>

@optional

@end

@interface PLContentView : UIView

@property (nonatomic, strong, readonly) PLContentViewModel *viewModel;
@property (nonatomic, weak) id<PLContentViewDelegate> delegate;

#pragma mark - Lifecycle
- (instancetype)initWithFolderPath:(NSString *)folderPath;

@end

NS_ASSUME_NONNULL_END
