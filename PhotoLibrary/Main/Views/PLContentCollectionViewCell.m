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
@property (strong, nonatomic) IBOutlet UIImageView *selectImageView;
@property (strong, nonatomic) IBOutlet UIImageView *folderImageView;

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
        self.folderImageView.hidden = NO;
        self.nameLabel.hidden = NO;
        self.nameLabel.text = contentPath.lastPathComponent;
        
        self.imageView.hidden = YES;
    } else {
        self.folderImageView.hidden = YES;
        self.nameLabel.hidden = YES;
        
        self.imageView.hidden = NO;
        self.imageView.image = nil;
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            
            if ([[SDImageCache sharedImageCache] diskImageDataExistsWithKey:contentPath]) {
                dispatch_main_async_safe(^{
                    self.imageView.image = [[SDImageCache sharedImageCache] imageFromCacheForKey:contentPath];
                });
            } else {
                NSData *data = [[NSData alloc] initWithContentsOfFile:contentPath];
                UIImage *image = nil;
                if ([contentPath.pathExtension.lowercaseString isEqualToString:@"gif"]) {
                    image = [UIImage sd_imageWithGIFData:data];
                } else {
                    image = [UIImage imageWithData:data];
                    if (image.size.width < 1000 && image.size.height < 1000) {
                        image = [image resizeScaleImage:0.7f]; // 压缩图片
                    } else if (image.size.width < 2000 && image.size.height < 2000) {
                        image = [image resizeScaleImage:0.55f]; // 压缩图片
                    } else {
                        image = [image resizeScaleImage:0.35f]; // 压缩图片
                    }
                }
                [[SDImageCache sharedImageCache] storeImage:image forKey:contentPath completion:nil];
                
                dispatch_main_async_safe(^{
                    @strongify(self);
                    self.imageView.image = image;
                });
            }
        });
    }
}
- (void)setCellType:(PLContentCollectionViewCellType)cellType {
    if (_cellType == cellType) {
        return;
    }
    _cellType = cellType;
    
    self.selectImageView.hidden = cellType == PLContentCollectionViewCellTypeNormal;
    self.selectImageView.image = cellType == PLContentCollectionViewCellTypeEdit ? [UIImage imageNamed:@"SelectedOff"] : [UIImage imageNamed:@"SelectedOn"];
}

@end
