//
//  PLContentModel.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/10.
//

#import "PLContentModel.h"

@implementation PLContentModel

+ (instancetype)contentModelFromItemPath:(NSString *)itemPath {
    PLContentModel *model = [PLContentModel new];
    model.itemPath = itemPath;
    
    return model;
}

- (void)setItemPath:(NSString *)itemPath {
    _itemPath = itemPath.copy;
    
    self.isFolder = [GYFileManager contentIsFolderAtPath:itemPath];
    if (self.isFolder) {
        self.foldersCount = [GYFileManager folderPathsInFolder:itemPath].count;
        self.filesCount = [GYFileManager filePathsInFolder:itemPath].count;
    }
}

@end
