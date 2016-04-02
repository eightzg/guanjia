//
//  AddFriendVC.m
//  未名管家
//
//  Created by apple on 16/3/9.
//  Copyright © 2016年 eight. All rights reserved.
//

#import "AddFriendVC.h"
#import <EaseMobSDKFull/EaseMob.h>
#import "MBProgressHUD+MJ.h"

@interface AddFriendVC ()<EMChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation AddFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加";
//    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (IBAction)addFriend:(id)sender {
    NSLog(@"添加好友按钮点击");
    // 添加好友
    
    // 1.获取要添加好友的名字
    NSString *username = self.textField.text;
    
    
    // 2.向服务器发送一个添加好友的请求
    // buddy 哥儿们
    // message ： 请求添加好友的 额外信息
    NSString *loginUsername = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    NSString *message = [@"我是" stringByAppendingString:loginUsername];
    
    EMError *error =  nil;
    [[EaseMob sharedInstance].chatManager addBuddy:username message:message error:&error];
    if (error) {
        NSLog(@"添加好友失败 %@",error);
        
    }else{
        NSLog(@"添加好友成功");
//        [MBProgressHUD showSuccess:@"添加好友成功" toView:self.view.window];
//        [self.navigationController popViewControllerAnimated:YES];
    }
}



@end
