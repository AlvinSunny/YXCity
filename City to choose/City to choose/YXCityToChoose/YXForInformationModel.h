//  YXForInformationModel.h
//  Created by 一笑 on 2017/10/18.


#import <Foundation/Foundation.h>
#import <WHC_ModelSqlite.h>

@interface YXForInformationModel : NSObject <WHC_SqliteInfo>

@property (nonatomic, strong) NSMutableArray            *nameKeyList;

@property (nonatomic, strong) NSMutableArray            *dateList;

+ (NSString *)whc_SqliteVersion;

@end
