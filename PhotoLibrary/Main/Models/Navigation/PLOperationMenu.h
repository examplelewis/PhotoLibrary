//
//  PLOperationMenu.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, PLOperationMenuAction) {
    PLOperationMenuActionNone = 0,
    PLOperationMenuActionJumpTo = 1 << 0,
    
    PLOperationMenuActionMoveToMix = 1 << 1,
    PLOperationMenuActionMoveToEdit = 1 << 2,
    PLOperationMenuActionMoveToOther = 1 << 3,
    PLOperationMenuActionMoveToTypes = PLOperationMenuActionMoveToMix | PLOperationMenuActionMoveToEdit | PLOperationMenuActionMoveToOther,
    
    PLOperationMenuActionDepart = 1 << 4,
    PLOperationMenuActionMerge = 1 << 5,
    
    PLOperationMenuActionViewAllInList = 1 << 6,
    PLOperationMenuActionViewAllInDetail = 1 << 7,
};

NS_ASSUME_NONNULL_BEGIN

@class PLOperationMenu;
@protocol PLOperationMenuDelegate <NSObject>

- (void)operationMenu:(PLOperationMenu *)menu didTapAction:(PLOperationMenuAction)action;

@end

@interface PLOperationMenu : NSObject

@property (nonatomic, strong, readonly) UIMenu *menu;
@property (nonatomic, weak) id<PLOperationMenuDelegate> delegate;
@property (nonatomic, assign) PLOperationMenuAction action;

- (instancetype)initWithAction:(PLOperationMenuAction)action;

@end

NS_ASSUME_NONNULL_END
