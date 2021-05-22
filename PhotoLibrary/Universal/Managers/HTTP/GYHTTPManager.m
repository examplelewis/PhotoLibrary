//
//  GYHTTPManager.m
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#import "GYHTTPManager.h"
#import <AFNetworking/AFNetworking.h>

#import "GYHTTPHeader.h"

@implementation GYHTTPManager

- (void)GET:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:url parameters:parameters error:nil];
    request.timeoutInterval = 15.0f;

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            completionHandler(response, responseObject, error);
            return;
        }
        
        if (!((NSString *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:GYErrorDomainHTTP code:GYErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: GYErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if (!((NSArray *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:GYErrorDomainHTTP code:GYErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: GYErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if (!((NSDictionary *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:GYErrorDomainHTTP code:GYErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: GYErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        
        completionHandler(response, responseObject, nil);
    }];
    [dataTask resume];
}

- (void)POST:(NSString *)url parameters:(id)parameters completionHandler:(nonnull void (^)(NSURLResponse *response, id _Nullable responseObject, NSError * _Nullable error))completionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = responseSerializer;
    
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
    request.timeoutInterval = 15.0f;

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            completionHandler(response, responseObject, error);
            return;
        }
        
        if (!((NSString *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:GYErrorDomainHTTP code:GYErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: GYErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if (!((NSArray *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:GYErrorDomainHTTP code:GYErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: GYErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        if (!((NSDictionary *)responseObject).isNotEmpty) {
            completionHandler(response, responseObject, [NSError errorWithDomain:GYErrorDomainHTTP code:GYErrorCodeAPIReturnEmptyObject userInfo:@{NSLocalizedDescriptionKey: GYErrorLocalizedDescriptionAPIReturnEmptyObject}]);
            return;
        }
        
        completionHandler(response, responseObject, nil);
    }];
    [dataTask resume];
}

@end
