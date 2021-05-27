//
//  PLPhotoViewController.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/27.
//

#import "PLPhotoViewController.h"

#import "PLPhotoMainCollectionViewCell.h"

static NSInteger const kMainCollectionViewTag = 101;
static NSInteger const kBottomCollectionViewTag = 102;

@interface PLPhotoViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *bottomCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *mainFlowLayout;

@property (nonatomic, copy) NSArray<NSString *> *files;

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
    }
}

#pragma mark - Configure
- (void)setupNotifications {
    
}
- (void)setupUIAndData {
    // Data
    self.files = @[];
    
    // UI
    [self setupNavigationBar];
    [self setupMainCollectionViewFlowLayout];
    [self setupMainCollectionView];
}
- (void)setupNavigationBar {
    
}
- (void)setupMainCollectionViewFlowLayout {
    self.mainFlowLayout = [UICollectionViewFlowLayout new];
    self.mainFlowLayout.minimumInteritemSpacing = 0;
    self.mainFlowLayout.minimumLineSpacing = 0;
    
    CGFloat screenWidth = MAX(kScreenWidth, kScreenHeight);
    CGFloat screenHeight = MIN(kScreenWidth, kScreenHeight);
    self.mainFlowLayout.itemSize = CGSizeMake(screenWidth - 50 * 2, screenHeight - 20 - 24); // 20: StatusBar; 24: Safe Area Bottom
}
- (void)setupMainCollectionView {
    [self.mainCollectionView registerNib:[UINib nibWithNibName:@"PLPhotoMainCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"PLPhotoMainCell"];
}

#pragma mark - Refresh
- (void)refreshFiles {
    self.files = [GYFileManager filePathsInFolder:self.folderPath extensions:[GYSettingManager defaultManager].mimeImageTypes];
    self.files = [self.files sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    
    [self.mainCollectionView reloadData];
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

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.files.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == kMainCollectionViewTag) {
        PLPhotoMainCollectionViewCell *cell = (PLPhotoMainCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PLPhotoMainCell" forIndexPath:indexPath];
        cell.filePath = self.files[indexPath.row];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.mainFlowLayout.itemSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.mainFlowLayout.minimumLineSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.mainFlowLayout.minimumInteritemSpacing;
}


@end
