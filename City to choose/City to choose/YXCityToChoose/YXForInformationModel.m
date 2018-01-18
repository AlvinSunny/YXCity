//  YXForInformationModel.m
//  Created by 一笑 on 2017/10/18.

#import "YXForInformationModel.h"

@implementation YXForInformationModel
+ (NSString *)whc_SqliteVersion {
    return @"1.0";
}

+ (NSString *)whc_OtherSqlitePath {
    return [NSString stringWithFormat:@"%@/Library/cityDate.db",NSHomeDirectory()];
}

@end
