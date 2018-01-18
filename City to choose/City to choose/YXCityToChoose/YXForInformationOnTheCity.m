//  YXForInformationOnTheCity.m
//  Created by 一笑 on 2017/10/18.

#import "YXForInformationOnTheCity.h"
#import "YXDistrictModel.h"
#import <WHC_ModelSqlite.h>
#import <YYKit/NSObject+YYModel.h>
#import <UIKit/UIKit.h>

//用户信息缓存 名称
#define kForInformationModelObject @"YXForInformationModelObject"

//用户model缓存
#define kYXForInformationModelObject @"YXForInformationModelObject"

static NSString * const kEYCNCityServiceAPIDomain = @"http://restapi.amap.com";

static NSString * const kEYCNCityServiceAPIURI = @"/v3/config/district";

static NSString * const kEYCNCitySerivceErrorDomain = @"cn.robotbros.EYCNCityPickerErrorDomain";


@interface YXForInformationOnTheCity ()

@property (nonatomic, copy) NSString *apikey;

@end

@implementation YXForInformationOnTheCity

- (instancetype _Nullable )initWithAPIKey:(NSString *_Nonnull)key{
    self = [super init];
    if (self) {
        self.apikey = key;
    }
    return self;
}

- (instancetype _Nullable )initWithAPIKey:(NSString *_Nonnull)key citySubdistrictType:(YXSubdistrictType)citySubdistrictType citiesWithCompletion:(YXCityServiceCompletion _Nullable )completion
{
    self = [super init];
    if (self) {
        self.apikey = key;
        self.citySubdistrictType = citySubdistrictType;
        [self requestYXCitiesWithCompletion:^(YXForInformationModel * _Nullable citieInforModel, NSError * _Nullable error) {
            completion(citieInforModel,error);
        }];
    }
    return self;
}

