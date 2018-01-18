//  YXForInformationOnTheCity.h
//  Created by 一笑 on 2017/10/18.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "YXForInformationModel.h"

typedef NS_ENUM(NSInteger, YXSubdistrictType)
{
    YXSubdistrictProvinceType = 1,         //省
    YXSubdistrictCityType = 2,             //市
    YXSubdistrictAreaType = 3              //县
};

typedef void (^YXCityServiceCompletion)(YXForInformationModel * _Nullable citieInforModel, NSError * _Nullable error);

@protocol YXForInformationDelegate <NSObject>

- (void)requestYXCitiesWithYXForInformationModel:(YXForInformationModel *_Nullable)information error:(NSError * _Nullable)error;

@end

@interface YXForInformationOnTheCity : NSObject

/** 高德web api Domain，默认地址:http://lbs.amap.com/api/webservice/guide/api/district*/
@property (nonatomic, copy, nullable) NSString *apiCityDomain;

/// URI : 在电脑术语中，统一资源标识符（Uniform Resource Identifier，或URI)是一个用于标识某一互联网资源名称的字符串。
/**高德获取行政区域web api URI, 默认地址: /v3/config/district*/
@property (nonatomic, copy, nullable) NSString *apiCityURI;

/**需要获取的城市信息级别*/
@property (nonatomic, assign) YXSubdistrictType  citySubdistrictType;

@property (nonatomic, weak,nullable) id <YXForInformationDelegate> delegate;

/**
 初始化服务
 @param key key 高德web API Key，详情请查看：http://developer.amap.com/api/webservice/summary/
 @param citySubdistrictType 需要获取的城市信息级别
 @param completion 回调查询结果
 @return 实例
 */
- (instancetype _Nullable )initWithAPIKey:(NSString *_Nonnull)key citySubdistrictType:(YXSubdistrictType)citySubdistrictType citiesWithCompletion:(YXCityServiceCompletion _Nullable )completion;

/**
 初始化服务
 @param key key 高德web API Key，
 @return 实例
 */
- (instancetype _Nullable )initWithAPIKey:(NSString *_Nonnull)key;

/**
 开始获取城市信息
 */
- (void)configCities;

@end

