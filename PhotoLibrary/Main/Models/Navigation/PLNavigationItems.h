//
//  PLNavigationItems.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/10.
//

#import <Foundation/Foundation.h>

#import <StepSlider.h>
#import "PLOperationMenu.h"

typedef NS_OPTIONS(NSInteger, PLNavigationAction) {
    PLNavigationActionNone          = 0,
    PLNavigationActionEdit          = 1 << 0,
    PLNavigationActionSelectAll     = 1 << 1,
    PLNavigationActionShift         = 1 << 2,
    PLNavigationActionTrash         = 1 << 3,
    PLNavigationActionMenu          = 1 << 4,
    PLNavigationActionSizeSlider    = 1 << 5,
    PLNavigationActionJumpSwitch    = 1 << 6,
    
    PLNavigationActionContentIPAD   = PLNavigationActionEdit | PLNavigationActionSelectAll | PLNavigationActionShift | PLNavigationActionTrash | PLNavigationActionMenu | PLNavigationActionSizeSlider | PLNavigationActionJumpSwitch,
};

@class PLNavigationItems;

NS_ASSUME_NONNULL_BEGIN

@protocol PLNavigationItemsDatasource <NSObject>

@optional
- (PLOperationMenuAction)menuActionForForNavigationItems:(PLNavigationItems *)navigationItems;
- (BOOL)selectingModeForNavigationItems:(PLNavigationItems *)navigationItems;

@end

@protocol PLNavigationItemsDelegate <NSObject>

@optional
- (void)navigationItems:(PLNavigationItems *)navigationItems didTapEditBarButtonItem:(UIBarButtonItem *)item;
- (void)navigationItems:(PLNavigationItems *)navigationItems didTapSelectAllBarButtonItem:(UIBarButtonItem *)item selectAll:(BOOL)selectAll;
- (void)navigationItems:(PLNavigationItems *)navigationItems didTapShiftBarButtonItem:(UIBarButtonItem *)item shiftMode:(BOOL)shiftMode;
- (void)navigationItems:(PLNavigationItems *)navigationItems didTapTrashBarButtonItem:(UIBarButtonItem *)item;
- (void)navigationItems:(PLNavigationItems *)navigationItems didChangeSliderValue:(StepSlider *)sender;

@end

@interface PLNavigationItems : NSObject

@property (nonatomic, assign, readonly) PLNavigationAction actions;
@property (nonatomic, copy, readonly) NSArray<UIBarButtonItem *> *barButtonItems;

@property (nonatomic, weak) id<PLNavigationItemsDatasource> dataSource;
@property (nonatomic, weak) id<PLNavigationItemsDelegate> delegate;
@property (nonatomic, weak) id<PLOperationMenuDelegate> menuDelegate;

#pragma mark - Lifecycle
+ (instancetype)itemsFromActions:(PLNavigationAction)actions;

#pragma mark - Configure
- (void)setupNavigationItems;

#pragma mark - Update
- (void)updateAllBarButtonItemTitle:(NSString *)title;
- (void)updateShiftBarButtonItemTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
