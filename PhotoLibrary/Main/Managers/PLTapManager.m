//
//  PLTapManager.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/11.
//

#import "PLTapManager.h"

static NSTimeInterval const kMaxTimeInterval = 3.0f;

@interface PLTapModel ()

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *actionName;

@end

@implementation PLTapModel

#pragma mark - Lifecycle
+ (instancetype)tapModelWithCount:(NSInteger)count timeInterval:(NSTimeInterval)timeInterval eventName:(NSString *)eventName actionName:(NSString *)actionName {
    return [[PLTapModel alloc] initWithCount:count timeInterval:timeInterval eventName:eventName actionName:actionName];
}
- (instancetype)initWithCount:(NSInteger)count timeInterval:(NSTimeInterval)timeInterval eventName:(NSString *)eventName actionName:(NSString *)actionName {
    self = [super init];
    if (self) {
        self.count = count;
        self.timeInterval = (timeInterval > kMaxTimeInterval) ? kMaxTimeInterval : timeInterval;
        self.eventName = eventName;
        self.actionName = actionName;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"在%.2f秒内触发%ld次 %@\n即可执行操作: %@", self.timeInterval, self.count, self.eventName, self.actionName];
}

@end

@interface PLTapManager ()

@property (nonatomic, strong) PLTapModel *tapModel;

@property (nonatomic, strong) NSMutableArray<NSDate *> *tapDates;

@end

@implementation PLTapManager

#pragma mark - Lifecycle
- (instancetype)initWithTapModel:(PLTapModel *)tapModel {
    self = [super init];
    if (self) {
        self.tapModel = tapModel;
        self.tapDates = [NSMutableArray array];
    }
    
    return self;
}

- (void)triggerTap {
    if (self.tapDates.count == self.tapModel.count - 1) {
        [self _reset];
        [self _triggerAction];
        return;
    }
    
    NSDate *currentDate = [NSDate date];
    if (self.tapDates.count == 0) {
        [self.tapDates addObject:currentDate];
        return;
    }
    
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.tapDates.lastObject];
    if (timeInterval <= self.tapModel.timeInterval) {
        [self.tapDates addObject:currentDate];
        return;
    }
    
    [self _reset];
    if (timeInterval <= kMaxTimeInterval) {
        [self _showInfo];
    }
}
- (void)_reset {
    [self.tapDates removeAllObjects];
}
- (void)_showInfo {
    [SVProgressHUD showInfoWithStatus:self.tapModel.description];
}

- (void)_triggerAction {
    if ([self.delegate respondsToSelector:@selector(tapManager:didTriggerTapActionWithTapModel:)]) {
        [self.delegate tapManager:self didTriggerTapActionWithTapModel:self.tapModel];
    }
}

@end
