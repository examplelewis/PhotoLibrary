//
//  NSError+GYCommon.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/26.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (GYCommon)

- (NSString *)downloadUrl;
- (GYErrorType)downloadErrorType;

@end

NS_ASSUME_NONNULL_END
