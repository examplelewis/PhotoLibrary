//
//  NSString+GYAdd.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSString+GYAdd.h"

@implementation NSString (GYAdd)

- (BOOL)isNotEmpty {
    return [self isKindOfClass:[NSString class]] && self.length > 0;
}

- (NSString *)md5Middle {
    if (self.length != 32) { // MD5都是32位的
        return self;
    } else {
        return [self substringWithRange:NSMakeRange(self.length / 4, self.length / 2)];
    }
}
- (NSString *)md5Middle8 {
    if (self.length != 32) { // MD5都是32位的
        return self;
    } else {
        return [self substringWithRange:NSMakeRange(self.length * 3 / 8, self.length / 4)];
    }
}

- (NSString *)removeEmoji {
    __block NSMutableString *temp = [NSMutableString string];
    [self enumerateSubstringsInRange: NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
        const unichar hs = [substring characterAtIndex: 0];
        if (0xd800 <= hs && hs <= 0xdbff) { // surrogate pair
            const unichar ls = [substring characterAtIndex: 1];
            const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
            
            [temp appendString: (0x1d000 <= uc && uc <= 0x1f77f)? @"": substring]; // U+1D000-1F77F
        } else { // non surrogate
            [temp appendString: (0x2100 <= hs && hs <= 0x26ff)? @"": substring]; // U+2100-26FF
        }
    }];
    
    return [temp copy];
}

#pragma mark - Export
- (void)exportToPath:(NSString *)path {
    [self exportToPath:path behavior:GYFileOpertaionBehaviorNone];
}
- (void)exportToPath:(NSString *)path behavior:(GYFileOpertaionBehavior)behavior {
    BOOL showNoneLog = behavior & GYFileOpertaionBehaviorShowNoneLog;
    BOOL showSuccessLog = behavior & GYFileOpertaionBehaviorShowSuccessLog;
    BOOL exportNoneLog = behavior & GYFileOpertaionBehaviorExportNoneLog;
    
    if (!self.isNotEmpty) {
        if (showNoneLog) {
            [[GYLogManager defaultManager] addWarningLogWithFormat:@"输出到: %@ 的内容为空%@，已忽略", path];
        }
        if (!exportNoneLog) {
            return;
        }
    }
    
    NSError *error;
    if ([self writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        if (showSuccessLog) {
            [[GYLogManager defaultManager] addDefaultLogWithFormat:@"结果文件导出成功，请查看：%@", path];
        }
    } else {
        [[GYLogManager defaultManager] addErrorLogWithFormat:@"导出结果文件出错：%@", error.localizedDescription];
    }
}

@end
