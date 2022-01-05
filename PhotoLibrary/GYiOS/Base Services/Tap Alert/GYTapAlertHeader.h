//
//  GYTapAlertHeader.h
//  PodsGYiOS
//
//  Created by 龚宇 on 22/01/05.
//

#ifndef GYTapAlertHeader_h
#define GYTapAlertHeader_h

static NSTimeInterval const GYTapAlertMaxTimeInterval = 3.0f;

@class GYTapAlertManager;
@class GYTapAlertAction;
@protocol GYTapAlertDelegate <NSObject>

- (void)manager:(GYTapAlertManager *)tapManager didTriggerAction:(GYTapAlertAction *)action;

@end

#endif /* GYTapAlertHeader_h */
