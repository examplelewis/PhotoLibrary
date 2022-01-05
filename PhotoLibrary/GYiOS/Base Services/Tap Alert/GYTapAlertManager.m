//
//  GYTapAlertManager.m
//  PodsGYiOS
//
//  Created by 龚宇 on 22/01/05.
//

#import "GYTapAlertManager.h"

@interface GYTapAlertManager ()

@property (nonatomic, strong) GYTapAlertAction *action;
@property (nonatomic, strong) NSMutableArray<NSDate *> *tapDates;

@end

@implementation GYTapAlertManager

#pragma mark - Lifecycle
- (instancetype)initWithAction:(GYTapAlertAction *)action {
    self = [super init];
    if (self) {
        self.action = action;
        self.tapDates = [NSMutableArray array];
    }
    
    return self;
}

- (void)triggerTap {
    NSDate *currentDate = [NSDate date];
    if (self.tapDates.count == 0) {
        [self.tapDates addObject:currentDate];
        return;
    }
    
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.tapDates.lastObject];
    if (timeInterval <= self.action.timeInterval) {
        if (self.tapDates.count == self.action.count - 1) {
            [self _reset];
            [self _triggerAction];
        } else {
            [self.tapDates addObject:currentDate];
        }
        
        return;
    }
    
    [self _reset];
    if (timeInterval <= GYTapAlertMaxTimeInterval) {
        [self _showInfo];
    }
}
- (void)_reset {
    [self.tapDates removeAllObjects];
}
- (void)_showInfo {
    [SVProgressHUD showInfoWithStatus:self.action.description];
}

- (void)_triggerAction {
    if ([self.delegate respondsToSelector:@selector(manager:didTriggerAction:)]) {
        [self.delegate manager:self didTriggerAction:self.action];
    }
}

@end
