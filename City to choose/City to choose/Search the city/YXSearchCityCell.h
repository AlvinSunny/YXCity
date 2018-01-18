//
//  YXSearchCityCell.h
//  范时特
//
//  Created by 一笑 on 2017/12/28.
//  Copyright © 2017年 boyikeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXSearchCityCell : UITableViewCell

- (void)configTitleString:(NSString *)titleString;

- (instancetype)initWithTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UILabel *lineLb;

@end
