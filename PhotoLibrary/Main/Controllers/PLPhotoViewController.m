//
//  PLPhotoViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/27.
//

#import "PLPhotoViewController.h"
#import "PLPhotoMainCellView.h"
#import "PLPhotoBottomCellView.h"

static CGFloat const kMarginH = 50.f;
static CGFloat const kMarginBottom = 20.0f;
static NSInteger const kMainScrollViewPreloadCountPerSide = 5; // mainScrollView前后预加载的数量
static NSInteger const kBottomScrollViewPreloadCountPerSide = 20; // bottomScrollView前后预加载的数量

@interface PLPhotoViewController () <UIScrollViewDelegate> {
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat scrollViewWidth;
    CGFloat scrollViewHeight;
}

@property (nonatomic, strong) NSMutableArray<PLPhotoFileModel *> *fileModels;
@property (nonatomic, strong) NSMutableArray<PLPhotoFileModel *> *deleteModels;

@property (nonatomic, strong) NSMutableArray<PLPhotoMainCellView *> *mainCellViews;
@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;

@property (nonatomic, strong) NSMutableArray<PLPhotoBottomCellView *> *bottomCellViews;
@property (nonatomic, strong) IBOutlet UIScrollView *bottomScrollView;

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
    
    if (self.fileModels.count == 0) {
        [self readFiles];
        [self createMainCellViews];
        [self createBottomCellViews];
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
    
    self.fileModels = [NSMutableArray array];
    self.deleteModels = [NSMutableArray array];
    
    self.mainCellViews = [NSMutableArray array];
    self.bottomCellViews = [NSMutableArray array];
    
    // UI
    [self setupMainScrollView];
    [self setupBottomScrollView];
}
- (void)setupMainScrollView {
    self.mainScrollView.frame = CGRectMake(kMarginH, 0, scrollViewWidth, scrollViewHeight);
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.bounces = NO;
    self.mainScrollView.scrollEnabled = NO;
    self.mainScrollView.delegate = self;
    
    // 单击切换
    UITapGestureRecognizer *oneTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainScrollViewOneTapGRPressed:)];
    [self.mainScrollView addGestureRecognizer:oneTapGR];
}
- (void)setupBottomScrollView {
    self.bottomScrollView.frame = CGRectMake(0, screenHeight - 20 - 96, screenWidth, 96);
    self.bottomScrollView.showsHorizontalScrollIndicator = YES;
    self.bottomScrollView.showsVerticalScrollIndicator = NO;
//    self.mainScrollView.delegate = self;
}

#pragma mark - Read
- (void)readFiles {
    NSArray *files = [GYFileManager filePathsInFolder:self.folderPath extensions:[GYSettingManager defaultManager].mimeImageTypes].mutableCopy;
    files = [files sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    
    [self.fileModels removeAllObjects];
    for (NSInteger i = 0; i < files.count; i++) {
        [self.fileModels addObject:[PLPhotoFileModel fileModelWithFilePath:files[i] plIndex:i]];
    }
}
- (void)createMainCellViews {
    for (NSInteger i = 0; i < self.fileModels.count; i++) {
        PLPhotoMainCellView *cellView = [[PLPhotoMainCellView alloc] initWithFrame:CGRectMake(i * scrollViewWidth, 0, scrollViewWidth, scrollViewHeight)];
        cellView.tag = i + 1000;
        
        [self.mainCellViews addObject:cellView];
        [self.mainScrollView addSubview:cellView];
    }
    
    self.mainScrollView.contentSize = CGSizeMake(self.fileModels.count * scrollViewWidth, scrollViewHeight);
    
    NSInteger index = self.currentIndex;
    if (index >= self.fileModels.count) {
        index = self.fileModels.count - 1;
    }
    [self mainScrollViewScrollToIndex:index];
}
- (void)createBottomCellViews {
    [self createBottomCellViewWithViewType:PLPhotoBottomCellViewTypePlaceholderLeading index:-1];
    for (NSInteger i = 0; i < self.fileModels.count; i++) {
        [self createBottomCellViewWithViewType:PLPhotoBottomCellViewTypeImage index:i];
    }
    [self createBottomCellViewWithViewType:PLPhotoBottomCellViewTypePlaceholderTrailing index:-1];
    
    self.mainScrollView.contentSize = CGSizeMake(screenWidth, 96);
    
    NSInteger index = self.currentIndex;
    if (index >= self.fileModels.count) {
        index = self.fileModels.count - 1;
    }
    [self bottomScrollViewScrollToIndex:index];
}
- (void)createBottomCellViewWithViewType:(PLPhotoBottomCellViewType)viewType index:(NSInteger)index {
    PLPhotoBottomCellView *cellView = [[PLPhotoBottomCellView alloc] initWithFrame:CGRectZero];
    cellView.tag = viewType == PLPhotoBottomCellViewTypePlaceholderLeading ? -1 : viewType == PLPhotoBottomCellViewTypePlaceholderTrailing ? -2 : index + 1000;
    cellView.type = viewType;
    
    [self.bottomCellViews addObject:cellView];
    [self.bottomScrollView addSubview:cellView];
}

#pragma mark - Refresh
- (void)refreshMainCellViews {
    for (NSInteger i = 0; i < self.deleteModels.count; i++) {
        NSArray<PLPhotoMainCellView *> *cellViews = [self.mainCellViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PLPhotoMainCellView * _Nullable cellView, NSDictionary<NSString *,id> * _Nullable bindings) {
            return cellView.fileModel.plIndex == self.deleteModels[i].plIndex;
        }]];
        if (cellViews.count > 0) {
            PLPhotoMainCellView *cellView = cellViews.firstObject;
            [cellView removeFromSuperview];
        }
    }

    for (NSInteger i = 0; i < self.fileModels.count; i++) {
        NSArray<PLPhotoMainCellView *> *cellViews = [self.mainCellViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PLPhotoMainCellView * _Nullable cellView, NSDictionary<NSString *,id> * _Nullable bindings) {
            return cellView.fileModel.plIndex == self.fileModels[i].plIndex;
        }]];
        if (cellViews.count > 0) {
            PLPhotoMainCellView *cellView = cellViews.firstObject;
            cellView.frame = CGRectMake(i * scrollViewWidth, 0, scrollViewWidth, scrollViewHeight);

            if (!cellView.superview) {
                [self.mainScrollView addSubview:cellView];
            }
        }
    }
}

