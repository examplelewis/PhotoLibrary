//
//  GYFileManager.m
//  MyComicView
//
//  Created by 龚宇 on 16/08/03.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "GYFileManager.h"

@implementation GYFileManager

#pragma mark - Create
+ (BOOL)createFolderAtPath:(NSString *)folderPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        return YES;
    } else {
        NSError *error;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            return YES;
        } else {
            [GYLogManager.defaultManager addErrorLogWithFormat:@"创建文件夹 %@ 时发生错误: \n%@", folderPath, error.localizedDescription];
            return NO;
        }
    }
}
+ (BOOL)createFileAtPath:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    } else {
        return [NSFileManager.defaultManager createFileAtPath:filePath contents:nil attributes:nil];
    }
}

#pragma mark - Trash
+ (BOOL)trashFilePath:(NSString *)filePath {
    return [self trashFileURL:[self fileURLFromFilePath:filePath] resultItemURL:nil];
}
+ (BOOL)trashFileURL:(NSURL *)fileURL {
    return [self trashFileURL:fileURL resultItemURL:nil];
}
+ (BOOL)trashFileURL:(NSURL *)fileURL resultItemURL:(NSURL * _Nullable)outResultingURL {
    NSError *error;
    if ([[NSFileManager defaultManager] trashItemAtURL:fileURL resultingItemURL:&outResultingURL error:&error]) {
        [GYLogManager.defaultManager addDefaultLogWithFormat:@"%@ 已经被移动到废纸篓", fileURL.path.lastPathComponent];
        return YES;
    } else {
        [GYLogManager.defaultManager addErrorLogWithFormat:@"移动文件 %@ 到废纸篓时发生错误: %@", fileURL.path.lastPathComponent, error.localizedDescription];
        return NO;
    }
}
+ (BOOL)trashItemAtURL:(NSURL *)url resultingItemURL:(NSURL * _Nullable * _Nullable)outResultingURL error:(NSError **)error {
    return [[NSFileManager defaultManager] trashItemAtURL:url resultingItemURL:outResultingURL error:error];
}

#pragma mark - Remove
+ (void)removeFilePath:(NSString *)filePath {
    [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
}
+ (void)removeFileURL:(NSURL *)fileURL {
    [NSFileManager.defaultManager removeItemAtURL:fileURL error:nil];
}
+ (void)removeFilePath:(NSString *)filePath error:(NSError **)error {
    [NSFileManager.defaultManager removeItemAtPath:filePath error:error];
}
+ (void)removeFileURL:(NSURL *)fileURL error:(NSError **)error {
    [NSFileManager.defaultManager removeItemAtURL:fileURL error:error];
}

#pragma mark - Move
+ (void)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    NSError *error;
    if (![[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:[GYFileManager removeSeparatorInPathComponentsAtItemPath:toPath] error:&error]) {
        [GYLogManager.defaultManager addErrorLogWithFormat:@"移动文件 %@ 时发生错误: %@", fromPath, error.localizedDescription];
    }
}
+ (void)moveItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL {
    [GYFileManager moveItemFromPath:[GYFileManager filePathFromFileURL:fromURL] toPath:[GYFileManager filePathFromFileURL:toURL]];
}
+ (void)moveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error {
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:[GYFileManager removeSeparatorInPathComponentsAtItemPath:toPath] error:error];
}
+ (void)moveItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL error:(NSError **)error {
    [GYFileManager moveItemFromPath:[GYFileManager filePathFromFileURL:fromURL] toPath:[GYFileManager filePathFromFileURL:toURL] error:error];
}

#pragma mark - Copy
+ (void)copyItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    NSError *error;
    if (![[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:[GYFileManager removeSeparatorInPathComponentsAtItemPath:toPath] error:&error]) {
        [GYLogManager.defaultManager addErrorLogWithFormat:@"拷贝文件 %@ 时发生错误: %@", fromPath, error.localizedDescription];
    }
}
+ (void)copyItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL {
    [GYFileManager copyItemFromPath:[GYFileManager filePathFromFileURL:fromURL] toPath:[GYFileManager filePathFromFileURL:toURL]];
}
+ (BOOL)copyItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError *__autoreleasing  _Nullable *)error {
    return [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:[GYFileManager removeSeparatorInPathComponentsAtItemPath:toPath] error:error];
}
+ (BOOL)copyItemFromURL:(NSURL *)fromURL toURL:(NSURL *)toURL error:(NSError *__autoreleasing  _Nullable *)error {
    return [GYFileManager copyItemFromPath:[GYFileManager filePathFromFileURL:fromURL] toPath:[GYFileManager filePathFromFileURL:toURL] error:error];
}

