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

NS_ASSUME_NONNULL_BEGIN

@interface PLContentCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *contentPath;
@property (nonatomic, assign) BOOL isFolder;
@property (nonatomic, assign) PLContentCollectionViewCellType cellType;

@end

NS_ASSUME_NONNULL_END
