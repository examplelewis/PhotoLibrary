//
//  PLUniversalHeader.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/24.
//

#ifndef PLUniversalHeader_h
#define PLUniversalHeader_h

typedef NS_ENUM(NSUInteger, PLContentFolderType) {
    PLContentFolderTypeNormal,
    PLContentFolderTypeTrash,
    PLContentFolderTypeMixWorks,
    PLContentFolderTypeEditWorks,
};


static CGFloat const PLSafeAreaBottom = 20.0f;
static CGFloat const PLNorchPhoneSafeAreaTop = 44.0f;
static CGFloat const PLNorchPhoneSafeAreaBottom = 34.0f;
static CGFloat const PLNavigationBarHeight = 44.0f;
static CGFloat const PLScrollViewIndicatorMargin = 9.0f; // 滚动条的高度+间距一共为9

static CGFloat const PLPhotoMainScrollViewMarginH = 50.f;
static NSInteger const PLPhotoMainScrollViewPreloadCountPerSide = 5; // mainScrollView前后预加载的数量

static CGFloat const PLPhotoBottomScrollViewHeight = 192.f;
static CGFloat const PLPhotoBottomScrollViewCellViewSpacingH = 5.0f;
static NSInteger const PLPhotoBottomScrollViewPreloadCountPerSide = 20; // bottomScrollView前后预加载的数量


#define screenWidth (MAX(kScreenWidth, kScreenHeight))
#define screenHeight (MIN(kScreenWidth, kScreenHeight))

#endif /* PLUniversalHeader_h */
