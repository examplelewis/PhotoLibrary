//
//  PLContentViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import "PLContentViewController.h"

static CGFloat const kSpacing = 10.0f;
static NSInteger const kColumnsPerRow = 7;

@interface PLContentViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *editBBI;
@property (nonatomic, strong) UIBarButtonItem *trashBBI;

@property(nonatomic, assign) CGFloat spacing;
@property(nonatomic, assign) NSInteger columnsPerRow;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<SMBFile *> *files;

@end

@implementation PLContentViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.file.name;
    
    [self setupUIAndData];
}


#pragma mark - Configure
- (void)setupUIAndData {
    // Data
    self.spacing = kSpacing;
    self.columnsPerRow = kColumnsPerRow;
    self.files = [NSMutableArray array];
    
    // UI
    [self setupNavigationBar];
    [self setupCollectionViewFlowLayout];
    [self setupCollectionView];
}
- (void)setupNavigationBar {
    self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemDidPress:)];
    self.editBBI.tag = 101;
    
    self.trashBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashBarButtonItemDidPress:)];
    self.trashBBI.enabled = NO;
    
    self.navigationItem.rightBarButtonItems = @[self.editBBI, self.trashBBI];
}
- (void)setupCollectionViewFlowLayout {
    self.flowLayout = [UICollectionViewFlowLayout new];
    self.flowLayout.minimumInteritemSpacing = self.spacing;
    self.flowLayout.minimumLineSpacing = self.spacing;
    
    CGFloat screenWidth = MAX(kScreenWidth, kScreenHeight);
    CGFloat itemWidth = (screenWidth - (self.columnsPerRow + 1) * self.spacing) / self.columnsPerRow;
    self.flowLayout.itemSize = CGSizeMake(floorf(itemWidth), floorf(itemWidth));
    
    self.flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 65); // section Header 大小
    self.flowLayout.sectionInset = UIEdgeInsetsMake(self.spacing, self.spacing, self.spacing, self.spacing); // 设置每个分区的 上左下右 的内边距
    self.flowLayout.sectionFootersPinToVisibleBounds = YES; // 设置分区的头视图和尾视图 是否始终固定在屏幕上边和下边
    
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
}
- (void)setupCollectionView {
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? 20 : 80;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    cell.contentView.layer.borderColor = [UIColor cyanColor].CGColor;
    cell.contentView.layer.borderWidth = 2;

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action
- (void)editBarButtonItemDidPress:(UIBarButtonItem *)sender {
    if (sender.tag == 101) {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editBarButtonItemDidPress:)];
        self.editBBI.tag = 102;
        self.trashBBI.enabled = YES;
        self.navigationItem.rightBarButtonItems = @[self.editBBI, self.trashBBI];
        
    } else {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemDidPress:)];
        self.editBBI.tag = 101;
        self.trashBBI.enabled = NO;
        self.navigationItem.rightBarButtonItems = @[self.editBBI, self.trashBBI];
        
    }
}
- (void)trashBarButtonItemDidPress:(UIBarButtonItem *)sender {
    
}

@end
