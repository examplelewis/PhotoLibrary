//
//  PLContentViewModel.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLContentViewModel : NSObject

@property (nonatomic, copy, readonly) NSString *folderPath;

@property (nonatomic, assign) NSInteger foldersCount;
@property (nonatomic, assign) NSInteger filesCount;
@property (nonatomic, assign) NSInteger selectsCount;

@property (nonatomic, assign) BOOL bothFoldersAndFiles;

- (instancetype)initWithFolderPath:(NSString *)folderPath;

- (void)refreshItems;

- (void)cleanSDWebImageCache;

#pragma mark - Select Items
- (BOOL)isSelectedAtItemPath:(NSString *)itemPath;
- (void)removeAllSelectItems;
- (void)selectAllItems:(BOOL)selectAll;
- (void)addSelectItem:(NSString *)itemPath;
- (void)removeSelectItem:(NSString *)itemPath;

#pragma mark - Path
- (nullable NSString *)folderPathAtIndex:(NSInteger)index;
- (nullable NSString *)filePathAtIndex:(NSInteger)index;

#pragma mark - Move SelectItems
- (void)moveSelectItemsToMixWorks;
- (void)moveSelectItemsToEditWorks;
- (void)moveSelectItemsToOtherWorks;
- (void)moveSelectItemsToTrash;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