#pragma mark - MainScrollView
- (void)mainScrollViewScrollToIndex:(NSInteger)index {
    NSInteger refreshStart = index - kMainScrollViewPreloadCountPerSide;
    NSInteger refreshEnd = index + kMainScrollViewPreloadCountPerSide;
    if (refreshStart < 0) {
        refreshStart = 0;
    }
    if (refreshEnd >= self.fileModels.count) {
        refreshEnd = self.fileModels.count - 1;
    }
    
    for (NSInteger i = refreshStart; i <= refreshEnd; i++) {
        PLPhotoMainCellView *cellView = (PLPhotoMainCellView *)[self.mainScrollView viewWithTag:1000 + self.fileModels[i].plIndex];
        cellView.fileModel = self.fileModels[i];
    }
    
    [self.mainScrollView setContentOffset:CGPointMake(index * self.mainScrollView.width, 0) animated:NO];
}
- (void)bottomScrollViewScrollToIndex:(NSInteger)index {
    
}

#pragma mark - Actions
- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)restoreButtonPressed:(UIButton *)sender {
    if (self.deleteModels.count == 0) {
        return;
    }
    
    NSInteger index = roundf(self.mainScrollView.contentOffset.x / scrollViewWidth); // 还原操作前，正在看的index
    NSInteger plIndex = -1; // 如果plIndex == -1，说明还原之前所有文件都删光了
    if (self.fileModels.count > 0) {
        plIndex = self.fileModels[index].plIndex; // 还原操作前，正在看的图片对应的plIndex
    }
    
    [self.fileModels addObject:self.deleteModels.lastObject];
    [self.fileModels.lastObject restoreFile]; // 文件操作
    [self.fileModels sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"filePath" ascending:YES]]]; // 需要按照文件名重新排序
    [self.deleteModels removeLastObject];
    [self refreshMainCellViews];
    
    // 还原操作后，根据之前保留下来的plIndex，查找正确的index，并且跳转
    NSInteger scrollIndex = 0; // 如果还原之前所有文件都删光了，那么直接跳转到第一个就可以了
    if (plIndex != -1) {
        scrollIndex = [[self.fileModels valueForKey:@"plIndex"] indexOfObject:@(plIndex)];
    }
    if (scrollIndex != NSNotFound) {
        [self mainScrollViewScrollToIndex:scrollIndex];
    }
}
- (IBAction)deleteButtonPressed:(UIButton *)sender {
    if (self.fileModels.count == 0) {
        return;
    }
    
    NSInteger index = roundf(self.mainScrollView.contentOffset.x / scrollViewWidth); // 需要删除的index
    [self.deleteModels addObject:self.fileModels[index]];
    [self.deleteModels.lastObject trashFile]; // 文件操作
    [self.fileModels removeObjectAtIndex:index];
    [self refreshMainCellViews];
    
    // 如果删除了最后一张图片，显示删除完了之后的最后一张图片
    if (index >= self.fileModels.count) {
        index = self.fileModels.count - 1;
    }
    [self mainScrollViewScrollToIndex:index]; // 跳转到下一张图片，但是因为之前删除了一张图片，所以index不变
}
- (IBAction)bottomButtonPressed:(UIButton *)sender {
    
}
- (void)mainScrollViewOneTapGRPressed:(UIGestureRecognizer *)sender {
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
        if (index >= self.fileModels.count) {
            return;
        }
    }
    [self mainScrollViewScrollToIndex:index];
}

@end
