//
//  GYTapAlertAction.h
//  PodsGYiOS
//
//  Created by 龚宇 on 22/01/05.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYTapAlertAction : NSObject

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *actionName;

#pragma mark - Lifecycle
+ (instancetype)tapActionWithCount:(NSInteger)count timeInterval:(NSTimeInterval)timeInterval eventName:(NSString *)eventName actionName:(NSString *)actionName;

@end

NS_ASSUME_NONNULL_END
