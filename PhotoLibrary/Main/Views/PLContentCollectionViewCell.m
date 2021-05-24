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

@end

@implementation PLContentCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Setter
- (void)setContentPath:(NSString *)contentPath {
    _contentPath = [contentPath copy];
    _isFolder = [GYFileManager contentIsFolderAtPath:contentPath];
    self.cellType = PLContentCollectionViewCellTypeNormal;
    
    if (self.isFolder) {
        self.backgroundColor = [UIColor cyanColor];
        self.contentView.backgroundColor = [UIColor cyanColor];
        
        self.nameLabel.hidden = NO;
        self.nameLabel.text = contentPath.lastPathComponent;
        
        self.imageView.hidden = YES;
    } else {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.nameLabel.hidden = YES;
        
        self.imageView.hidden = NO;
        self.imageView.image = nil;
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [[NSData alloc] initWithContentsOfFile:contentPath];
            UIImage *image = nil;
            if ([contentPath.pathExtension.lowercaseString isEqualToString:@"gif"]) {
                image = [UIImage sd_imageWithGIFData:data];
            } else {
                image = [UIImage imageWithData:data];
                image = [image resizeScaleImage:0.6f]; // 压缩图片
            }
            
            dispatch_main_async_safe(^{
                @strongify(self);
                self.imageView.image = image;
            });
        });
    }
}
- (void)setCellType:(PLContentCollectionViewCellType)cellType {
    if (_cellType == cellType) {
        return;
    }
    
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

@end
