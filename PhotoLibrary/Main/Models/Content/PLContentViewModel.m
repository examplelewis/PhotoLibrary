//
//  PLContentViewModel.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/3.
//

#import "PLContentViewModel.h"

#import "PLContentModel.h"

@interface PLContentViewModel ()

@property (nonatomic, copy) NSString *folderPath;

@property (nonatomic, copy) NSArray<PLContentModel *> *folders;
@property (nonatomic, copy) NSArray<PLContentModel *> *files;
@property (nonatomic, strong) NSMutableArray<PLContentModel *> *selects;

@property (nonatomic, assign) BOOL operatingFiles; // 是否正在进行文件操作

@property (nonatomic, strong) NSIndexPath *shiftModeStartIndexPath;

@end

@implementation PLContentViewModel

#pragma mark - Lifecycle
- (instancetype)initWithFolderPath:(NSString *)folderPath {
    self = [super init];
    if (self) {
        self.folderPath = folderPath.copy;
        
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
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        
        [self _refreshItems];
        
        if ([self.delegate respondsToSelector:@selector(viewModelDidFinishRefreshingItems)]) {
            [self.delegate viewModelDidFinishRefreshingItems];
        }
    });
}
- (void)_refreshItems {
    if (self.recursivelyReading) {
        self.folders = @[];
        
        NSArray *filePaths = [GYFileManager allFilePathsInFolder:self.folderPath extensions:[PLAppManager defaultManager].mimeImageTypes];
        filePaths = [filePaths sortedArrayUsingDescriptors:@[[PLUniversalManager fileAscendingSortDescriptorWithKey:@"self"]]];
        self.files = [filePaths bk_map:^PLContentModel *(NSString *filePath) {
            return [PLContentModel contentModelFromItemPath:filePath];
        }];
    } else {
        NSArray *folderPaths = [GYFileManager folderPathsInFolder:self.folderPath];
        folderPaths = [folderPaths sortedArrayUsingDescriptors:@[[PLUniversalManager fileAscendingSortDescriptorWithKey:@"self"]]];
        self.folders = [folderPaths bk_map:^PLContentModel *(NSString *folderPath) {
            return [PLContentModel contentModelFromItemPath:folderPath];
        }];
        
        NSArray *filePaths = [GYFileManager filePathsInFolder:self.folderPath extensions:[PLAppManager defaultManager].mimeImageTypes];
        filePaths = [filePaths sortedArrayUsingDescriptors:@[[PLUniversalManager fileAscendingSortDescriptorWithKey:@"self"]]];
        self.files = [filePaths bk_map:^PLContentModel *(NSString *filePath) {
            return [PLContentModel contentModelFromItemPath:filePath];
        }];
    }
    
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
    
    if ([self.delegate respondsToSelector:@selector(viewModelDidFinishOperatingFiles)]) {
        [self.delegate viewModelDidFinishOperatingFiles];
    }
}

#pragma mark - Model
- (PLContentModel *)folderModelAtIndex:(NSInteger)index {
    if (index >= self.folders.count) {
        return nil;
    }
    
    return self.folders[index];
}
- (PLContentModel *)fileModelAtIndex:(NSInteger)index {
    if (index >= self.files.count) {
        return nil;
    }
    
    return self.files[index];
}

#pragma mark - Select Items
- (BOOL)isSelectedForModel:(PLContentModel *)model {
    return [self.selects indexOfObject:model] != NSNotFound;
}
- (void)removeAllSelectItems {
    [self.selects removeAllObjects];
}
- (void)selectAllItems:(BOOL)selectAll {
    [self.selects removeAllObjects];
    if (selectAll) {
        [self.selects addObjectsFromArray:self.folders];
        [self.selects addObjectsFromArray:self.files];
    }
}
- (void)addSelectItem:(PLContentModel *)model {
    if ([self isSelectedForModel:model]) {
        return;
    }
    
    [self.selects addObject:model];
}
- (void)removeSelectItem:(PLContentModel *)model {
    if (![self isSelectedForModel:model]) {
        return;
    }
    
    [self.selects removeObject:model];
}

