//
//  PLContentModel.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLContentModel : NSObject

@property (nonatomic, copy) NSString *itemPath;

@property (nonatomic, assign) BOOL isFolder;
@property (nonatomic, assign) NSInteger foldersCount;
@property (nonatomic, assign) NSInteger filesCount;

+ (instancetype)contentModelFromItemPath:(NSString *)itemPath;

@end

NS_ASSUME_NONNULL_END
