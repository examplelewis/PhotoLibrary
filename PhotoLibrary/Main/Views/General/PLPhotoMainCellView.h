//
//  PLPhotoMainCellView.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/28.
//

#import <UIKit/UIKit.h>
#import "PLPhotoFileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLPhotoMainCellView : UIView

@property (nonatomic, assign) NSInteger plIndex; // 最开始读取的顺序
@property (nonatomic, strong) PLPhotoFileModel *fileModel;

- (void)resetScale;

@end

NS_ASSUME_NONNULL_END