#pragma mark - Move Select Items
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
    [[PLUniversalManager defaultManager] moveContentsToMixWorksAtPaths:[self.selects valueForKey:@"itemPath"] completion:^{
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
    [[PLUniversalManager defaultManager] moveContentsToEditWorksAtPaths:[self.selects valueForKey:@"itemPath"] completion:^{
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
    [[PLUniversalManager defaultManager] moveContentsToOtherWorksAtPaths:[self.selects valueForKey:@"itemPath"] completion:^{
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
    [[PLUniversalManager defaultManager] trashContentsAtPaths:[self.selects valueForKey:@"itemPath"] completion:^{
        @strongify(self);
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"已将%ld个项目移动到废纸篓", self.selects.count]];
        [self refreshAfterOperatingFiles];
    }];
}

#pragma mark - Folder
- (BOOL)canMergeFolder {
    if (self.selects.count <= 1) {
        return NO;
    }
    
    BOOL foundFile = NO;
    for (NSInteger i = 0; i < self.selects.count; i++) {
        if (!self.selects[i].isFolder) {
            foundFile = YES;
            break;
        }
    }
    
    return !foundFile;
}
- (void)mergeFolder {
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        // 创建不会冲突的合并文件夹
        NSString *newFolderName = [NSString stringWithFormat:@"%@ 合并", self.selects.firstObject.itemPath.lastPathComponent];
        NSString *newFolderPath = [self.folderPath stringByAppendingPathComponent:newFolderName];
        newFolderPath = [GYFileManager nonConflictFilePathForFilePath:newFolderPath];
        [GYFileManager createFolderAtPath:newFolderPath];
        
        // 移动文件
        for (NSInteger i = 0; i < self.selects.count; i++) {
            NSArray *filePaths = [GYFileManager filePathsInFolder:self.selects[i].itemPath];
            for (NSInteger j = 0; j < filePaths.count; j++) {
                NSString *filePath = filePaths[j];
                NSString *newFilePath = [newFolderPath stringByAppendingPathComponent:filePath.lastPathComponent];
                newFilePath = [GYFileManager nonConflictFilePathForFilePath:newFilePath];
                
                [GYFileManager moveItemFromPath:filePath toPath:newFilePath];
            }
        }
        
        // 删除原有的文件夹
        for (NSInteger i = 0; i < self.selects.count; i++) {
            [GYFileManager removeFilePath:self.selects[i].itemPath];
        }
        
        // 回调
        if ([self.delegate respondsToSelector:@selector(viewModelDidFinishMerging)]) {
            [self.delegate viewModelDidFinishMerging];
        }
    });
}
- (BOOL)canDepartFolder {
    return (self.selects.count == 1 && self.selects.firstObject.isFolder);
}
- (void)departFolderByNumber:(NSInteger)number {
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        NSArray *filePaths = [GYFileManager filePathsInFolder:self.selects.firstObject.itemPath];
        if (filePaths.count <= number) {
            [SVProgressHUD showInfoWithStatus:@"选中的文件夹内文件数量小于输入的数字，已忽略"];
            return;
        }
        
        NSInteger loopTimes = ceilf(filePaths.count * 1.0f / number);
        
        // 创建文件夹
        for (NSInteger i = 0; i < loopTimes; i++) {
            NSString *folderPath = [self.selects.firstObject.itemPath stringByAppendingFormat:@" %ld", i + 1];
            [GYFileManager createFolderAtPath:folderPath];
        }
        
        // 移动文件
        for (NSInteger i = 0; i < filePaths.count; i++) {
            NSInteger loopTime = floorf(i * 1.0f / number);
            NSString *newFolderPath = [self.selects.firstObject.itemPath stringByAppendingFormat:@" %ld", loopTime + 1];
            
            NSString *filePath = filePaths[i];
            NSString *newFilePath = [newFolderPath stringByAppendingPathComponent:filePath.lastPathComponent];
            
            [GYFileManager moveItemFromPath:filePath toPath:newFilePath];
        }
        
        // 删除原有的文件夹
        [GYFileManager removeFilePath:self.selects.firstObject.itemPath];
        
        // 回调
        if ([self.delegate respondsToSelector:@selector(viewModelDidFinishDeparting)]) {
            [self.delegate viewModelDidFinishDeparting];
        }
    });
}

