//
//  GYFoundationManager.h
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/08.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYFoundationManager : NSObject

#pragma mark - Date & Time
+ (NSString *)humanReadableTimeFromInterval:(NSTimeInterval)interval;

#pragma mark - Export
+ (void)exportToPath:(NSString *)path string:(NSString *)string continueWhenExist:(BOOL)continueWhenExist showSuccessLog:(BOOL)showSuccessLog;

@end

NS_ASSUME_NONNULL_END
