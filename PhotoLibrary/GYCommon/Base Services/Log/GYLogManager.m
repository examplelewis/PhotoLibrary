//
//  GYLogManager.m
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/10.
//

#import "GYLogManager.h"
#import "GYLogFormatters.h"

@interface GYLogManager ()

@property (strong) id defaultTextColor;
@property (strong) id successColor;
@property (strong) id warningTextColor;
@property (strong) id errorTextColor;
@property (strong) id textFont;

//@property (strong) NSMutableArray *logs; // 日志
@property (strong) NSAttributedString *latestLog;
@property (strong) NSDate *current;
@property (strong) NSLock *lock;

@end

@implementation GYLogManager

#pragma mark - Setup
+ (void)setupLoggerWithLogsDirectory:(NSString *)logsDirectory {
    // 在系统上保持一周的日志文件
    DDLogFileManagerDefault *logFileManagerDefault = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logsDirectory];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManagerDefault];
    fileLogger.logFormatter = GYFileLogFormatter.new;
    fileLogger.rollingFrequency = 60 * 60 * 24 * 7;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    fileLogger.maximumFileSize = 10 * 1024 * 1024;
    [DDLog addLogger:fileLogger];
    
    // RELEASE 的时候不需要添加 console 日志，只保留文件日志
#ifdef DEBUG
    DDOSLogger *osLogger = DDOSLogger.sharedInstance;
    osLogger.logFormatter = GYOSLogFormatter.new;
    [DDLog addLogger:osLogger]; // console 日志
#endif
}

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static GYLogManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [NSLock new];
//        self.logs = [NSMutableArray array];
    }
    
    return self;
}
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Setup
- (void)updateDefaultColor:(id)defaultColor successColor:(id)successColor warningColor:(id)warningColor errorColor:(id)errorColor font:(id)font {
    self.defaultTextColor = defaultColor;
    self.successColor = successColor;
    self.warningTextColor = warningColor;
    self.errorTextColor = errorColor;
    self.textFont = font;
}

#pragma mark - Log Clean / Reset
- (void)clean {
    [self.lock lock];
    self.latestLog = nil;
//    [self.logs removeAllObjects];
    [self.lock unlock];
    
    [NSNotificationCenter.defaultCenter postNotificationName:GYCommonLogCleanNotificationKey object:nil];
}
- (void)reset {
    [self.lock lock];
    self.current = [NSDate date];
    self.latestLog = nil;
//    [self.logs removeAllObjects];
    [self.lock unlock];
    
    [NSNotificationCenter.defaultCenter postNotificationName:GYCommonLogCleanNotificationKey object:nil];
}

#pragma mark - Log 换行
- (void)addNewlineLog {
    [self _addLogWithBehavior:GYLogBehaviorLevelDefault | GYLogBehaviorOnBothTimeAppend log:@""];
}

#pragma mark - Log 页面和文件，显示时间，添加新的日志
- (void)addDefaultLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelDefault | GYLogBehaviorOnBothTimeAppend log:log];
}
- (void)addSuccessLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelSuccess | GYLogBehaviorOnBothTimeAppend log:log];
}

- (void)addWarningLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelWarning | GYLogBehaviorOnBothTimeAppend log:log];
}
- (void)addErrorLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelError | GYLogBehaviorOnBothTimeAppend log:log];
}

#pragma mark - Log 页面和文件，显示时间，新的日志覆盖之前的日志
- (void)addReplaceDefaultLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelDefault | GYLogBehaviorOnBothTime log:log];
}
- (void)addReplaceSuccessLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelSuccess | GYLogBehaviorOnBothTime log:log];
}
- (void)addReplaceWarningLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelWarning | GYLogBehaviorOnBothTime log:log];
}
- (void)addReplaceErrorLogWithFormat:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelError | GYLogBehaviorOnBothTime log:log];
}

#pragma mark - Log 自定义
- (void)addDefaultLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelDefault | behavior log:log];
}
- (void)addSuccessLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelSuccess | behavior log:log];
}
- (void)addWarningLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelWarning | behavior log:log];
}
- (void)addErrorLogWithBehavior:(GYLogBehavior)behavior format:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    [self _addLogWithBehavior:GYLogBehaviorLevelError | behavior log:log];
}

