//
//  PLPhotoFileModel.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/5/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLPhotoFileModel : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) NSInteger plIndex; // 最开始读取的顺序

+ (instancetype)fileModelWithFilePath:(NSString *)filePath plIndex:(NSInteger)plIndex;

@end

NS_ASSUME_NONNULL_END
