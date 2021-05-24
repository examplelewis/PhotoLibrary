//
//  PLContentCollectionViewCell.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import "PLContentCollectionViewCell.h"

@interface PLContentCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property(nonatomic, strong) NSMutableData *imageData;

@end

@implementation PLContentCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - File Ops
// 读取文件 meta-data
- (void)readFileMetadata {
    self.nameLabel.text = @"正在读取文件 meta-data";
    _fileStatus = PLContentCellFileStatusReadingMetadata;
    
    @weakify(self);
    [self.file updateStatus:^(NSError * _Nullable error) {
        @strongify(self);
        
        if (error) {
            NSString *errorDesc = [NSString stringWithFormat:@"%@ meta-data\n%@", self.file.name, error.localizedDescription];
//            dispatch_main_async_safe(^{
                self.nameLabel.text = errorDesc;
//            });
            self->_fileStatus = PLContentCellFileStatusReadMetadataFailure;
        } else {
            if (self.file.isDirectory) {
                self.backgroundColor = [UIColor cyanColor];
                self.contentView.backgroundColor = [UIColor cyanColor];
                
//                dispatch_main_async_safe(^{
                    self.nameLabel.text = self.file.name;
//                });
                self->_fileStatus = PLContentCellFileStatusFolder; // 文件夹就认定已经读取完毕
            } else {
                self.backgroundColor = [UIColor redColor];
                self.contentView.backgroundColor = [UIColor redColor];
                
//                dispatch_main_async_safe(^{
                    self.nameLabel.text = @"读取文件 meta-data 成功";
//                });
                self->_fileStatus = PLContentCellFileStatusReadMetadataSuccess;
                
                [self openFile];
            }
        }
    }];
}
// 打开文件
- (void)openFile {
    self.nameLabel.text = @"正在打开文件";
    _fileStatus = PLContentCellFileStatusOpeningFile;
    
    @weakify(self);
    [self.file open:SMBFileModeRead completion:^(NSError * _Nullable error) {
        @strongify(self);
        
        if (error) {
            NSString *errorDesc = [NSString stringWithFormat:@"%@ 打开\n%@", self.file.name, error.localizedDescription];
//            dispatch_main_async_safe(^{
                self.nameLabel.text = errorDesc;
//            });
            self->_fileStatus = PLContentCellFileStatusOpenFileFailure;
            
            [self closeFile]; // 打开文件失败，需要关闭文件
        } else {
//            dispatch_main_async_safe(^{
                self.nameLabel.text = @"打开文件 成功";
//            });
            self->_fileStatus = PLContentCellFileStatusOpenFileSuccess;
            
            [self readFileContent];
        }
    }];
}
// 读取文件内容
- (void)readFileContent {
    self.nameLabel.text = @"正在读取文件 内容";
    _fileStatus = PLContentCellFileStatusReadingContent;
    
    self.imageData = [NSMutableData data];
    
    @weakify(self);
    [self.file read:12000 progress:^BOOL(unsigned long long bytesReadTotal, NSData * _Nullable data, BOOL complete, NSError * _Nullable error) {
        @strongify(self);
        
        if (error) {
            NSLog(@"Unable to read from the file: %@", error);
//            NSString *errorDesc = [NSString stringWithFormat:@"%@ 内容\n%@", self.file.name, error.localizedDescription];
////            dispatch_main_async_safe(^{
//                self.nameLabel.text = errorDesc;
////            });
//            self->_fileStatus = PLContentCellFileStatusReadContentFailure;
        } else {
            NSLog(@"Read %ld bytes, in total %llu bytes (%0.2f %%)", data.length, bytesReadTotal, (double)bytesReadTotal / self.file.size * 100);
            
            if (data) {
                [self.imageData appendData:data];
            }
        }
        
        if (complete) {
////                dispatch_main_async_safe(^{
//                self.nameLabel.text = @"读取文件 内容 成功";
////                });
//            self->_fileStatus = PLContentCellFileStatusReadContentSuccess;
            
            [self closeFile];
            
            UIImage *image = [UIImage imageWithData:self.imageData];
            self.imageView.image = image;
            self.nameLabel.hidden = YES;
//        } else {
//            NSString *errorDesc = [NSString stringWithFormat:@"%@ 内容\n complete = NO", self.file.name];
////                dispatch_main_async_safe(^{
////                    self.nameLabel.text = @"【轻点重试】读取文件 内容 出现错误:\ncomplete = NO";
//                self.nameLabel.text = errorDesc;
////                });
//            self->_fileStatus = PLContentCellFileStatusReadContentFailure;
        }
        
//
        
        return YES;
    }];
}
- (void)closeFile {
    [self.file close:nil];
}


#pragma mark - Setter
- (void)setFile:(SMBFile *)file {
    // 如果文件名相同，那么就认定为同一个文件
    if ([_file.name isEqualToString:file.name] && _file.isDirectory == file.isDirectory) {
        return;
    }
    
    _file = file;
    
    self.nameLabel.hidden = NO;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.nameLabel.text = @"文件已指定";
    _fileStatus = PLContentCellFileStatusSpecified;
    
    [self readFileMetadata];
}
- (void)setCellType:(PLContentCollectionViewCellType)cellType {
    _cellType = cellType;
    
    switch (cellType) {
        case PLContentCollectionViewCellTypeNormal: {
            
        }
            break;
        case PLContentCollectionViewCellTypeEdit: {
            
        }
            break;
        case PLContentCollectionViewCellTypeEditSelect: {
            
        }
            break;
        default:
            break;
    }
}
- (void)setImageData:(NSData *)imageData {
    _imageData = imageData;
    
    UIImage *image = [UIImage imageWithData:imageData];
//    dispatch_main_async_safe(^{
        self.imageView.image = image;
        self.nameLabel.hidden = YES;
//    });
}

@end
