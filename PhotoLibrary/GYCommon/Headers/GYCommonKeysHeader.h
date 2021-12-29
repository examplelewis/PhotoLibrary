//
//  GYCommonKeysHeader.h
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/08.
//

#ifndef GYCommonKeysHeader_h
#define GYCommonKeysHeader_h

// 日志相关
// 以下通知都需要在主线程上跑：dispatch_main_async_safe((^{   }));
static NSString * const GYCommonLogCleanNotificationKey = @"com.gongyu.PodsGYCommon.notification.keys.log.clean";
static NSString * const GYCommonLogScrollLatestNotificationKey = @"com.gongyu.PodsGYCommon.notification.keys.log.scroll.latest";
static NSString * const GYCommonLogShowNotificationKey = @"com.gongyu.PodsGYCommon.notification.keys.log.show";

#endif /* GYCommonKeysHeader_h */
