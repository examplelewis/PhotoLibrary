//
//  PLPhotoMainCellView.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLPhotoMainCellView : UIView

@property (nonatomic, copy) NSString *filePath;

- (void)resetScale;

@end

NS_ASSUME_NONNULL_END
