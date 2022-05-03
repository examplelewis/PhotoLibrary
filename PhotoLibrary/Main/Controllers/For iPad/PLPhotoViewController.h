//
//  PLPhotoViewController.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/27.
//

#import "PLViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLPhotoViewController : PLViewController

@property (nonatomic, copy) NSString *folderPath;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL recursivelyReading; // 是否递归文件夹，默认为NO

@end

NS_ASSUME_NONNULL_END
