//
//  LoginVC.m
//  未名管家
//
//  Created by apple on 15/11/18.
//  Copyright (c) 2015年 eight. All rights reserved.
//

#import "LoginVC.h"
#import "RegistVC.h"
#import "MBProgressHUD+MJ.h"
#import "ReverseVC.h"
#import "ComObj.h"
#import "BaseTabBarController.h"

#import <BmobUser.h>
#import <EaseMobSDKFull/EaseMob.h>

@interface LoginVC () <RegistVCdelegate>
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UISwitch *rmbPwdSwitch;

@end

@implementation LoginVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *pwdStr = [userDefault objectForKey:@"password"];
    NSString *userStr = [userDefault objectForKey:@"userName"];
    self.rmbPwdSwitch.on = [userDefault boolForKey:@"switchStatus"];
    self.userField.text = userStr;
    if ([self.rmbPwdSwitch isOn]) {
        self.pwdField.text = pwdStr;
    }
    
}
//登录
- (IBAction)loginBtnClicked:(id)sender {
    if ([self.pwdField.text isEqualToString:@""] || [self.userField.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"用户名或密码不得为空" toView:self.view];
        return;
    }
    //登录到Bmob
    [BmobUser loginInbackgroundWithAccount:self.userField.text andPassword:self.pwdField.text block:^(BmobUser *user, NSError *error) {
        if (user) {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:self.pwdField.text forKey:@"password"];
            [userDefault setObject:self.userField.text forKey:@"userName"];
            [userDefault setBool:self.rmbPwdSwitch.isOn forKey:@"switchStatus"];
            //将window的主窗口设置为tabBarController
            BaseTabBarController *tb = [[BaseTabBarController alloc] init];
            self.view.window.rootViewController = tb;
        } else {
            if (error.code == 101) {
                [MBProgressHUD showError:@"用户名或密码不正确" toView:self.view];
            }
        }
    }];
    
    //登录到Ease
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:self.userField.text password:self.pwdField.text completion:^(NSDictionary *loginInfo, EMError *error) {
        if (!error && loginInfo) {
            NSLog(@"Ease>>>>>>>登陆成功");
            [MBProgressHUD showSuccess:@"登陆成功!" toView:self.view.window];
        }
    } onQueue:nil];
}
//忘记密码
- (IBAction)lostPwdBtnClicked:(id)sender {
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - RegistVCdelegate
- (void)registUser:(NSString *)user password:(NSString *)pwd {
    self.userField.text = user;
    self.pwdField.text = pwd;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[RegistVC class]]) {
        RegistVC *registVC = segue.destinationViewController;
        registVC.delegate = self;
    }
}

@end
