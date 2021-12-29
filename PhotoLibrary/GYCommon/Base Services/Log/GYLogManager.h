//
//  GYLogManager.h
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/10.
//

#import <Foundation/Foundation.h>
#import "GYLogHeader.h"
#import "GYLog.h"

NS_ASSUME_NONNULL_BEGIN

@interface GYLogManager : NSObject

#pragma mark - Setup
+ (void)setupLoggerWithLogsDirectory:(NSString *)logsDirectory;

#pragma mark - Lifecycle
+ (instancetype)defaultManager;

#pragma mark - Setup
- (void)updateDefaultColor:(id)defaultColor successColor:(id)successColor warningColor:(id)warningColor errorColor:(id)errorColor font:(id)font;

#pragma mark - Log Clean / Reset
- (void)clean;
- (void)reset;

#pragma mark - Log 换行
- (void)addNewlineLog;

#pragma mark - Log 页面和文件，显示时间，添加新的日志
- (void)addDefaultLogWithFormat:(NSString *)format, ...;
- (void)addSuccessLogWithFormat:(NSString *)format, ...;
- (void)addWarningLogWithFormat:(NSString *)format, ...;
- (void)addErrorLogWithFormat:(NSString *)format, ...;

#pragma mark - Log 页面和文件，显示时间，新的日志覆盖之前的日志
- (void)addReplaceDefaultLogWithFormat:(NSString *)format, ...;
- (void)addReplaceSuccessLogWithFormat:(NSString *)format, ...;
- (void)addReplaceWarningLogWithFormat:(NSString *)format, ...;
- (void)addReplaceErrorLogWithFormat:(NSString *)format, ...;

#pragma mark - Log 自定义
- (void)addDefaultLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ...;
- (void)addSuccessLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ...;
- (void)addWarningLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ...;
- (void)addErrorLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ...;

#pragma mark - Local Log
- (void)saveDefaultLocalLog:(NSString *)log;
- (void)saveSuccessLocalLog:(NSString *)log;
- (void)saveWarningLocalLog:(NSString *)log;
- (void)saveErrorLocalLog:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
