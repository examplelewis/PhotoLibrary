//
//  PLNavigationItems.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/10.
//

#import "PLNavigationItems.h"

@interface PLNavigationItems ()

@property (nonatomic, strong) UIBarButtonItem *editBBI;
@property (nonatomic, strong) UIBarButtonItem *allBBI;
@property (nonatomic, strong) UIBarButtonItem *trashBBI;
@property (nonatomic, strong) UIBarButtonItem *menuBBI;
@property (nonatomic, strong) UIBarButtonItem *sliderBBI;
@property (nonatomic, strong) UIBarButtonItem *jumpSwitchBBI;

@property (nonatomic, strong) PLOperationMenu *operationMenu;

@end

@implementation PLNavigationItems

@synthesize actions = _actions;
@synthesize barButtonItems = _barButtonItems;

#pragma mark - Lifecycle
+ (instancetype)itemsFromActions:(PLNavigationAction)actions {
    return [[PLNavigationItems alloc] initWithActions:actions];
}
- (instancetype)initWithActions:(PLNavigationAction)actions {
    self = [super init];
    if (self) {
        _actions = actions;
    }
    
    return self;
}

#pragma mark - Configure
- (void)setupNavigationItems {
    if (self.actions & PLNavigationActionEdit) {
        self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBarButtonItemDidPress:)];
    }
    
    if (self.actions & PLNavigationActionSelectAll) {
        self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
        self.allBBI.enabled = NO;
    }
    
    if (self.actions & PLNavigationActionTrash) {
        self.trashBBI = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(trashBarButtonItemDidPress:)];
        self.trashBBI.enabled = NO;
    }
    
    if (self.actions & PLNavigationActionMenu) {
        BOOL confirm = [self.dataSource respondsToSelector:@selector(menuActionForForNavigationItems:)];
        NSAssert(confirm, @"PLNavigationActionMenu 需要实现 menuActionForForNavigationItems: 委托方法");
        
        PLOperationMenuAction actions = [self.dataSource menuActionForForNavigationItems:self];
        self.operationMenu = [[PLOperationMenu alloc] initWithAction:actions];
        self.operationMenu.delegate = self.menuDelegate;
        self.menuBBI = [[UIBarButtonItem alloc] initWithTitle:@"操作" menu:self.operationMenu.menu];
        self.menuBBI.enabled = NO;
    }
    
    if (self.actions & PLNavigationActionSizeSlider) {
        UIView *jumpSwitchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 44)];
        UISwitch *jumpSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 6.5, 47, 31)];
        jumpSwitch.tag = 100;
        jumpSwitch.on = [PLUniversalManager defaultManager].directlyJumpPhoto;
        [jumpSwitch addTarget:self action:@selector(jumpSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [jumpSwitchView addSubview:jumpSwitch];
        self.jumpSwitchBBI = [[UIBarButtonItem alloc] initWithCustomView:jumpSwitchView];
    }
    
    if (self.actions & PLNavigationActionJumpSwitch) {
        UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 44)];
        StepSlider *slider = [[StepSlider alloc] initWithFrame:CGRectMake(0, 9, 270, 26)];
        slider.tag = 100;
        slider.maxCount = 6;
        slider.index = [PLUniversalManager defaultManager].columnsPerRow - 4;
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [sliderView addSubview:slider];
        self.sliderBBI = [[UIBarButtonItem alloc] initWithCustomView:sliderView];
    }
}

#pragma mark - Update
- (void)updateAllBarButtonItemTitle:(NSString *)title {
    if (self.allBBI) {
        self.allBBI = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
    }
}

#pragma mark - Actions
- (void)editBarButtonItemDidPress:(UIBarButtonItem *)sender {
    if (![self.dataSource respondsToSelector:@selector(selectingModeForNavigationItems:)]) {
        return;
    }
    BOOL selectingMode = [self.dataSource selectingModeForNavigationItems:self];
    
    // edit
    UIBarButtonSystemItem editSystemItem = selectingMode ? UIBarButtonSystemItemEdit : UIBarButtonSystemItemCancel;
    self.editBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:editSystemItem target:self action:@selector(editBarButtonItemDidPress:)];
    
    // trash
    self.trashBBI.enabled = !selectingMode;
    
    // all
    self.allBBI = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
    self.allBBI.enabled = !selectingMode;
    
    // menu
    self.menuBBI.enabled = !selectingMode;
    
    if ([self.delegate respondsToSelector:@selector(navigationItems:didTapEditBarButtonItem:)]) {
        [self.delegate navigationItems:self didTapEditBarButtonItem:sender];
    }
}
- (void)trashBarButtonItemDidPress:(UIBarButtonItem *)sender {
    if ([self.delegate respondsToSelector:@selector(navigationItems:didTapTrashBarButtonItem:)]) {
        [self.delegate navigationItems:self didTapTrashBarButtonItem:sender];
    }
}
- (void)allBarButtonItemDidPress:(UIBarButtonItem *)sender {
    BOOL selectAll = [self.allBBI.title isEqualToString:@"全选"];
    
    NSString *allTitle = selectAll ? @"取消全选" : @"全选";
    self.allBBI = [[UIBarButtonItem alloc] initWithTitle:allTitle style:UIBarButtonItemStylePlain target:self action:@selector(allBarButtonItemDidPress:)];
    
    if ([self.delegate respondsToSelector:@selector(navigationItems:didTapSelectAllBarButtonItem:selectAll:)]) {
        [self.delegate navigationItems:self didTapSelectAllBarButtonItem:sender selectAll:selectAll];
    }
}
- (void)sliderValueChanged:(StepSlider *)sender {
    [PLUniversalManager defaultManager].columnsPerRow = sender.index + 4;
    
    if ([self.delegate respondsToSelector:@selector(navigationItems:didChangeSliderValue:)]) {
        [self.delegate navigationItems:self didChangeSliderValue:sender];
    }
}
- (void)jumpSwitchValueChanged:(UISwitch *)sender {
    [PLUniversalManager defaultManager].directlyJumpPhoto = ![PLUniversalManager defaultManager].directlyJumpPhoto;
}

#pragma mark - Getter
- (NSArray<UIBarButtonItem *> *)barButtonItems {
    _barButtonItems = @[];
    
    if (self.editBBI) {
        _barButtonItems = [_barButtonItems arrayByAddingObject:self.editBBI];
    }
    if (self.allBBI) {
        _barButtonItems = [_barButtonItems arrayByAddingObject:self.allBBI];
    }
    if (self.trashBBI) {
        _barButtonItems = [_barButtonItems arrayByAddingObject:self.trashBBI];
    }
    if (self.menuBBI) {
        _barButtonItems = [_barButtonItems arrayByAddingObject:self.menuBBI];
    }
    if (self.sliderBBI) {
        _barButtonItems = [_barButtonItems arrayByAddingObject:self.sliderBBI];
    }
    if (self.jumpSwitchBBI) {
        _barButtonItems = [_barButtonItems arrayByAddingObject:self.jumpSwitchBBI];
    }
    
    return _barButtonItems;
}

@end
