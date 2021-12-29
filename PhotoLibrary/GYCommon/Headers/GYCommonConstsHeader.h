//
//  GYCommonConstsHeader.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#ifndef GYCommonConstsHeader_h
#define GYCommonConstsHeader_h

typedef NS_OPTIONS(NSUInteger, GYFileOpertaionBehavior) {
    GYFileOpertaionBehaviorNone             = 0,
    GYFileOpertaionBehaviorShowSuccessLog   = 1 << 0,
    GYFileOpertaionBehaviorShowNoneLog      = 1 << 1,
    GYFileOpertaionBehaviorExportNoneLog    = 1 << 2,
    GYFileOpertaionBehaviorContinueWhenExists  = 1 << 3,
};

typedef NS_ENUM(NSUInteger, GYErrorType) {
    GYErrorTypeDownloadOther,
    GYErrorTypeDownloadConnectionLost,
};

// Time Format
static NSString * const GYTimeFormatCompactyMd = @"yyyyMMdd";
static NSString * const GYTimeFormatyMdHms = @"yyyy-MM-dd HH:mm:ss";
static NSString * const GYTimeFormatyMdHmsS = @"yyyy-MM-dd HH:mm:ss.SSS";
static NSString * const GYTimeFormatEMdHmsZy = @"EEE MMM dd HH:mm:ss Z yyyy";
static NSString * const GYTimeFormatyMdHmsCompact = @"yyyyMMddHHmmss";

// Warning
static NSString * const GYWarningNoneContentFoundInInputTextView = @"没有获得任何输入内容，请检查输入框";
static NSString * const GYWarningWrongContentFoundInInputTextView = @"输入框的内容有误，请检查";

#endif /* GYCommonConstHeader_h */
