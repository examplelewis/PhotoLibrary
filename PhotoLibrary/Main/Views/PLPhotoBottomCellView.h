//
//  PLPhotoBottomCellView.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/5/29.
//

#import <UIKit/UIKit.h>
#import "PLPhotoFileModel.h"

typedef NS_ENUM(NSUInteger, PLPhotoBottomCellViewType) {
    PLPhotoBottomCellViewTypeImage,
    PLPhotoBottomCellViewTypePlaceholderLeading,
    PLPhotoBottomCellViewTypePlaceholderTrailing,
};

NS_ASSUME_NONNULL_BEGIN

@interface PLPhotoBottomCellView : UIView

@property (nonatomic, assign) PLPhotoBottomCellViewType type;
@property (nonatomic, strong) PLPhotoFileModel *fileModel;

@end

NS_ASSUME_NONNULL_END
