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
@property (strong, nonatomic) IBOutlet UIImageView *folderImageView;
@property (strong, nonatomic) IBOutlet UILabel *fileCountLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fileCountLabelCenterYConstraint;

@end

@implementation PLContentCollectionViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 4.0f;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.fileCountLabelCenterYConstraint.constant = 25.0f;
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.fileCountLabelCenterYConstraint.constant = 15.0f;
    } else {
        self.fileCountLabelCenterYConstraint.constant = 10.0f;
    }
}

#pragma mark - Setter
- (void)setModel:(PLContentModel *)model {
    _model = model;
    
    self.cellType = PLContentCollectionViewCellTypeNormal;
    
    self.folderImageView.hidden = !model.isFolder;
    self.nameLabel.hidden = !model.isFolder;
    self.fileCountLabel.hidden = !model.isFolder;
    self.imageView.hidden = model.isFolder;
    
    if (model.isFolder) {
        self.nameLabel.text = model.itemPath.lastPathComponent;
        self.fileCountLabel.text = [NSString stringWithFormat:@"%ld / %ld", model.foldersCount, model.filesCount];
    } else {
        UIImage *memoryImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:model.itemPath];
        if (memoryImage) {
            self.imageView.image = memoryImage;
        } else {
            self.imageView.image = nil;
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [[NSData alloc] initWithContentsOfFile:model.itemPath];
                UIImage *image = nil;
                if ([model.itemPath.pathExtension.lowercaseString isEqualToString:@"gif"]) {
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
                            image = [image resizeScaleImage:0.66f];
                        } else {
                            image = [image resizeScaleImage:0.33f];
                        }
                    }
                }
                
                [[SDImageCache sharedImageCache] storeImageToMemory:image forKey:model.itemPath];
                
                dispatch_main_async_safe(^{
                    @strongify(self);
                    self.imageView.image = image;
                });
            });
        }
    }
}

- (void)setCellType:(PLContentCollectionViewCellType)cellType {
    if (_cellType == cellType) {
        return;
    }
    _cellType = cellType;
    
    self.layer.borderColor = (cellType == PLContentCollectionViewCellTypeEditSelect) ? [UIColor colorWithHexString:@"#F7D450"].CGColor : [UIColor clearColor].CGColor;
}

@end
