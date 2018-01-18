//  YXDistrictModel.h
//  Created by 一笑 on 2017/10/18.

#import <Foundation/Foundation.h>
#import <WHC_ModelSqlite.h>

@interface YXDistrictModel : NSObject  <NSCoding>

/**城市编码*/
@property (nonatomic, copy) NSString          *citycode;
/**地理编码*/
@property (nonatomic, copy) NSString          *adcode;
/**城市名称*/
@property (nonatomic, copy) NSString          *name;
/**中心点经纬度*/
@property (nonatomic, copy) NSString          *center;
/**城市级别*/
@property (nonatomic, copy) NSString          *level;
/**区域*/
@property (nonatomic, strong) NSArray         *districts;
/** 城市名称-拼音*/
@property (nonatomic, copy) NSString *pinyin;
/** 城市名称-拼音首字母*/
@property (nonatomic, copy) NSString *initials;

@end

