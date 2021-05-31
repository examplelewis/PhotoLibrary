//
//  PLPhotoMainCellView.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/28.
//

#import "PLPhotoMainCellView.h"

@interface PLPhotoMainCellView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation PLPhotoMainCellView

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupScrollView];
        [self setupImageView];
    }
    
    return self;
}

#pragma mark - Configure
- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.contentSize = self.size;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    [self.scrollView setMinimumZoomScale:1.0f];
    [self.scrollView setMaximumZoomScale:5.0f];
    
    [self addSubview:self.scrollView];
}
- (void)setupImageView {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
}

#pragma mark - Public
- (void)resetScale {
    [self.scrollView setZoomScale:1.0f animated:NO];
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
                    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                        image = [image resizeScaleImage:1.0f];
                    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                        if ([PLUniversalManager defaultManager].directlyJumpPhoto) {
                            // 直接跳转到图片页的，因为没有使用列表页的缓存，并且图片页使用ScrollView，没有内存问题，因此使用原尺寸大小
                            image = [image resizeScaleImage:1.0f];
                        } else {
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
