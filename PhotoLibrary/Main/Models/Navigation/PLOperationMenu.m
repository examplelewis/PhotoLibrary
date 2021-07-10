//
//  PLOperationMenu.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/3.
//

#import "PLOperationMenu.h"

@implementation PLOperationMenu

#pragma mark - Lifecycle
- (instancetype)initWithAction:(PLOperationMenuAction)action {
    self = [super init];
    if (self) {
        _action = action;
        
        [self generate];
    }
    
    return self;
}

#pragma mark - UIMenu
- (void)generate {
    NSMutableArray<UIAction *> *actions = [NSMutableArray array];
    
    @weakify(self);
    
    if (self.action & PLOperationMenuActionJumpTo) {
        UIAction *action = [UIAction actionWithTitle:@"跳转至" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            @strongify(self);
            
            if ([self.delegate respondsToSelector:@selector(operationMenu:didTapAction:)]) {
                [self.delegate operationMenu:self didTapAction:PLOperationMenuActionJumpTo];
            }
        }];
        
        [actions addObject:action];
    }
    
    if (self.action & PLOperationMenuActionMoveToMix) {
        UIAction *action = [UIAction actionWithTitle:@"移动到混合作品" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            @strongify(self);
            
            if ([self.delegate respondsToSelector:@selector(operationMenu:didTapAction:)]) {
                [self.delegate operationMenu:self didTapAction:PLOperationMenuActionMoveToMix];
            }
        }];
        
        [actions addObject:action];
    }
    
    if (self.action & PLOperationMenuActionMoveToEdit) {
        UIAction *action = [UIAction actionWithTitle:@"移动到编辑作品" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            @strongify(self);
            
            if ([self.delegate respondsToSelector:@selector(operationMenu:didTapAction:)]) {
                [self.delegate operationMenu:self didTapAction:PLOperationMenuActionMoveToEdit];
            }
        }];
        
        [actions addObject:action];
    }
    
    if (self.action & PLOperationMenuActionMoveToOther) {
        UIAction *action = [UIAction actionWithTitle:@"移动到其他作品" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            @strongify(self);
            
            if ([self.delegate respondsToSelector:@selector(operationMenu:didTapAction:)]) {
                [self.delegate operationMenu:self didTapAction:PLOperationMenuActionMoveToOther];
            }
        }];
        
        [actions addObject:action];
    }
    
    _menu = [UIMenu menuWithTitle:@"" children:actions.copy];
}

@end
