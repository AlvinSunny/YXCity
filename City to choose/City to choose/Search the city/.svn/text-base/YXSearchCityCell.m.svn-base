//  YXSearchCityCell.m
//  范时特
//  Created by 一笑 on 2017/12/28.
//  Copyright © 2017年 boyikeji. All rights reserved.

#import "YXSearchCityCell.h"

@interface YXSearchCityCell  ()

@property (weak, nonatomic) IBOutlet UILabel *searchTitle;

@end

@implementation YXSearchCityCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configTitleString:(NSString *)titleString{
    self.searchTitle.text = titleString;
}

- (instancetype)initWithTableView:(UITableView *)tableView
{
    static NSString *Id = @"YXSearchCityCellId";
    YXSearchCityCell *cell = [tableView dequeueReusableCellWithIdentifier:Id];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"YXSearchCityCell" owner:nil options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
