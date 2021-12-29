//
//  NSDictionary+GYCommon.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSDictionary+GYCommon.h"

@implementation NSDictionary (GYCommon)

#pragma mark - Empty
- (BOOL)isNotEmpty {
    return [self isKindOfClass:[NSDictionary class]] && self.count > 0;
}

#pragma mark - String
- (NSString *)readableJSONString {
    if (!self.readableJSONData) {
        return nil;
    }
    
    return [NSString.alloc initWithData:self.readableJSONData encoding:NSUTF8StringEncoding];
}
- (NSData *)readableJSONData {
    if (!self.isNotEmpty) {
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
}

#pragma mark - Export
- (void)exportToPath:(NSString *)path {
    [self exportToPath:path continueWhenExist:YES];
}
- (void)exportToPath:(NSString *)path continueWhenExist:(BOOL)continueWhenExist {
    GYFileOpertaionBehavior behavior = GYFileOpertaionBehaviorNone;
    if (continueWhenExist) {
        behavior = behavior | GYFileOpertaionBehaviorContinueWhenExists;
    }
    
    [self exportToPath:path behavior:behavior];
}
- (void)exportToPath:(NSString *)path behavior:(GYFileOpertaionBehavior)behavior {
    BOOL showNoneLog = behavior & GYFileOpertaionBehaviorShowNoneLog;
    BOOL showSuccessLog = behavior & GYFileOpertaionBehaviorShowSuccessLog;
    BOOL exportNoneLog = behavior & GYFileOpertaionBehaviorExportNoneLog;
    BOOL continueWhenExist = behavior & GYFileOpertaionBehaviorContinueWhenExists;
    
    if (!self.isNotEmpty) {
        if (showNoneLog) {
            [GYLogManager.defaultManager addWarningLogWithFormat:@"输出到: %@ 的内容为空，已忽略", path];
        }
        if (!exportNoneLog) {
            return;
        }
    }
    
    [GYFoundationManager exportToPath:path string:self.readableJSONString continueWhenExist:continueWhenExist showSuccessLog:showSuccessLog];
}

- (void)exportToPlistPath:(NSString *)plistPath {
    [self exportToPlistPath:plistPath behavior:GYFileOpertaionBehaviorNone];
}
- (void)exportToPlistPath:(NSString *)plistPath behavior:(GYFileOpertaionBehavior)behavior {
    BOOL showNoneLog = behavior & GYFileOpertaionBehaviorShowNoneLog;
    BOOL showSuccessLog = behavior & GYFileOpertaionBehaviorShowSuccessLog;
    BOOL exportNoneLog = behavior & GYFileOpertaionBehaviorExportNoneLog;
    
    if (!self.isNotEmpty) {
        if (showNoneLog) {
            [GYLogManager.defaultManager addWarningLogWithFormat:@"输出到: %@ 的内容为空，已忽略", plistPath];
        }
        if (!exportNoneLog) {
            return;
        }
    }
    
    NSError *error;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListBinaryFormat_v1_0 options:kNilOptions error:NULL];
    if (error) {
        [GYLogManager.defaultManager addErrorLogWithFormat:@"导出结果文件出错：%@", error.localizedDescription];
        return;
    }
    
    if ([plistData writeToFile:plistPath atomically:YES]) {
        if (showSuccessLog) {
            [GYLogManager.defaultManager addDefaultLogWithFormat:@"结果文件导出成功，请查看：%@", plistPath];
        }
    }
}

@end
