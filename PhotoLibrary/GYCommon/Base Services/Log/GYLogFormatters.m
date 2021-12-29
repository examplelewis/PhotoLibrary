//
//  GYLogFormatters.m
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/18.
//

#import "GYLogFormatters.h"

@implementation GYFileLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    return logMessage->_message;
}

@end

@implementation GYOSLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    return [logMessage->_message componentsSeparatedByString:@"\n"].lastObject;
}

@end
