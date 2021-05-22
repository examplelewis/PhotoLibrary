//
//  GYUtilityManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYUtilityManager : NSObject

#pragma mark - Date & Time
+ (NSString *)humanReadableTimeFromInterval:(NSTimeInterval)interval;

#pragma mark - Tool
+ (NSString *)readFileAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