#pragma mark - File Path
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterReturnedItems:items];
    
    for (NSString *item in items) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:item];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
        
        if (!folderFlag) {
            [results addObject:filePath];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath extensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterReturnedItems:items];
    
    for (NSString *extension in extensions) {
        NSArray *filteredItems = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nonnull item, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [item.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame;
        }]];
        for (NSString *item in filteredItems) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:item];
            BOOL folderFlag = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
            
            if (!folderFlag) {
                [results addObject:filePath];
            }
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)filePathsInFolder:(NSString *)folderPath withoutExtensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *extensionsFiles = [NSMutableArray array];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterReturnedItems:items];
    NSMutableArray<NSString *> *results = [NSMutableArray arrayWithArray:[items bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }]];
    
    for (NSString *extension in extensions) {
        NSArray *filteredItems = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nonnull item, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [item.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame;
        }]];
        for (NSString *item in filteredItems) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:item];
            BOOL folderFlag = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
            
            if (!folderFlag) {
                [extensionsFiles addObject:filePath];
            }
        }
    }
    
    [results removeObjectsInArray:extensionsFiles];
    
    return [results copy];
}
+ (NSArray<NSString *> *)folderPathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterReturnedItems:items];
    
    for (NSString *item in items) {
        NSString *folder = [folderPath stringByAppendingPathComponent:item];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)itemPathsInFolder:(NSString *)folderPath {
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterReturnedItems:items];
    return [items bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }];
}
+ (NSArray<NSString *> *)hiddenItemPathsInFolder:(NSString *)folderPath {
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterHiddenReturnedItems:items];
    return [items bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }];
}

+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *items = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterReturnedItems:items];
    
    for (NSString *item in items) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:item];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
        
        if (!folderFlag) {
            [results addObject:filePath];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath extensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *items = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterReturnedItems:items];
    
    for (NSString *extension in extensions) {
        NSArray *filteredItems = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nonnull item, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [item.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame;
        }]];
        for (NSString *item in filteredItems) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:item];
            BOOL folderFlag = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
            
            if (!folderFlag) {
                [results addObject:filePath];
            }
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)allFilePathsInFolder:(NSString *)folderPath withoutExtensions:(NSArray<NSString *> *)extensions {
    NSMutableArray<NSString *> *extensionsFiles = [NSMutableArray array];
    NSArray *items = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterReturnedItems:items];
    NSMutableArray<NSString *> *results = [NSMutableArray arrayWithArray:[items bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }]];
    
    for (NSString *extension in extensions) {
        NSArray *filteredItems = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString * _Nonnull item, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [item.pathExtension caseInsensitiveCompare:extension] == NSOrderedSame;
        }]];
        for (NSString *item in filteredItems) {
            NSString *filePath = [folderPath stringByAppendingPathComponent:item];
            BOOL folderFlag = YES;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&folderFlag];
            
            if (!folderFlag) {
                [extensionsFiles addObject:filePath];
            }
        }
    }
    
    [results removeObjectsInArray:extensionsFiles];
    
    return [results copy];
}
+ (NSArray<NSString *> *)allFolderPathsInFolder:(NSString *)folderPath {
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    NSArray *items = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterReturnedItems:items];
    
    for (NSString *item in items) {
        NSString *folder = [folderPath stringByAppendingPathComponent:item];
        BOOL folderFlag = YES;
        [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&folderFlag];
        
        if (folderFlag) {
            [results addObject:folder];
        }
    }
    
    return [results copy];
}
+ (NSArray<NSString *> *)allItemPathsInFolder:(NSString *)folderPath {
    NSArray *items = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterReturnedItems:items];
    return [items bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }];
}
+ (NSArray<NSString *> *)allHiddenItemPathsInFolder:(NSString *)folderPath {
    NSArray *items = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    items = [GYFileManager filterHiddenReturnedItems:items];
    return [items bk_map:^id(NSString *obj) {
        return [folderPath stringByAppendingPathComponent:obj];
    }];
}

#pragma mark - Attributes
+ (NSDictionary *)allAttributesOfItemAtPath:(NSString *)path {
    NSError *error;
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    return [NSDictionary dictionaryWithDictionary:dict];
}
+ (id)attribute:(NSString *)attribute ofItemAtPath:(NSString *)path {
    return [self allAttributesOfItemAtPath:path][attribute];
}
+ (unsigned long long)fileSizeAtPath:(NSString *)path {
    return [[GYFileManager attribute:NSFileSize ofItemAtPath:path] unsignedLongLongValue];
}
+ (unsigned long long)folderSizeAtPath:(NSString *)path {
    unsigned long long fileSize = 0;
    NSArray *filePaths = [GYFileManager allFilePathsInFolder:path];
    for (NSString *filePath in filePaths) {
        fileSize += [GYFileManager fileSizeAtPath:filePath];
    }

    return fileSize;
}
+ (NSString *)fileSizeDescriptionAtPath:(NSString *)path {
    return [GYFileManager sizeDescriptionFromSize:[GYFileManager fileSizeAtPath:path]];
}
+ (NSString *)folderSizeDescriptionAtPath:(NSString *)path {
    return [GYFileManager sizeDescriptionFromSize:[GYFileManager folderSizeAtPath:path]];
}
+ (NSString *)sizeDescriptionFromSize:(unsigned long long)size {
    if (size < 1024.0f) {
        return [NSString stringWithFormat:@"%lld B", size];
    }
    
    if (size / 1024.0f < 1024.0f) {
        return [NSString stringWithFormat:@"%.2f KB", size / 1024.0f];
    }
    
    if (size / 1024.0f / 1024.0f < 1024.0f) {
        return [NSString stringWithFormat:@"%.2f MB", size / 1024.0f / 1024.0f];
    }
    
    return [NSString stringWithFormat:@"%.2f GB", size / 1024.0f / 1024.0f / 1024.0f];
}

