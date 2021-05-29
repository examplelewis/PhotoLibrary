//
//  PLPhotoFileModel.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/5/29.
//

#import "PLPhotoFileModel.h"

@implementation PLPhotoFileModel

#pragma mark - Generators
+ (instancetype)fileModelWithFilePath:(NSString *)filePath plIndex:(NSInteger)plIndex {
    PLPhotoFileModel *fileModel = [PLPhotoFileModel new];
    fileModel.filePath = filePath;
    fileModel.plIndex = plIndex;
    
    return fileModel;
}

#pragma mark - File Ops
- (void)trashFile {
    NSString *superTrashFolderPath = self.trashFilePath.stringByDeletingLastPathComponent;
    [GYFileManager createFolderAtPath:superTrashFolderPath];
    
    [GYFileManager moveItemFromPath:self.filePath toPath:self.trashFilePath];
}
- (void)restoreFile {
    NSString *superFolderPath = self.filePath.stringByDeletingLastPathComponent;
    [GYFileManager createFolderAtPath:superFolderPath];
    
    [GYFileManager moveItemFromPath:self.trashFilePath toPath:self.filePath];
}

#pragma mark - Setter
- (void)setFilePath:(NSString *)filePath {
    _filePath = [filePath copy];
    _trashFilePath = [filePath stringByReplacingOccurrencesOfString:[GYSettingManager defaultManager].documentPath withString:[GYSettingManager defaultManager].trashFolderPath];
}

@end
