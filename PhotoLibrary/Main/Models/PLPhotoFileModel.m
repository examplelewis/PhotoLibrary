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
- (void)moveToMixWorks {
    [GYFileManager moveItemFromPath:self.filePath toPath:self.mixWorksFilePath];
}
- (void)moveToEditWorks {
    // 先将文件移动到"源文件"文件夹中
    NSString *superOriginFolderPath = self.editWorksOriginFilePath.stringByDeletingLastPathComponent;
    [GYFileManager createFolderAtPath:superOriginFolderPath];
    
    [GYFileManager moveItemFromPath:self.filePath toPath:self.editWorksOriginFilePath];
    
    // 再将文件复制到"编辑文件"文件夹中
    NSString *superEditFolderPath = self.editWorksEditFilePath.stringByDeletingLastPathComponent;
    [GYFileManager createFolderAtPath:superEditFolderPath];
    
    [GYFileManager copyItemFromPath:self.editWorksOriginFilePath toPath:self.editWorksEditFilePath];
}
- (void)moveToOtherWorks {
    [GYFileManager moveItemFromPath:self.filePath toPath:self.otherWorksFilePath];
}

#pragma mark - Setter
- (void)setFilePath:(NSString *)filePath {
    _filePath = [filePath copy];
    
    _trashFilePath = [filePath stringByReplacingOccurrencesOfString:[GYSettingManager defaultManager].documentPath withString:[GYSettingManager defaultManager].trashFolderPath];
    _mixWorksFilePath = [[GYSettingManager defaultManager].mixWorksFolderPath stringByAppendingPathComponent:filePath.lastPathComponent];
    _mixWorksFilePath = [PLUniversalManager nonConflictFilePathForFilePath:self.mixWorksFilePath];
    _editWorksOriginFilePath = [filePath stringByReplacingOccurrencesOfString:[GYSettingManager defaultManager].documentPath withString:[GYSettingManager defaultManager].editWorksOriginFolderPath];
    _editWorksEditFilePath = [filePath stringByReplacingOccurrencesOfString:[GYSettingManager defaultManager].documentPath withString:[GYSettingManager defaultManager].editWorksEditFolderPath];
    _otherWorksFilePath = [[GYSettingManager defaultManager].otherWorksFolderPath stringByAppendingPathComponent:filePath.lastPathComponent];
    _otherWorksFilePath = [PLUniversalManager nonConflictFilePathForFilePath:self.otherWorksFilePath];
}

@end
