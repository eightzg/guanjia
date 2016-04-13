//
//  UserDetailVC.m
//  未名管家
//
//  Created by apple on 16/4/6.
//  Copyright © 2016年 eight. All rights reserved.
//

#import "UserDetailVC.h"
#import <BmobSDK/BmobUser.h>

@interface UserDetailVC ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@end

@implementation UserDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.iconView.image = [UIImage imageNamed:@"头像"];
    BmobUser *bUser = [BmobUser getCurrentUser];
    self.userName.text = bUser.username;
    self.hidesBottomBarWhenPushed = YES;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
