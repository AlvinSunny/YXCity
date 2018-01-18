//
//  YXSearchTheCityView.h
//  范时特
//
//  Created by 一笑 on 2017/12/21.
//  Copyright © 2017年 boyikeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YXSearchTheCityViewDelegate <NSObject>

/**取消搜索城市*/
- (void)cancelSearchTheCity;

/**城市名称*/
- (void)cityNameTitle:(NSString *)title cityCode:(NSString *)cityCode;

@end

@interface YXSearchTheCityView : UIView
//
- (void)loadData;

@property (nonatomic, weak) id <YXSearchTheCityViewDelegate> delegate;

@end
