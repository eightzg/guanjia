//
//  UserDetailVC.m
//  未名管家
//
//  Created by apple on 16/4/6.
//  Copyright © 2016年 eight. All rights reserved.
//

#import "UserDetailVC.h"
#import "ChangeNickVC.h"
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
    //设置昵称Label的文字；
    self.nickName.text = self.nick;
}

//push的时候隐藏底部tab
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChangeNickVC *change =  segue.destinationViewController;
    change.nick = self.nickName.text;
    //block实现部分，进行传值
    change.block = ^(NSString *string) {
        self.nickName.text = string;
    };
}

@end
