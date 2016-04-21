//
//  SettingsVC.m
//  未名管家
//
//  Created by apple on 16/2/29.
//  Copyright © 2016年 eight. All rights reserved.
//

#import "SettingsVC.h"
#import "UserDetailVC.h"

#import <EaseMobSDKFull/EaseMob.h>
#import <BmobSDK/BmobUser.h>
#import <BmobQuery.h>

@interface SettingsVC () <EMChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *loginUsername = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    

    
    BmobUser *bUser = [BmobUser getCurrentUser];
    self.navigationItem.title = bUser.username;
    
    self.iconView.image = [UIImage imageNamed:@"头像"];
    self.nickName.text = @"我是昵称";
    self.userName.text = [NSString stringWithFormat:@"用户名:%@",bUser.username];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Nick"];
    //查找GameScore表的数据
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"error is:%@",error);
        } else{
            NSDictionary *dict = [array lastObject];
            self.nickName.text = [dict objectForKey:@"nickName"];
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }];
}



#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UserDetailVC *detail =  segue.destinationViewController;
    detail.nick = self.nickName.text;
}


@end
