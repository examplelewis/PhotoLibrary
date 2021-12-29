//
//  GYFoundationManager.m
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/08.
//

#import "GYFoundationManager.h"

@implementation GYFoundationManager

#pragma mark - Date & Time
+ (NSString *)humanReadableTimeFromInterval:(NSTimeInterval)interval {
    NSInteger minutes = interval / 60;
    NSInteger seconds = floor(interval - minutes * 60);
    NSInteger milliseconds = (NSInteger)floor(interval * 1000) % 1000;
    
    return [NSString stringWithFormat:@"%02ld:%02ld.%03ld", minutes, seconds, milliseconds];
}

+ (void)exportToPath:(NSString *)path string:(NSString *)string continueWhenExist:(BOOL)continueWhenExist showSuccessLog:(BOOL)showSuccessLog {
    if ([GYFileManager fileExistsAtPath:path]) {
        // 如果需要接着写的话，那么先添加分隔符
        if (continueWhenExist) {
            string = [NSString stringWithFormat:@"\n\n----------%@ 添加内容----------\n\n%@", [NSDate.date dateStringWithFormat:GYTimeFormatyMdHms], string];
        }
    } else {
        [GYFileManager createFileAtPath:path];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    if ([fileHandle closeAndReturnError:&error]) {
        if (showSuccessLog) {
            [GYLogManager.defaultManager addDefaultLogWithFormat:@"结果文件导出成功，请查看：%@", path];
        }
    } else {
        [GYLogManager.defaultManager addErrorLogWithFormat:@"导出结果文件出错：%@", error.localizedDescription];
    }
}

@end
