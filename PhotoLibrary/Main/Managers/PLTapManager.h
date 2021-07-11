//
//  PLTapManager.h
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLTapModel : NSObject

#pragma mark - Lifecycle
+ (instancetype)tapModelWithCount:(NSInteger)count timeInterval:(NSTimeInterval)timeInterval eventName:(NSString *)eventName actionName:(NSString *)actionName;

@end

@class PLTapManager;
@protocol PLTapManagerDelegate <NSObject>

- (void)tapManager:(PLTapManager *)tapManager didTriggerTapActionWithTapModel:(PLTapModel *)tapModel;

@end

@interface PLTapManager : NSObject

@property (nonatomic, weak) id<PLTapManagerDelegate> delegate;

#pragma mark - Lifecycle
- (instancetype)initWithTapModel:(PLTapModel *)tapModel;

- (void)triggerTap;

@end

NS_ASSUME_NONNULL_END
