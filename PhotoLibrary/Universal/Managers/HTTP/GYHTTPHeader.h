//
//  GYHTTPHeader.h
//  MyUniqueBox
//
//  Created by 龚宇 on 20/09/29.
//  Copyright © 2020 龚宇. All rights reserved.
//

#ifndef GYHTTPHeader_h
#define GYHTTPHeader_h

#pragma mark - Domain
static NSString * const GYErrorDomainHTTP = @"com.gongyu.MyUniqueBox.HTTP";
static NSString * const GYErrorDomainHTTPWeiboAPI = @"com.gongyu.MyUniqueBox.HTTP.weiboApi";
static NSString * const GYErrorDomainHTTPExHentaiAPI = @"com.gongyu.MyUniqueBox.HTTP.exHentaiApi";


#pragma mark - Code
static NSInteger const GYErrorCodeAPIReturnEmptyObject = -10001;
static NSInteger const GYErrorCodeAPIReturnUselessObject = -10002;

#pragma mark - UserInfo
static NSString * const GYErrorLocalizedDescriptionAPIReturnEmptyObject = @"接口返回空数据";
static NSString * const GYErrorLocalizedDescriptionAPIReturnUselessObject = @"接口未返回可用数据";

#pragma mark - Weibo



#endif /* GYHTTPHeader_h */
