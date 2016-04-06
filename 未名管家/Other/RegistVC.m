//
//  RegistVC.m
//  未名管家
//
//  Created by apple on 15/11/18.
//  Copyright (c) 2015年 eight. All rights reserved.
//

#import "RegistVC.h"
#import "MBProgressHUD+MJ.h"
#import "LoginVC.h"

#import <BmobSDK/BmobUser.h>
#import <EaseMobSDKFull/EaseMob.h>

@interface RegistVC ()
@property (weak, nonatomic) IBOutlet UITextField *userFiled;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UITextField *pwdSureField;
@property (weak, nonatomic) IBOutlet UITextField *labPwdField;

@end

@implementation RegistVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.userFiled becomeFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//注册按钮点击
- (IBAction)registClicked:(id)sender {
    [self judgeUser];
}

//判断用户信息逻辑
- (void)judgeUser {
    if ([self.userFiled.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入用户名" toView:self.view];
        return;
    }else if ([self.pwdField.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入密码" toView:self.view];
        return;
    }else if ([self.pwdSureField.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入确认密码" toView:self.view];
        return;
    }else if ([self.labPwdField.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"请输入实验室密码" toView:self.view];
        return;
    }
    if (self.pwdField.text.length < 6) {
        [MBProgressHUD showError:@"密码长度不得小于6位" toView:self.view];
        return;
    }else if (![self.pwdSureField.text isEqualToString:self.pwdField.text]) {
        [MBProgressHUD showError:@"两次密码不一致" toView:self.view];
        return;
    }
    else if (![self.labPwdField.text isEqualToString:@"renrendouaiycl"]) {
        [MBProgressHUD showError:@"实验室密码不正确！" toView:self.view];
        return;
    }else if ([self hasChinese:self.userFiled.text]) {
        [MBProgressHUD showError:@"用户名只能含有英文和数字" toView:self.view];
        return;
    }else {
        [self registToBmob];
        [self registToEase];
    }
}

- (BOOL)hasChinese:(NSString *)str {
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
            return YES;
    }
    return NO;
}

/**注册用户到bmob平台*/
- (void)registToBmob {
    BmobUser *bUser = [[BmobUser alloc] init];
    [bUser setUsername:self.userFiled.text];
    [bUser setPassword:self.pwdField.text];
    [bUser signUpInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful){
            NSLog(@"Bmob>>>>>>注册成功");
            [MBProgressHUD showSuccess:@"注册成功" toView:self.view.window];
            //通知代理将用户名和密码填充到文本框
            [self.delegate registUser:self.userFiled.text password:self.pwdField.text];

            //跳转到登录控制器
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"%@",error);
            if (error.code == 202) {
                
                [MBProgressHUD showError:@"用户已经存在，请重新注册" toView:self.view];
                self.userFiled.text = nil;
                [self.userFiled becomeFirstResponder];
            }
        }
    }];
}

/**注册用户到环信*/
- (void)registToEase {
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:self.userFiled.text
                                                         password:self.pwdField.text
                                                   withCompletion:^(NSString *username, NSString *password, EMError*error) {
        //TODO
        if (!error) {
            NSLog(@"EaseMob>>>>>>注册成功");
        }else {
            NSLog(@"EaseMob>>>>>>%@",error);
        }
    } onQueue:nil];
    
}

@end
