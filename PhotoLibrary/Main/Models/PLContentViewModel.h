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

@property (nonatomic, copy) NSArray<NSString *> *folders;
@property (nonatomic, copy) NSArray<NSString *> *files;
@property (nonatomic, assign) BOOL bothFoldersAndFiles;
@property (nonatomic, strong) NSMutableArray<NSString *> *selects;

@property (nonatomic, assign) BOOL operatingFiles;

- (instancetype)initWithFolderPath:(NSString *)folderPath;

- (void)refreshItems;

- (void)cleanSDWebImageCache;

#pragma mark - Move SelectItems
- (void)moveSelectItemsToMixWorks;
- (void)moveSelectItemsToEditWorks;
- (void)moveSelectItemsToOtherWorks;
- (void)moveSelectItemsToTrash;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
