//
//  GYTapAlertAction.m
//  PodsGYiOS
//
//  Created by 龚宇 on 22/01/05.
//

#import "GYTapAlertAction.h"
#import "GYTapAlertHeader.h"

@implementation GYTapAlertAction

#pragma mark - Lifecycle
+ (instancetype)tapActionWithCount:(NSInteger)count timeInterval:(NSTimeInterval)timeInterval eventName:(NSString *)eventName actionName:(NSString *)actionName {
    return [GYTapAlertAction.alloc initWithCount:count timeInterval:timeInterval eventName:eventName actionName:actionName];
}
- (instancetype)initWithCount:(NSInteger)count timeInterval:(NSTimeInterval)timeInterval eventName:(NSString *)eventName actionName:(NSString *)actionName {
    self = [super init];
    if (self) {
        self.count = count;
        self.timeInterval = (timeInterval > GYTapAlertMaxTimeInterval) ? GYTapAlertMaxTimeInterval : timeInterval;
        self.eventName = eventName;
        self.actionName = actionName;
    }
    
    return self;
}

#pragma mark - Description
- (NSString *)description {
    return [NSString stringWithFormat:@"在%.2f秒内触发%ld次 %@\n即可执行操作: %@", self.timeInterval, self.count, self.eventName, self.actionName];
}

@end
