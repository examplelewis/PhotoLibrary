//
//  PLContentViewModel.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/3.
//

#import "PLContentViewModel.h"

@implementation PLContentViewModel

#pragma mark - Lifecycle
- (instancetype)initWithFolderPath:(NSString *)folderPath {
    self = [super init];
    if (self) {
        _folderPath = folderPath.copy;
        
        self.folders = @[];
        self.files = @[];
        self.bothFoldersAndFiles = NO;
        self.selects = [NSMutableArray array];
        
        self.operatingFiles = NO;
    }
    
    return self;
}

#pragma mark - Refreshing
- (void)refreshItems {
    self.folders = [GYFileManager folderPathsInFolder:self.folderPath];
    self.folders = [self.folders sortedArrayUsingDescriptors:@[[PLUniversalManager fileAscendingSortDescriptorWithKey:@"self"]]];
    self.files = [GYFileManager filePathsInFolder:self.folderPath extensions:[GYSettingManager defaultManager].mimeImageTypes];
    self.files = [self.files sortedArrayUsingDescriptors:@[[PLUniversalManager fileAscendingSortDescriptorWithKey:@"self"]]];
    self.bothFoldersAndFiles = (self.folders.count > 0 && self.files.count > 0);
}
- (void)refreshAfterOperatingFiles {
    NSMutableArray *folders = [self.folders mutableCopy];
    [folders removeObjectsInArray:self.selects];
    self.folders = folders.copy;
    
    NSMutableArray *files = [self.files mutableCopy];
    [files removeObjectsInArray:self.selects];
    self.files = files.copy;
    
    [self.selects removeAllObjects];
    
    self.operatingFiles = NO;
    
    @weakify(self);
    dispatch_main_async_safe(^{
        @strongify(self);
        
//        [self.collectionView reloadData];
//
//        [self setupTitle];
//        [self setupAllBBI];
//        [self setupNavigationBarItems];
    });
}


- (void)cleanSDWebImageCache {
    for (NSInteger i = 0; i < self.files.count; i++) {
        [[SDImageCache sharedImageCache] removeImageFromMemoryForKey:self.files[i]];
    }
}



#pragma mark - Move SelectItems
- (void)moveSelectItemsToMixWorks {
    if (self.operatingFiles) {
        return;
    }
    if (self.selects.count == 0) {
        return;
    }
    
    [SVProgressHUD show];
    self.operatingFiles = YES;
    @weakify(self);
    [[PLUniversalManager defaultManager] moveContentsToMixWorksAtPaths:self.selects completion:^{
        @strongify(self);
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"已将%ld个项目移动到混合作品", self.selects.count]];
        [self refreshAfterOperatingFiles];
    }];
}
- (void)moveSelectItemsToEditWorks {
    if (self.operatingFiles) {
        return;
    }
    if (self.selects.count == 0) {
        return;
    }
    
    // Gif图片不可编辑
    [self.selects filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable filePath, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![filePath.pathExtension.lowercaseString isEqualToString:@"gif"];
    }]];
    
    [SVProgressHUD show];
    self.operatingFiles = YES;
    @weakify(self);
    [[PLUniversalManager defaultManager] moveContentsToEditWorksAtPaths:self.selects completion:^{
        @strongify(self);
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"已将%ld个项目移动到编辑作品", self.selects.count]];
        [self refreshAfterOperatingFiles];
    }];
}
- (void)moveSelectItemsToOtherWorks {
    if (self.operatingFiles) {
        return;
    }
    if (self.selects.count == 0) {
        return;
    }
    
    [SVProgressHUD show];
    self.operatingFiles = YES;
    @weakify(self);
    [[PLUniversalManager defaultManager] moveContentsToOtherWorksAtPaths:self.selects completion:^{
        @strongify(self);
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"已将%ld个项目移动到其他作品", self.selects.count]];
        [self refreshAfterOperatingFiles];
    }];
}
- (void)moveSelectItemsToTrash {
    if (self.operatingFiles) {
        return;
    }
    if (self.selects.count == 0) {
        return;
    }
    
    [SVProgressHUD show];
    self.operatingFiles = YES;
    @weakify(self);
    [[PLUniversalManager defaultManager] trashContentsAtPaths:self.selects completion:^{
        @strongify(self);
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"已将%ld个项目移动到废纸篓", self.selects.count]];
        [self refreshAfterOperatingFiles];
    }];
}

@end
