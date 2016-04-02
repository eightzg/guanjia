//
//  HistoryCell.m
//  未名管家
//
//  Created by apple on 15/11/20.
//  Copyright (c) 2015年 eight. All rights reserved.
//

#import "HistoryCell.h"

@interface HistoryCell()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *periodLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;


@end

@implementation HistoryCell

- (void)setDict:(NSDictionary *)dict {
    _dict = dict;
    self.dateLabel.text = [dict objectForKey:@"date"];
    self.periodLabel.text = [dict objectForKey:@"timePeriod"];
    self.reasonLabel.text = [NSString stringWithFormat:@"预订原因：%@",[dict objectForKey:@"reason"]];
    
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"cell";
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HistoryCell" owner:nil options:nil] firstObject];
    }
    
    return cell;
}

@end
