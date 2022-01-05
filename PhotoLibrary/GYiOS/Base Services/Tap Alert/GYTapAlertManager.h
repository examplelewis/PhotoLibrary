//
//  GYTapAlertManager.h
//  PodsGYiOS
//
//  Created by 龚宇 on 22/01/05.
//

#import <Foundation/Foundation.h>
#import "GYTapAlertHeader.h"
#import "GYTapAlertAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface GYTapAlertManager : NSObject

@property (nonatomic, weak) id<GYTapAlertDelegate> delegate;

#pragma mark - Lifecycle
- (instancetype)initWithAction:(GYTapAlertAction *)action;

- (void)triggerTap;

@end

NS_ASSUME_NONNULL_END