#pragma mark - Log 内部实现
- (void)_addLogWithBehavior:(GYLogBehavior)behavior log:(NSString *)log {
    if (behavior & GYLogBehaviorNone) {
        return;
    }
    
    // 日志内容
    NSString *logs = @"";
    if (behavior & GYLogBehaviorTime) {
        if (self.current) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.current];
            logs = [logs stringByAppendingFormat:@"%@ | %@\t\t", [[NSDate date] dateStringWithFormat:GYTimeFormatyMdHmsS], [GYFoundationManager humanReadableTimeFromInterval:interval]];
            
            CGSize logsSize = [logs sizeWithAttributes:@{NSFontAttributeName: self.textFont}];
            if (logsSize.width < 250) {
                logs = [logs stringByAppendingString:@"\t"];
            }
        } else {
            logs = [logs stringByAppendingFormat:@"%@\t\t", [[NSDate date] dateStringWithFormat:GYTimeFormatyMdHmsS]];
        }
    }
    logs = [logs stringByAppendingString:log];
    
    // 本地日志
    if (behavior & GYLogBehaviorOnDDLog) {
        NSString *localLogs = logs.copy;
        // logs里面的时间和日志间隔可能是两个\t，也可能是三个\t，因此在本地日志中需要替换
        NSRange firstTabsRange = [localLogs rangeOfString:@"\t\t\t"];
        // 正常情况下第一次出现三个\t的location应该是35。如果超过35，那就表明第一次出现三个\t是在具体的日志内容中，不应替换
        if (firstTabsRange.location == 35) {
            localLogs = [localLogs stringByReplacingCharactersInRange:firstTabsRange withString:@"\t\t"];
        }
        
        if (behavior & GYLogBehaviorLevelDefault) {
            [self saveDefaultLocalLog:localLogs];
        } else if (behavior & GYLogBehaviorLevelSuccess) {
            [self saveSuccessLocalLog:localLogs];
        } else if (behavior & GYLogBehaviorLevelWarning) {
            [self saveWarningLocalLog:localLogs];
        } else if (behavior & GYLogBehaviorLevelError) {
            [self saveErrorLocalLog:localLogs];
        }
    }
    
    if (behavior & GYLogBehaviorOnView) {
        // 添加日志的样式
        id textColor = self.defaultTextColor;
        if (behavior & GYLogBehaviorLevelSuccess) {
            textColor = self.successColor;
        } else if (behavior & GYLogBehaviorLevelWarning) {
            textColor = self.warningTextColor;
        } else if (behavior & GYLogBehaviorLevelError) {
            textColor = self.errorTextColor;
        }
        NSAttributedString *attributedLog = [[NSAttributedString alloc] initWithString:logs attributes:@{NSForegroundColorAttributeName: textColor, NSFontAttributeName: self.textFont}];
        
        // 显示日志
        GYLog *log = [GYLog defaultLogWithAttributedLog:attributedLog latestLog:self.latestLog.string];
        log.shouldAppend = ((behavior & GYLogBehaviorAppend) || !self.latestLog);
        [NSNotificationCenter.defaultCenter postNotificationName:GYCommonLogShowNotificationKey object:log];
        // 将日志滚动到最前面
        [NSNotificationCenter.defaultCenter postNotificationName:GYCommonLogScrollLatestNotificationKey object:nil];
        
        [self.lock lock];
        self.latestLog = attributedLog;
        if (!(behavior & GYLogBehaviorAppend) && self.latestLog) {
//                [self.logs removeLastObject];
        }
//            [self.logs addObject:attributedLog];
        [self.lock unlock];
    }
}

#pragma mark - Local Log
- (void)saveDefaultLocalLog:(NSString *)log {
    DDLogDebug(@"%@", log);
}
- (void)saveSuccessLocalLog:(NSString *)log {
    DDLogInfo(@"%@", log);
}
- (void)saveWarningLocalLog:(NSString *)log {
    DDLogWarn(@"%@", log);
}
- (void)saveErrorLocalLog:(NSString *)log {
    DDLogError(@"%@", log);
}

@end