/**@brief 请求中国行政区域数据*/
- (void)requestYXCitiesWithCompletion:(YXCityServiceCompletion)completion{
    
   YXForInformationModel  *informationModel = [self getSortObjectsAccordingToInitial];
    if (![informationModel isKindOfClass:[NSArray class]]) {
        if (informationModel.dateList) {
            completion(informationModel, nil);
            return;
        }
    }
    
    NSAssert(_apikey != nil, @"高德Web API key并未指定，详情请查看：http://developer.amap.com/api/webservice/summary/");
    NSString *baseURLString = _apiCityDomain == nil ? kEYCNCityServiceAPIDomain : _apiCityDomain;
    NSString *apiURI = _apiCityURI == nil ? kEYCNCityServiceAPIURI : _apiCityURI;
    NSString *subdistrict = @"";
    switch (self.citySubdistrictType) {
        case YXSubdistrictProvinceType:
            subdistrict = @"1";
            break;
        case YXSubdistrictCityType:
            subdistrict = @"2";
            break;
        case YXSubdistrictAreaType:
            subdistrict = @"3";
            break;
        default:
            break;
    }
    
    NSString *params = [NSString stringWithFormat:@"?key=%@&subdistrict=%@", _apikey,subdistrict];
    NSString *url = [[baseURLString stringByAppendingPathComponent:apiURI] stringByAppendingString:params];
    NSLog(@"%@",url);
    NSURL *apiURL = [NSURL URLWithString:url];
    NSURLSession *session = [NSURLSession sharedSession];
    __block YXForInformationModel    *inforModel = [[YXForInformationModel alloc]init];
    NSURLSessionDataTask *task =
    [session dataTaskWithURL:apiURL
           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
               if (error) {
                   completion(nil, error);
               } else {
                   NSError *err;
                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableLeaves
                                                                          error:&err];
                   if (err != nil) {
                       NSString *errString = [NSString stringWithFormat:@"解析数据失败，原因: %@", err.localizedDescription];
                       NSError *customErr = [NSError errorWithDomain:kEYCNCitySerivceErrorDomain
                                                                code:-1
                                                            userInfo:@{NSLocalizedDescriptionKey: errString}];
                       completion(nil, customErr);
                   } else {
                       if (![[json objectForKey:@"status"] isEqualToString:@"1"]) {
                           // request failed
                           NSString *errString = [NSString stringWithFormat:@"获取数据失败，原因: %@", [json objectForKey:@"info"]];
                           NSError *customErr = [NSError errorWithDomain:kEYCNCitySerivceErrorDomain
                                                                    code:-2
                                                                userInfo:@{NSLocalizedDescriptionKey: errString}];
                           completion(nil, customErr);
                           return;
                       }
                       
                       NSDictionary *country = [[json objectForKey:@"districts"] firstObject];
                       NSArray *provinces = [country objectForKey:@"districts"];
                       NSMutableArray *newProvinces = [NSMutableArray array];
                       [provinces enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                           
                           switch (self.citySubdistrictType) {
                               case YXSubdistrictProvinceType:
                               {
                                   YXDistrictModel *disModel = [YXDistrictModel modelWithDictionary:obj];
                                   if (![[disModel.name substringFromIndex:disModel.name.length-1] isEqualToString:@"省"]) {//过滤省 添加进来的是特别行政区 或市
                                       disModel.pinyin = [self transform:disModel.name];
                                       disModel.initials = [self firstCharactorWithString:disModel.name];
                                       [newProvinces addObject:disModel];
                                   }
                               }
                                   break;
                               case YXSubdistrictCityType:
                               {
                                   YXDistrictModel *disModel = [YXDistrictModel modelWithDictionary:obj];
                                   if (![[disModel.name substringFromIndex:disModel.name.length-1] isEqualToString:@"省"]) {//过滤省 添加进来的是特别行政区 或市
                                       disModel.pinyin = [self transform:disModel.name];
                                       disModel.initials = [self firstCharactorWithString:disModel.name];
                                       [newProvinces addObject:disModel];
                                   }
                                   NSArray *cities = [obj valueForKeyPath:@"districts"];
                                   [cities enumerateObjectsUsingBlock:^(id item, NSUInteger idx2, BOOL * _Nonnull stop2) {
                                       
                                       YXDistrictModel *disCityModel = [YXDistrictModel modelWithDictionary:item];
                                       if (![[disCityModel.name substringFromIndex:disCityModel.name.length-1] isEqualToString:@"区"]) {//区
                                           disCityModel.pinyin = [self transform:disCityModel.name];
                                           disCityModel.initials = [self firstCharactorWithString:disCityModel.name];
                                           [newProvinces addObject:disCityModel];
                                       }
                                   }];
                               }
                                   break;
                               case YXSubdistrictAreaType:
                               {
                                   YXDistrictModel *disModel = [YXDistrictModel modelWithDictionary:obj];
                                   if (![[disModel.name substringFromIndex:disModel.name.length-1] isEqualToString:@"省"]) {//过滤省 添加进来的是特别行政区 或市
                                       disModel.pinyin = [self transform:disModel.name];
                                       disModel.initials = [self firstCharactorWithString:disModel.name];
                                       [newProvinces addObject:disModel];
                                   }
                                   
                                   NSArray *cities = [obj valueForKeyPath:@"districts"];
                                   [cities enumerateObjectsUsingBlock:^(id item, NSUInteger idx2, BOOL * _Nonnull stop2) {
                                       
                                       YXDistrictModel *disCityModel = [YXDistrictModel modelWithDictionary:item];
                                       if (![[disCityModel.name substringFromIndex:disCityModel.name.length-1] isEqualToString:@"区"]) {//区
                                           disCityModel.pinyin = [self transform:disCityModel.name];
                                           disCityModel.initials = [self firstCharactorWithString:disCityModel.name];
                                           [newProvinces addObject:disCityModel];

                                       }
                                       
                                       NSArray *regions = [item valueForKeyPath:@"districts"];
                                       [regions enumerateObjectsUsingBlock:^(id item2, NSUInteger idx, BOOL * _Nonnull stop) {
                                           YXDistrictModel *disCountyModel = [YXDistrictModel modelWithDictionary:item2];
                                           if (![[disCountyModel.name substringFromIndex:disCountyModel.name.length-1] isEqualToString:@"区"]) {//区
                                               disCountyModel.pinyin = [self transform:disCountyModel.name];
                                               disCountyModel.initials = [self firstCharactorWithString:disCountyModel.name];
                                               [newProvinces addObject:disCountyModel];
                                           }
                                       }];
                                   }];
                               }
                                   break;
                               default:
                                   break;
                           }
                           
                       }];
                       
                       inforModel  = [self sortObjectsAccordingToInitialWith:newProvinces];
                       completion(inforModel, nil);
                   }
               }
           }];
    [task resume];
}