#pragma mark - View All
- (BOOL)canViewAll {
    return (self.selects.count == 1 && self.selects.firstObject.isFolder);
}
- (PLContentModel *)viewAllModel {
    return self.selects.firstObject;
}

#pragma mark - Shift Mode
- (void)shiftModeTapIndexPath:(NSIndexPath *)indexPath withModel:(nonnull PLContentModel *)model {
    if (!self.shiftModeStartIndexPath) {
        [self addSelectItem:model];
        self.shiftModeStartIndexPath = indexPath;
        
        return;
    }
    
    if (self.shiftModeStartIndexPath.section != indexPath.section) {
        [SVProgressHUD showInfoWithStatus:@"不支持跨Section的Shift选择"];
        return;
    }
    
    if (self.shiftModeStartIndexPath.row == indexPath.row) {
        [self removeSelectItem:model];
        self.shiftModeStartIndexPath = nil;
        
        [self _switchShiftMode];
        
        return;
    }
    
    NSInteger shiftStart = MIN(self.shiftModeStartIndexPath.row, indexPath.row);
    NSInteger shiftEnd = MAX(self.shiftModeStartIndexPath.row, indexPath.row);
    BOOL allSelected = [self _isAllSelectedInShiftModeBetween:shiftStart and:shiftEnd isFolder:model.isFolder];
    [self _processModelsFrom:shiftStart to:shiftEnd allSelectd:allSelected isFolder:model.isFolder];
    [self _switchShiftMode];
}
- (BOOL)_isAllSelectedInShiftModeBetween:(NSInteger)start and:(NSInteger)end isFolder:(BOOL)isFolder {
    BOOL allSelected = YES;
    for (NSInteger i = start; i <= end; i++) {
        PLContentModel *model;
        if (isFolder) {
            model = self.folders[i];
        } else {
            model = self.files[i];
        }
        
        if (![self isSelectedForModel:model]) {
            allSelected = NO;
            break;
        }
    }
    
    return allSelected;
}
- (void)_processModelsFrom:(NSInteger)shiftStart to:(NSInteger)shiftEnd allSelectd:(BOOL)allSelected isFolder:(BOOL)isFolder {
    for (NSInteger i = shiftStart; i <= shiftEnd; i++) {
        PLContentModel *model;
        if (isFolder) {
            model = self.folders[i];
        } else {
            model = self.files[i];
        }
        
        if (allSelected) {
            [self removeSelectItem:model];
        } else {
            [self addSelectItem:model];
        }
    }
}
- (void)_switchShiftMode {
    self.shiftMode = !self.shiftMode;
    
    if ([self.delegate respondsToSelector:@selector(viewModelDidSwitchShiftMode)]) {
        [self.delegate viewModelDidSwitchShiftMode];
    }
}

#pragma mark - Tools
- (void)cleanSDWebImageCache {
    for (NSInteger i = 0; i < self.files.count; i++) {
        [[SDImageCache sharedImageCache] removeImageFromMemoryForKey:self.files[i].itemPath];
    }
}

#pragma mark - Getter
- (NSInteger)foldersCount {
    _foldersCount = self.folders.count;
    return _foldersCount;
}
- (NSInteger)filesCount {
    _filesCount = self.files.count;
    return _filesCount;
}
- (NSInteger)selectsCount {
    _selectsCount = self.selects.count;
    return _selectsCount;
}

#pragma mark - Setter
- (void)setFolderPath:(NSString *)folderPath {
    _folderPath = folderPath.copy;
    
    if ([folderPath hasPrefix:[PLAppManager defaultManager].trashFolderPath]) {
        _folderType = PLContentFolderTypeTrash;
    } else if ([folderPath hasPrefix:[PLAppManager defaultManager].mixWorksFolderPath]) {
        _folderType = PLContentFolderTypeMixWorks;
    } else if ([folderPath hasPrefix:[PLAppManager defaultManager].editWorksFolderPath]) {
        _folderType = PLContentFolderTypeEditWorks;
    } else {
        _folderType = PLContentFolderTypeNormal;
    }
}
- (void)setShiftMode:(BOOL)shiftMode {
    if (_shiftMode == shiftMode) {
        return;
    }
    
    _shiftMode = shiftMode;
    
    if (!shiftMode) {
        self.shiftModeStartIndexPath = nil;
    }
}

@end
