//
//  GYExceptionManager.m
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/09.
//

#import "GYExceptionManager.h"

@implementation GYExceptionManager

//在AppDelegate中注册后，程序崩溃时会执行的方法
void uncaughtExceptionHandler(NSException *exception) {
    NSString *crashTime = [[NSDate date] dateStringWithFormat:@"yyyy-MM-dd HH:mm:ss.ssssssZZZ"];
    NSString *exceptionInfo = [NSString stringWithFormat:@"【此处出现闪退】-----\ncrashTime: %@\nException reason: %@\nException name: %@\nException stack:%@", crashTime, [exception name], [exception reason], [exception callStackSymbols]];
    
    [GYLogManager.defaultManager saveErrorLocalLog:exceptionInfo];
}

@end
