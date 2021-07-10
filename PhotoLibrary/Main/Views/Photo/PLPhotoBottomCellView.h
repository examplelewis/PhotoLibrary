//
//  PLPhotoBottomCellView.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/5/29.
//

#import <UIKit/UIKit.h>
#import "PLPhotoFileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLPhotoBottomCellView : UIView

@property (nonatomic, assign) NSInteger plIndex; // 最开始读取的顺序
@property (nonatomic, strong) PLPhotoFileModel *fileModel;

@end

NS_ASSUME_NONNULL_END