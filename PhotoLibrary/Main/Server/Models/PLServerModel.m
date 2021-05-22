//
//  PLServerModel.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/22.
//

#import "PLServerModel.h"

@implementation PLServerModel

+ (instancetype)modelWithHostName:(NSString *)hostName ipAddress:(NSString *)ipAddress {
    PLServerModel *model = [PLServerModel new];
    model.hostName = hostName;
    model.ipAddress = ipAddress;
    model.username = @"examplelewis";
    model.password = @"Example@163.COM";
    
    return model;
}

@end
