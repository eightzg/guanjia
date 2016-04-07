//
//  SettingsVC.m
//  未名管家
//
//  Created by apple on 16/2/29.
//  Copyright © 2016年 eight. All rights reserved.
//

#import "SettingsVC.h"
#import <EaseMobSDKFull/EaseMob.h>
#import <BmobSDK/BmobUser.h>

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
    
    self.iconView.image = [UIImage imageNamed:@"icon_image"];
    self.nickName.text = @"我是昵称";
    self.userName.text = [NSString stringWithFormat:@"用户名:%@",bUser.username];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
}

- (void)didReceiveMessage:(EMMessage *)message {
    NSLog(@"接收到消息>>>>>>%@",message);
}

#pragma mark - Table view data source

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 1;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    static NSString *ID = @"cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
//    }
//    
//    cell.textLabel.text = @"我是设置";
//    
//    return cell;
//}


@end
