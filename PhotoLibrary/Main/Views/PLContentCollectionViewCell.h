//
//  PLContentCollectionViewCell.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PLContentCollectionViewCellType) {
    PLContentCollectionViewCellTypeNormal,
    PLContentCollectionViewCellTypeEdit,
    PLContentCollectionViewCellTypeEditSelect,
};

typedef NS_ENUM(NSUInteger, PLContentCellFileStatus) {
    PLContentCellFileStatusUnspecified = 0, // 未指定, self.file == nil
    PLContentCellFileStatusSpecified = 1, // 已指定, self.file != nil
    
    PLContentCellFileStatusMetadata = 10, // 分割线
    PLContentCellFileStatusReadingMetadata = 11, // meta-data 读取中
    PLContentCellFileStatusReadMetadataSuccess = 12, // meta-data 读取成功
    PLContentCellFileStatusReadMetadataFailure = 13, // meta-data 读取失败
    
    PLContentCellFileStatusOpenFile = 20, // 分割线
    PLContentCellFileStatusOpeningFile = 21, // 文件 打开中
    PLContentCellFileStatusOpenFileSuccess = 22, // 文件 打开成功
    PLContentCellFileStatusOpenFileFailure = 23, // 文件 打开失败
    
    PLContentCellFileStatusContent = 30, // 分割线
    PLContentCellFileStatusReadingContent = 31, // 文件内容 读取中
    PLContentCellFileStatusReadContentSuccess = 32, // 文件内容 读取成功
    PLContentCellFileStatusReadContentFailure = 33, // 文件内容 读取失败
    
    PLContentCellFileStatusFolder = 100, // 文件夹, 不用读取
};

NS_ASSUME_NONNULL_BEGIN

@interface PLContentCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) SMBFile *file;
@property(nonatomic, assign) PLContentCollectionViewCellType cellType;

@property (nonatomic, assign, readonly) PLContentCellFileStatus fileStatus;

@end

NS_ASSUME_NONNULL_END
