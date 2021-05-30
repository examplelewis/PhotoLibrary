//
//  PLPhotoPhoneViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/30.
//

#import "PLPhotoPhoneViewController.h"
#import "PLPhotoMainCellView.h"

@interface PLPhotoPhoneViewController () {
    CGFloat scrollViewHeight;
}

@property (nonatomic, strong) NSMutableArray<PLPhotoFileModel *> *fileModels;
@property (nonatomic, strong) NSMutableArray<PLPhotoFileModel *> *deleteModels;

@property (nonatomic, strong) NSMutableArray<PLPhotoMainCellView *> *cellViews;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PLPhotoPhoneViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNotifications];
    [self setupUIAndData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.fileModels.count == 0) {
        [self readFiles];
        [self createMainCellViews];
    }
}

#pragma mark - Configure
- (void)setupNotifications {
    
}
- (void)setupUIAndData {
    self.title = self.folderPath.lastPathComponent;
    
    // Data
    scrollViewHeight = kScreenHeight - PLNorchPhoneSafeAreaTop - PLNavigationBarHeight;
    
    self.fileModels = [NSMutableArray array];
    self.deleteModels = [NSMutableArray array];
    
    self.cellViews = [NSMutableArray array];
    
    // UI
    [self setupNavigationBar];
    [self setupScrollView];
}
- (void)setupNavigationBar {
    UIBarButtonItem *deleteBBI = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteBarButtonItemPressed:)];
    UIBarButtonItem *restoreBBI = [[UIBarButtonItem alloc] initWithTitle:@"撤销" style:UIBarButtonItemStylePlain target:self action:@selector(restoreBarButtonItemPressed:)];
    
    self.navigationItem.rightBarButtonItems = @[deleteBBI, restoreBBI];
}
- (void)setupScrollView {
    self.scrollView.frame = CGRectMake(0, PLNorchPhoneSafeAreaTop + PLNavigationBarHeight, kScreenWidth, scrollViewHeight);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.scrollEnabled = NO;
    
    // 单击切换
    UITapGestureRecognizer *oneTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewOneTapGRPressed:)];
    [self.scrollView addGestureRecognizer:oneTapGR];
}

#pragma mark - Read
- (void)readFiles {
    NSArray *files = [GYFileManager filePathsInFolder:self.folderPath extensions:[GYSettingManager defaultManager].mimeImageTypes].mutableCopy;
    files = [files sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    
    [self.fileModels removeAllObjects];
    for (NSInteger i = 0; i < files.count; i++) {
        [self.fileModels addObject:[PLPhotoFileModel fileModelWithFilePath:files[i] plIndex:i]];
    }
    
    self.title = [NSString stringWithFormat:@"%@(%ld)", self.folderPath.lastPathComponent, self.fileModels.count];
}
- (void)createMainCellViews {
    for (NSInteger i = 0; i < self.fileModels.count; i++) {
        PLPhotoMainCellView *cellView = [[PLPhotoMainCellView alloc] initWithFrame:CGRectMake(i * kScreenWidth, 0, kScreenWidth, scrollViewHeight)];
        cellView.tag = i + 1000;
        
        [self.cellViews addObject:cellView];
        [self.scrollView addSubview:cellView];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.fileModels.count * kScreenWidth, scrollViewHeight);
    
    [self scrollViewScrollToIndex:0];
}

#pragma mark - Refresh
- (void)refreshMainCellViews {
    for (NSInteger i = 0; i < self.deleteModels.count; i++) {
        NSArray<PLPhotoMainCellView *> *cellViews = [self.cellViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PLPhotoMainCellView * _Nullable cellView, NSDictionary<NSString *,id> * _Nullable bindings) {
            return cellView.fileModel.plIndex == self.deleteModels[i].plIndex;
        }]];
        if (cellViews.count > 0) {
            PLPhotoMainCellView *cellView = cellViews.firstObject;
            [cellView removeFromSuperview];
        }
    }

    for (NSInteger i = 0; i < self.fileModels.count; i++) {
        NSArray<PLPhotoMainCellView *> *cellViews = [self.cellViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PLPhotoMainCellView * _Nullable cellView, NSDictionary<NSString *,id> * _Nullable bindings) {
            return cellView.fileModel.plIndex == self.fileModels[i].plIndex;
        }]];
        if (cellViews.count > 0) {
            PLPhotoMainCellView *cellView = cellViews.firstObject;
            cellView.frame = CGRectMake(i * kScreenWidth, 0, kScreenWidth, scrollViewHeight);

            if (!cellView.superview) {
                [self.scrollView addSubview:cellView];
            }
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(self.fileModels.count * kScreenWidth, scrollViewHeight);
}

#pragma mark - MainScrollView
- (void)scrollViewScrollToIndex:(NSInteger)index {
    if (self.fileModels.count  == 0) {
        return;
    }
    
    self.title = [NSString stringWithFormat:@"%@(%ld/%ld)", self.folderPath.lastPathComponent, index + 1, self.fileModels.count];
    
    NSInteger refreshStart = index - PLPhotoMainScrollViewPreloadCountPerSide;
    NSInteger refreshEnd = index + PLPhotoMainScrollViewPreloadCountPerSide;
    if (refreshStart < 0) {
        refreshStart = 0;
    }
    if (refreshEnd >= self.fileModels.count) {
        refreshEnd = self.fileModels.count - 1;
    }
    
    for (NSInteger i = refreshStart; i <= refreshEnd; i++) {
        PLPhotoMainCellView *cellView = (PLPhotoMainCellView *)[self.scrollView viewWithTag:1000 + self.fileModels[i].plIndex];
        cellView.fileModel = self.fileModels[i];
    }
    
    [self.scrollView setContentOffset:CGPointMake(index * kScreenWidth, 0) animated:NO];
}

#pragma mark - Actions
- (void)restoreBarButtonItemPressed:(UIButton *)sender {
    if (self.deleteModels.count == 0) {
        self.title = self.folderPath.lastPathComponent;
        
        return;
    }
    
    NSInteger index = roundf(self.scrollView.contentOffset.x / kScreenWidth); // 还原操作前，正在看的index
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
        [self scrollViewScrollToIndex:scrollIndex];
    }
}
- (void)deleteBarButtonItemPressed:(UIButton *)sender {
    if (self.fileModels.count == 0) {
        return;
    }
    
    NSInteger index = roundf(self.scrollView.contentOffset.x / kScreenWidth); // 需要删除的index
    [self.deleteModels addObject:self.fileModels[index]];
    [self.deleteModels.lastObject trashFile]; // 文件操作
    [self.fileModels removeObjectAtIndex:index];
    [self refreshMainCellViews];
    
    // 如果删除了最后一张图片，显示删除完了之后的最后一张图片
    if (index >= self.fileModels.count) {
        index = self.fileModels.count - 1;
    }
    [self scrollViewScrollToIndex:index]; // 跳转到下一张图片，但是因为之前删除了一张图片，所以index不变
}
- (void)scrollViewOneTapGRPressed:(UIGestureRecognizer *)sender {
    NSInteger index = roundf(self.scrollView.contentOffset.x / kScreenWidth);
    CGPoint point = [sender locationInView:self.scrollView];
    CGFloat currentOffsetX = point.x - index * kScreenWidth;
    if (currentOffsetX <= kScreenWidth / 2.0f) {
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
    [self scrollViewScrollToIndex:index];
}

@end
