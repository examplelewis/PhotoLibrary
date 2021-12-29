//
//  NSError+GYCommon.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "NSError+GYCommon.h"

@implementation NSError (GYCommon)

- (NSString *)downloadUrl {
    NSString *url = self.userInfo[NSURLErrorFailingURLStringErrorKey];
    if (url.isNotEmpty) {
        return url;
    }
    
    url = self.userInfo[@"NSErrorFailingURLKey"];
    if (url.isNotEmpty) {
        return url;
    }
    
    url = self.userInfo[@"NSErrorFailingURLStringKey"];
    if (url.isNotEmpty) {
        return url;
    }
    
    return @"";
}
- (GYErrorType)downloadErrorType {
    NSLog(@"error code: %ld", self.code);
    if ([self.localizedDescription containsString:@"The network connection was lost."] || [self.localizedDescription containsString:@"The request timed out."]) {
        return GYErrorTypeDownloadConnectionLost;
    } else {
        return GYErrorTypeDownloadOther;
    }
}

@end
