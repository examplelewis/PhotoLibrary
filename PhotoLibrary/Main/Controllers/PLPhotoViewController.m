//
//  PLPhotoViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/27.
//

#import "PLPhotoViewController.h"
#import "PLPhotoMainCellView.h"

static CGFloat const kMarginH = 50.f;
static CGFloat const kMarginBottom = 20.0f;
static NSInteger const kPreloadCountPerSide = 5; // 前后预加载的数量

@interface PLPhotoViewController () <UIScrollViewDelegate> {
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat scrollViewWidth;
    CGFloat scrollViewHeight;
}

@property (nonatomic, copy) NSArray<NSString *> *files;

@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) IBOutlet UICollectionView *bottomCollectionView;

@end

@implementation PLPhotoViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNotifications];
    [self setupUIAndData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.files.count == 0) {
        [self refreshFiles];
        [self refreshScrollView];
    }
}

#pragma mark - Configure
- (void)setupNotifications {
    
}
- (void)setupUIAndData {
    // Data
    screenWidth = MAX(kScreenWidth, kScreenHeight);
    screenHeight = MIN(kScreenWidth, kScreenHeight);
    scrollViewWidth = screenWidth - kMarginH * 2;
    scrollViewHeight = screenHeight - kMarginBottom;
    
    self.files = @[];
    
    // UI
    [self setupScrollView];
}
- (void)setupScrollView {
    self.mainScrollView.frame = CGRectMake(kMarginH, 0, scrollViewWidth, scrollViewHeight);
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.bounces = NO;
    self.mainScrollView.scrollEnabled = NO;
    self.mainScrollView.delegate = self;
    
    // 单击切换
    UITapGestureRecognizer *oneTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapGRPressed:)];
    [self.mainScrollView addGestureRecognizer:oneTapGR];
}

#pragma mark - Refresh
- (void)refreshFiles {
    self.files = [GYFileManager filePathsInFolder:self.folderPath extensions:[GYSettingManager defaultManager].mimeImageTypes];
    self.files = [self.files sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
}
- (void)refreshScrollView {
    for (NSInteger i = 0; i < self.files.count; i++) {
        PLPhotoMainCellView *cellView = [[PLPhotoMainCellView alloc] initWithFrame:CGRectMake(i * scrollViewWidth, 0, scrollViewWidth, scrollViewHeight)];
        cellView.tag = i + 1000;
        
        [self.mainScrollView addSubview:cellView];
    }
    
    self.mainScrollView.contentSize = CGSizeMake(self.files.count * scrollViewWidth, scrollViewHeight);
    
    NSInteger index = self.currentIndex;
    if (index >= self.files.count) {
        index = self.files.count - 1;
    }
    [self mainScrollViewScrollToIndex:index];
}

#pragma mark - ScrollView
- (void)mainScrollViewScrollToIndex:(NSInteger)index {
    NSInteger refreshStart = index - kPreloadCountPerSide;
    NSInteger refreshEnd = index + kPreloadCountPerSide;
    if (refreshStart < 0) {
        refreshStart = 0;
    }
    if (refreshEnd >= self.files.count) {
        refreshEnd = self.files.count - 1;
    }
    
    for (NSInteger i = refreshStart; i <= refreshEnd; i++) {
        PLPhotoMainCellView *cellView = (PLPhotoMainCellView *)[self.mainScrollView viewWithTag:1000 + i];
        cellView.filePath = self.files[i];
    }
    
    [self.mainScrollView setContentOffset:CGPointMake(index * self.mainScrollView.width, 0) animated:NO];
}

#pragma mark - Actions
- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)restoreButtonPressed:(UIButton *)sender {
    
}
- (IBAction)deleteButtonPressed:(UIButton *)sender {
    
}
- (IBAction)bottomButtonPressed:(UIButton *)sender {
    
}
- (void)oneTapGRPressed:(UIGestureRecognizer *)sender {
    NSInteger index = roundf(self.mainScrollView.contentOffset.x / scrollViewWidth);
    CGPoint point = [sender locationInView:self.mainScrollView];
    CGFloat currentOffsetX = point.x - index * scrollViewWidth;
    if (currentOffsetX <= scrollViewWidth / 2.0f) {
        index -= 1;
        if (index < 0) {
            return;
        }
    } else {
        index += 1;
        if (index >= self.files.count) {
            return;
        }
    }
    [self mainScrollViewScrollToIndex:index];
}

@end
