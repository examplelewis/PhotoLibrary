//
//  PLNavigationManager.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/6/5.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PLNavigationType) {
    PLNavigationTypeNone,
    PLNavigationTypeContent,
    PLNavigationTypePhoto
};

NS_ASSUME_NONNULL_BEGIN

@interface PLNavigationManager : NSObject

+ (PLNavigationType)navigateToContentAtFolderPath:(NSString *)folderPath;
+ (PLNavigationType)navigateToPhotoAtFolderPath:(NSString *)folderPath index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
