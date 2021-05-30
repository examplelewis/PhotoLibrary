//
//  PLPhotoBottomCellView.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/5/29.
//

#import "PLPhotoBottomCellView.h"

@interface PLPhotoBottomCellView ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation PLPhotoBottomCellView

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupImageView];
    }
    
    return self;
}

#pragma mark - Configure
- (void)setupImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - PLScrollViewIndicatorMargin)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor cyanColor];
    [self addSubview:self.imageView];
}

#pragma mark - Setter
- (void)setFileModel:(PLPhotoFileModel *)fileModel {
    if ([_fileModel.filePath isEqualToString:fileModel.filePath]) {
        return;
    }
    
    _fileModel = fileModel;
    
    if (self.imageView.image) {
        return;
    }
    
    UIImage *memoryImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:fileModel.filePath];
    if (memoryImage) {
        self.imageView.image = memoryImage;
    } else {
        self.imageView.image = nil;
        @weakify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            
            if ([[SDImageCache sharedImageCache] diskImageDataExistsWithKey:fileModel.filePath]) {
                dispatch_main_async_safe(^{
                    self.imageView.image = [[SDImageCache sharedImageCache] imageFromCacheForKey:fileModel.filePath];
                });
            } else {
                NSData *data = [[NSData alloc] initWithContentsOfFile:fileModel.filePath];
                UIImage *image = nil;
                if ([fileModel.filePath.pathExtension.lowercaseString isEqualToString:@"gif"]) {
                    image = [UIImage sd_imageWithGIFData:data];
                } else {
                    image = [UIImage imageWithData:data];
//                    image = [image resizeScaleImage:1.0f];
                    // 压缩图片，防止爆内存
                    if (image.size.width < 1000 && image.size.height < 1000) {
                        image = [image resizeScaleImage:1.0f];
                    } else if (image.size.width < 2000 && image.size.height < 2000) {
                        image = [image resizeScaleImage:0.8f];
                    } else {
                        image = [image resizeScaleImage:0.7f];
                    }
                }
                [[SDImageCache sharedImageCache] storeImage:image forKey:fileModel.filePath completion:nil];
                
                dispatch_main_async_safe(^{
                    @strongify(self);
                    self.imageView.image = image;
                });
            }
        });
    }
}

@end
