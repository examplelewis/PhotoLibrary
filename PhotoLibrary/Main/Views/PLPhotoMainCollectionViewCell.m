//
//  PLPhotoMainCollectionViewCell.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/27.
//

#import "PLPhotoMainCollectionViewCell.h"

@interface PLPhotoMainCollectionViewCell () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation PLPhotoMainCollectionViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupScrollView];
    [self setupImageView];
}

#pragma mark - Configure
- (void)setupScrollView {
    CGFloat screenWidth = MAX(kScreenWidth, kScreenHeight);
    CGFloat screenHeight = MIN(kScreenWidth, kScreenHeight);
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 50 * 2, screenHeight - 20 - 24)];
    self.scrollView.contentSize = CGSizeMake(screenWidth - 50 * 2, screenHeight - 20 - 24);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    [self.scrollView setMinimumZoomScale:1.0f];
    [self.scrollView setMaximumZoomScale:5.0f];
    
    [self addSubview:self.scrollView];
}
- (void)setupImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 居中显示
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Setter
- (void)setFilePath:(NSString *)filePath {
    _filePath = [filePath copy];
    
    UIImage *memoryImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:filePath];
    if (memoryImage) {
        self.imageView.image = memoryImage;
    } else {
        self.imageView.image = nil;
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
                    // 压缩图片，防止爆内存
                    if (image.size.width < 1000 && image.size.height < 1000) {
                        image = [image resizeScaleImage:1.0f];
                    } else if (image.size.width < 2000 && image.size.height < 2000) {
                        image = [image resizeScaleImage:0.8f];
                    } else {
                        image = [image resizeScaleImage:0.7f];
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
}

@end
