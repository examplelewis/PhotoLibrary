//
//  GYExceptionManager.h
//  PodsGYCommon
//
//  Created by 龚宇 on 21/12/09.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYExceptionManager : NSObject

void uncaughtExceptionHandler(NSException *exception);

@end

NS_ASSUME_NONNULL_END