//
//  NSDate+GYCommon.m
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/12.
//

#import "NSDate+GYCommon.h"

@implementation NSDate (GYCommon)

- (NSString *)dateStringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_CN"]];
    return [formatter stringFromDate:self];
}

@end
