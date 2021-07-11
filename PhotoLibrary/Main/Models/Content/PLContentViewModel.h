//
//  PLContentViewModel.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PLContentModel;
@class PLContentViewModel;

@protocol PLContentViewModelDelegate <NSObject>

- (void)viewModelDidFinishRefreshingItems;
- (void)viewModelDidFinishOperatingFiles;
- (void)viewModelDidSwitchShiftMode;

@end

@interface PLContentViewModel : NSObject

@property (nonatomic, assign, readonly) PLContentFolderType folderType;

@property (nonatomic, assign) NSInteger foldersCount;
@property (nonatomic, assign) NSInteger filesCount;
@property (nonatomic, assign) NSInteger selectsCount;
@property (nonatomic, assign) BOOL bothFoldersAndFiles;

@property (nonatomic, assign) BOOL shiftMode;

@property (nonatomic, weak) id<PLContentViewModelDelegate> delegate;

#pragma mark - Lifecycle
- (instancetype)initWithFolderPath:(NSString *)folderPath;

#pragma mark - Refreshing
- (void)refreshItems;

#pragma mark - Model
- (nullable PLContentModel *)folderModelAtIndex:(NSInteger)index;
- (nullable PLContentModel *)fileModelAtIndex:(NSInteger)index;

#pragma mark - Select Items
- (BOOL)isSelectedForModel:(PLContentModel *)model;
- (void)removeAllSelectItems;
- (void)selectAllItems:(BOOL)selectAll;
- (void)addSelectItem:(PLContentModel *)model;
- (void)removeSelectItem:(PLContentModel *)model;

#pragma mark - Move Select Items
- (void)moveSelectItemsToMixWorks;
- (void)moveSelectItemsToEditWorks;
- (void)moveSelectItemsToOtherWorks;
- (void)moveSelectItemsToTrash;

#pragma mark - Shift Mode
- (void)shiftModeTapIndexPath:(NSIndexPath *)indexPath withModel:(PLContentModel *)model;

#pragma mark - Tools
- (void)cleanSDWebImageCache;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
