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
@property (strong, nonatomic) IBOutlet UILabel *fileCountLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectImageViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fileCountLabelCenterYConstraint;

@end

@implementation PLContentCollectionViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.fileCountLabelCenterYConstraint.constant = 25.0f;
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.fileCountLabelCenterYConstraint.constant = 15.0f;
    } else {
        self.fileCountLabelCenterYConstraint.constant = 10.0f;
    }
}

#pragma mark - Setter
- (void)setContentPath:(NSString *)contentPath {
    _contentPath = [contentPath copy];
    
    if ([contentPath isEqualToString:@"DefaultImage"]) {
        _isFolder = NO;
        self.cellType = PLContentCollectionViewCellTypeNormal;
        
        self.folderImageView.hidden = YES;
        self.nameLabel.hidden = NO;
        self.nameLabel.text = @"轻点进入图片页";
        
        self.imageView.image = [UIImage imageNamed:@"DefaultImage"];
        
        return;
    }
    
    _isFolder = [GYFileManager contentIsFolderAtPath:contentPath];
    self.cellType = PLContentCollectionViewCellTypeNormal;
    
    if (self.isFolder) {
        self.folderImageView.hidden = NO;
        self.nameLabel.hidden = NO;
        self.nameLabel.text = contentPath.lastPathComponent;
        self.fileCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", [GYFileManager folderPathsInFolder:contentPath].count, [GYFileManager filePathsInFolder:contentPath].count];
        self.fileCountLabel.hidden = NO;
        self.imageView.hidden = YES;
        
        CGFloat selectImageViewSize = 44.0 - (PLFolderColumnsPerRow - 4) * 4;
        self.selectImageViewWidthConstraint.constant = selectImageViewSize;
        self.selectImageViewHeightConstraint.constant = selectImageViewSize;
    } else {
        self.folderImageView.hidden = YES;
        self.nameLabel.hidden = YES;
        self.fileCountLabel.hidden = YES;
        self.imageView.hidden = NO;
        
        CGFloat selectImageViewSize = 44.0 - ([PLUniversalManager defaultManager].columnsPerRow - 4) * 4;
        self.selectImageViewWidthConstraint.constant = selectImageViewSize;
        self.selectImageViewHeightConstraint.constant = selectImageViewSize;
        
        UIImage *memoryImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:contentPath];
        if (memoryImage) {
            self.imageView.image = memoryImage;
        } else {
            self.imageView.image = nil;
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @strongify(self);
                
                if ([[SDImageCache sharedImageCache] diskImageDataExistsWithKey:contentPath]) {
                    dispatch_main_async_safe(^{
                        self.imageView.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:contentPath];
                    });
                } else {
                    NSData *data = [[NSData alloc] initWithContentsOfFile:contentPath];
                    UIImage *image = nil;
                    if ([contentPath.pathExtension.lowercaseString isEqualToString:@"gif"]) {
                        image = [UIImage sd_imageWithGIFData:data];
                    } else {
                        image = [UIImage imageWithData:data];
                        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                            image = [image resizeScaleImage:1.0f];
                        } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                            // 压缩图片，防止爆内存
                            if (image.size.width < 1000 && image.size.height < 1000) {
                                image = [image resizeScaleImage:1.0f];
                            } else if (image.size.width < 2000 && image.size.height < 2000) {
                                image = [image resizeScaleImage:0.8f];
                            } else {
                                image = [image resizeScaleImage:0.7f];
                            }
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
