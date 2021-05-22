//
//  NSArray+GYAdd.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/13.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (GYAdd)

- (BOOL)isNotEmpty;

- (NSString *)stringValue;

#pragma mark - Export
- (void)exportToPath:(NSString *)path;
- (void)exportToPath:(NSString *)path behavior:(GYFileOpertaionBehavior)behavior;

- (void)exportToPlistPath:(NSString *)plistPath;
- (void)exportToPlistPath:(NSString *)plistPath behavior:(GYFileOpertaionBehavior)behavior;

@end

NS_ASSUME_NONNULL_END