#pragma mark - Check
+ (BOOL)fileExistsAtPath:(NSString *)itemPath {
    return [[NSFileManager defaultManager] fileExistsAtPath:itemPath];
}
+ (BOOL)itemIsFolderAtPath:(NSString *)itemPath {
    BOOL folderFlag = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:itemPath isDirectory:&folderFlag];
    return folderFlag;
}
+ (BOOL)isEmptyFolderAtPath:(NSString *)folderPath {
    return [self itemPathsInFolder:folderPath].count == 0;
}

#pragma mark - Panel
+ (NSString *)pathFromOpenPanelURL:(NSURL *)URL {
    NSString *path = URL.absoluteString;
    path = [path stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    path = [path stringByRemovingPercentEncoding];
    
    return path;
}

#pragma mark - Tool
+ (NSURL *)fileURLFromFilePath:(NSString *)filePath {
    return [NSURL fileURLWithPath:filePath];
}
+ (NSString *)filePathFromFileURL:(NSURL *)fileURL {
    return fileURL.path;
}
+ (NSArray<NSURL *> *)fileURLsFromFilePaths:(NSArray<NSString *> *)filePaths {
    return [filePaths bk_map:^id(NSString *obj) {
        return [NSURL fileURLWithPath:obj];
    }];
}
+ (NSArray<NSString *> *)filePathsFromFileURLs:(NSArray<NSURL *> *)fileURLs {
    return [fileURLs bk_map:^id(NSURL *obj) {
        return obj.path;
    }];
}
+ (BOOL)fileShouldIgnore:(NSString *)fileName {
    if ([fileName.lastPathComponent hasPrefix:@"."]) {
        return YES;
    }
    if ([fileName hasSuffix:@"DS_Store"]) {
        return YES;
    }
    if ([fileName rangeOfString:@"RECYCLE.BIN" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}
+ (BOOL)hiddenFileShouldIgnore:(NSString *)fileName {
    if (![fileName.lastPathComponent hasPrefix:@"."]) {
        return YES;
    }
    if ([fileName hasSuffix:@"DS_Store"]) {
        return YES;
    }
    if ([fileName rangeOfString:@"RECYCLE.BIN" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}
+ (NSArray<NSString *> *)filterReturnedItems:(NSArray<NSString *> *)items {
    return [items bk_select:^BOOL(NSString *item) {
        return ![GYFileManager fileShouldIgnore:item];
    }];
}
+ (NSArray<NSString *> *)filterHiddenReturnedItems:(NSArray<NSString *> *)items {
    return [items bk_select:^BOOL(NSString *item) {
        return ![GYFileManager hiddenFileShouldIgnore:item];
    }];
}
+ (NSString *)removeSeparatorInPathComponentsAtItemPath:(NSString *)itemPath {
    NSString *itemPathCopy = [itemPath copy];
    NSMutableArray *itemPathCopyComponents = [NSMutableArray arrayWithArray:itemPathCopy.pathComponents];
    for (NSInteger i = 0; i < itemPathCopyComponents.count; i++) {
        if ([itemPathCopyComponents[i] containsString:@"/"] && i != 0) {
            itemPathCopyComponents[i] = [itemPathCopyComponents[i] stringByReplacingOccurrencesOfString:@"/" withString:@" "];
        }
    }
    itemPathCopy = [itemPathCopyComponents componentsJoinedByString:@"/"];
    itemPathCopy = [itemPathCopy substringFromIndex:1];
    
    return itemPathCopy;
}
+ (NSString *)nonConflictFilePathForFilePath:(NSString *)filePath {
    NSString *outputFilePath = filePath.copy;
    NSInteger i = 2;
    
    while ([GYFileManager fileExistsAtPath:outputFilePath]) {
        outputFilePath = [filePath.stringByDeletingPathExtension stringByAppendingFormat:@" %ld.%@", i, filePath.pathExtension];
        i += 1;
    }
    
    return outputFilePath;
}
+ (NSString *)readFileAtPath:(NSString *)path {
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        [GYLogManager.defaultManager addErrorLogWithFormat:@"文件路径: %@\n读取文件时出现错误: %@", path, error.localizedDescription];
        return nil;
    } else {
        return content;
    }
}

@end
