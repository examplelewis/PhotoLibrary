//
//  GYHTTPManager.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface GYHTTPManager : NSObject

- (void)GET:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

- (void)POST:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
