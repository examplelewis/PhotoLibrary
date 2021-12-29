//
//  GYLogHeader.h
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/12.
//

#ifndef GYLogHeader_h
#define GYLogHeader_h

typedef NS_OPTIONS(NSUInteger, GYLogBehavior) {
    GYLogBehaviorNone              = 0,
    GYLogBehaviorLevelDefault      = 1 << 0,
    GYLogBehaviorLevelSuccess      = 1 << 1,
    GYLogBehaviorLevelWarning      = 1 << 2,
    GYLogBehaviorLevelError        = 1 << 3,
    
    GYLogBehaviorOnView            = 1 << 5,   // 在页面上显示Log
    GYLogBehaviorOnDDLog           = 1 << 6,   // 使用CocoaLumberJack处理Log
    GYLogBehaviorOnBoth            = GYLogBehaviorOnView | GYLogBehaviorOnDDLog, // 在页面上显示Log, 使用CocoaLumberJack处理Log
    
    GYLogBehaviorTime              = 1 << 9,   // 显示时间
    GYLogBehaviorAppend            = 1 << 10,  // 新日志以添加的形式
    
    GYLogBehaviorOnBothTimeAppend    = GYLogBehaviorOnBoth | GYLogBehaviorTime | GYLogBehaviorAppend,
    GYLogBehaviorOnViewTimeAppend    = GYLogBehaviorOnView | GYLogBehaviorTime | GYLogBehaviorAppend,
    GYLogBehaviorOnDDLogTimeAppend   = GYLogBehaviorOnDDLog | GYLogBehaviorTime | GYLogBehaviorAppend,
    
    GYLogBehaviorOnBothAppend        = GYLogBehaviorOnBoth | GYLogBehaviorAppend,
    GYLogBehaviorOnViewAppend        = GYLogBehaviorOnView | GYLogBehaviorAppend,
    GYLogBehaviorOnDDLogAppend       = GYLogBehaviorOnDDLog | GYLogBehaviorAppend,
    
    GYLogBehaviorOnBothTime          = GYLogBehaviorOnBoth | GYLogBehaviorTime,
    GYLogBehaviorOnViewTime          = GYLogBehaviorOnView | GYLogBehaviorTime,
    GYLogBehaviorOnDDLogTime         = GYLogBehaviorOnDDLog | GYLogBehaviorTime,
};

#endif /* GYLogHeader_h */
