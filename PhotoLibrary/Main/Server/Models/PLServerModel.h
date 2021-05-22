//
//  PLServerModel.h
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLServerModel : NSObject

@property(nonatomic, copy) NSString *hostName;
@property(nonatomic, copy) NSString *ipAddress;
@property(nonatomic, copy) NSString *username;
@property(nonatomic, copy) NSString *password;

+ (instancetype)modelWithHostName:(NSString *)hostName ipAddress:(NSString *)ipAddress;

@end

NS_ASSUME_NONNULL_END