/**
 开始获取城市信息
 */
- (void)configCities
{
    self.citySubdistrictType = _citySubdistrictType == 0 ? YXSubdistrictAreaType : _citySubdistrictType;
    [self requestYXCitiesWithCompletion:^(YXForInformationModel * _Nullable citieInforModel, NSError * _Nullable error) {
        if ([self.delegate respondsToSelector:@selector(requestYXCitiesWithYXForInformationModel:error:)]) {
            [self.delegate requestYXCitiesWithYXForInformationModel:citieInforModel error:error];
        }
    }];
}

//inforModel  = [self sortObjectsAccordingToInitialWith:newProvinces];
// 按首字母分组排序数组
-(YXForInformationModel *)sortObjectsAccordingToInitialWith:(NSArray *)newProvinces {
    
    // 初始化UILocalizedIndexedCollation
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    //得出collation索引的数量，这里是27个（26个字母和1个#）
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    //初始化一个数组newSectionsArray用来存放最终的数据，我们最终要得到的数据模型应该形如@[@[以A开头的数据数组], @[以B开头的数据数组], @[以C开头的数据数组], ... @[以#(其它)开头的数据数组]]
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
    //初始化27个空数组加入newSectionsArray
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }
    
    //将每个名字分到某个section下
    for (YXDistrictModel *personModel in newProvinces) {
        //获取name属性的值所在的位置，比如"汪峰"，首字母是W，在A~Z中排第11（第一位是0），sectionNumber就为11
        NSInteger sectionNumber = [collation sectionForObject:personModel collationStringSelector:@selector(name)];
        //把name为“汪峰”的p加入newSectionsArray中的第11个数组中去
        NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
        [sectionNames addObject:personModel];
    }
    
    //对每个section中的数组按照name属性排序
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *personArrayForSection = newSectionsArray[index];
        NSArray *sortedPersonArrayForSection = [collation sortedArrayFromArray:personArrayForSection collationStringSelector:@selector(name)];
        newSectionsArray[index] = sortedPersonArrayForSection;
    }
    
    //删除空的数组
    NSMutableArray *nameKeyList = [NSMutableArray new];
    NSArray *list = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    NSMutableArray *dateList = [NSMutableArray new];
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        if (((NSMutableArray *)(newSectionsArray[index])).count != 0) {
            [dateList addObject:newSectionsArray[index]];
            [nameKeyList addObject:list[index]];
        }
    }
    YXForInformationModel    *informationModel = [YXForInformationModel modelWithDictionary:@{@"nameKeyList":nameKeyList,@"dateList":dateList}];
    //数据存储
    if ([WHCSqlite insert:informationModel]) {
        NSLog(@"数据存储成功");
        YXForInformationModel  *infor = [[WHCSqlite query:[YXForInformationModel class] where:nil] firstObject];
        NSLog(@"%ld ---%ld",infor.nameKeyList.count,infor.dateList.count);
    }
    return informationModel;
}

- (YXForInformationModel *)getSortObjectsAccordingToInitial{
    YXForInformationModel   *iformationModel = [[YXForInformationModel alloc]init];
    NSArray  *list = [WHCSqlite query:[YXForInformationModel class]];
    if (list.count==1) {
        iformationModel = [list firstObject];
    }
    return iformationModel;
}

- (NSString *)transform:(NSString *)chinese{
    //将NSString装换成NSMutableString
    NSMutableString *pinyin = [chinese mutableCopy];
    //将汉字转换为拼音(带音标)
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    //去掉拼音的音标
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    //返回最近结果
    return pinyin;
}

//获取某个字符串或者汉字的首字母.
- (NSString *)firstCharactorWithString:(NSString *)string
{
    NSMutableString *str = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef) str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString *pinYin = [str capitalizedString];
    return [pinYin substringToIndex:1];
}

@end

