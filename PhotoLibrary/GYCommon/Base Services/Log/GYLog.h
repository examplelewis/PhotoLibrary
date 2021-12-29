//
//  GYLog.h
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/12.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GYLogType) {
    GYLogTypeDefault,
    GYLogTypeFile,
};

NS_ASSUME_NONNULL_BEGIN

@interface GYLog : NSObject

@property (assign) GYLogType type;
@property (strong) NSAttributedString *attributedLog;
@property (copy) NSString *latestLog;
@property (assign) BOOL shouldAppend;

+ (instancetype)defaultLogWithAttributedLog:(NSAttributedString *)attributedLog latestLog:(NSString *)latestLog;
+ (instancetype)fileLogWithAttributedLog:(NSAttributedString *)attributedLog latestLog:(NSString *)latestLog;

@end

NS_ASSUME_NONNULL_END
