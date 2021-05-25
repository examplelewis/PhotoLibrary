//
//  PLContentViewController.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PLContentFolderType) {
    PLContentFolderTypeNormal,
    PLContentFolderTypeTrash,
};

NS_ASSUME_NONNULL_BEGIN

@interface PLContentViewController : UIViewController

@property (nonatomic, copy) NSString *folderPath;
@property (nonatomic, assign) PLContentFolderType folderType;

@end

NS_ASSUME_NONNULL_END
