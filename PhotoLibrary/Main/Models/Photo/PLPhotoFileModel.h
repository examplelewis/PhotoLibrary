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
@property (nonatomic, copy, readonly) NSString *trashFilePath;
@property (nonatomic, assign) NSInteger plIndex; // 最开始读取的顺序

@property (nonatomic, copy, readonly) NSString *mixWorksFilePath;
@property (nonatomic, copy, readonly) NSString *editWorksOriginFilePath;
@property (nonatomic, copy, readonly) NSString *editWorksEditFilePath;
@property (nonatomic, copy, readonly) NSString *otherWorksFilePath;

#pragma mark - Generators
+ (instancetype)fileModelWithFilePath:(NSString *)filePath plIndex:(NSInteger)plIndex;

#pragma mark - File Ops
- (void)trashFile;
- (void)restoreFile;
- (void)moveToMixWorks;
- (void)moveToEditWorks;
- (void)moveToOtherWorks;

@end

NS_ASSUME_NONNULL_END
