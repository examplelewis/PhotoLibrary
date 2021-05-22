//
//  GYLogManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, GYLogBehavior) {
    GYLogBehaviorNone              = 0,
    GYLogBehaviorLevelDefault      = 1 << 0,
    GYLogBehaviorLevelWarning      = 1 << 1,
    GYLogBehaviorLevelError        = 1 << 2,
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

@interface GYLogManager : NSObject

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Log Clean / Reset
- (void)clean;
- (void)reset;

#pragma mark - Log 换行
- (void)addNewlineLog;

#pragma mark - Log 页面和文件，显示时间，添加新的日志
- (void)addDefaultLogWithFormat:(NSString *)format, ...;
- (void)addWarningLogWithFormat:(NSString *)format, ...;
- (void)addErrorLogWithFormat:(NSString *)format, ...;

#pragma mark - Log 页面和文件，显示时间，新的日志覆盖之前的日志
- (void)addReplaceDefaultLogWithFormat:(NSString *)format, ...;
- (void)addReplaceWarningLogWithFormat:(NSString *)format, ...;
- (void)addReplaceErrorLogWithFormat:(NSString *)format, ...;

#pragma mark - Log 自定义
- (void)addDefaultLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ...;
- (void)addWarningLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ...;
- (void)addErrorLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ...;

#pragma mark - Local Log
- (void)saveDefaultLocalLog:(NSString *)log;
- (void)saveWarningLocalLog:(NSString *)log;
- (void)saveErrorLocalLog:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
