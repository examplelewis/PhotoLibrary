//
//  PLPhotoFileModel.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/5/29.
//

#import "PLPhotoFileModel.h"

@implementation PLPhotoFileModel

+ (instancetype)fileModelWithFilePath:(NSString *)filePath plIndex:(NSInteger)plIndex {
    PLPhotoFileModel *fileModel = [PLPhotoFileModel new];
    fileModel.filePath = filePath;
    fileModel.plIndex = plIndex;
    
    return fileModel;
}

@end
