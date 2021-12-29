//
//  GYLog.m
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/12.
//

#import "GYLog.h"

@implementation GYLog

+ (instancetype)defaultLogWithAttributedLog:(NSAttributedString *)attributedLog latestLog:(NSString *)latestLog {
    GYLog *log = GYLog.new;
    log.type = GYLogTypeDefault;
    log.attributedLog = attributedLog;
    log.latestLog = latestLog;
    
    return log;
}
+ (instancetype)fileLogWithAttributedLog:(NSAttributedString *)attributedLog latestLog:(NSString *)latestLog {
    GYLog *log = GYLog.new;
    log.type = GYLogTypeFile;
    log.attributedLog = attributedLog;
    log.latestLog = latestLog;
    
    return log;
}

@end
