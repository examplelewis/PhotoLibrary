//
//  GYUtilityManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "GYUtilityManager.h"

@implementation GYUtilityManager

#pragma mark - Date & Time
+ (NSString *)humanReadableTimeFromInterval:(NSTimeInterval)interval {
    NSInteger minutes = interval / 60;
    NSInteger seconds = floor(interval - minutes * 60);
    NSInteger milliseconds = (NSInteger)floor(interval * 1000) % 1000;
    
    return [NSString stringWithFormat:@"%02ld:%02ld.%03ld", minutes, seconds, milliseconds];
}

#pragma mark - Tool
+ (NSString *)readFileAtPath:(NSString *)path {
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        [[GYLogManager defaultManager] addDefaultLogWithFormat:@"文件路径: %@\n读取文件时出现错误: %@", path, [error localizedDescription]];
        return nil;
    } else {
        return content;
    }
}

@end
