//
//  GYSQLiteSettingManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYSQLiteSettingManager : NSObject

+ (void)backupDatabase;
// 以下两个方法未测试
//+ (void)restoreDatebase;
//+ (void)removeDuplicates;

@end

NS_ASSUME_NONNULL_END
