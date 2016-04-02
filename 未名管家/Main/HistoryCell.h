//
//  HistoryCell.h
//  未名管家
//
//  Created by apple on 15/11/20.
//  Copyright (c) 2015年 eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *dict;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
