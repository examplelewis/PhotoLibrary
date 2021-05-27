//
//  PLPhotoMainCollectionViewCell.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/27.
//

#import "PLPhotoMainCollectionViewCell.h"

@interface PLPhotoMainCollectionViewCell () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PLPhotoMainCollectionViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
}



#pragma mark - Setter
- (void)setFilePath:(NSString *)filePath {
    _filePath = [filePath copy];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        
        if ([[SDImageCache sharedImageCache] diskImageDataExistsWithKey:filePath]) {
            dispatch_main_async_safe(^{
                self.imageView.image = [[SDImageCache sharedImageCache] imageFromCacheForKey:filePath];
            });
        } else {
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            UIImage *image = nil;
            if ([filePath.pathExtension.lowercaseString isEqualToString:@"gif"]) {
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
            [[SDImageCache sharedImageCache] storeImage:image forKey:filePath completion:nil];
            
            dispatch_main_async_safe(^{
                @strongify(self);
                self.imageView.image = image;
            });
        }
    });
}

@end
