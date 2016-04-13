//
//  AppDelegate.m
//  未名管家
//
//  Created by apple on 15/11/18.
//  Copyright (c) 2015年 eight. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginVC.h"
#import "ReverseVC.h"
#import "ComObj.h"
#import "GuideVC.h"
#import "BaseTabBarController.h"
#import "MBProgressHUD+MJ.h"

#import <BmobSDK/Bmob.h>
#import <BmobSDK/BmobUser.h>
#import <EaseMobSDKFull/EaseMob.h>

@interface AppDelegate ()<EMChatManagerDelegate, UIAlertViewDelegate>
/** 好友的名称 */
@property (nonatomic, copy) NSString *buddyUsername;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //注册远程通知
    if ([UIDevice currentDevice].systemVersion.doubleValue <= 8.0) {
        // 不是iOS8
        UIRemoteNotificationType type = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeNewsstandContentAvailability;
        // 当用户第一次启动程序时就获取deviceToke
        // 该方法在iOS8以及过期了
        // 只要调用该方法, 系统就会自动发送UDID和当前程序的Bunle ID到苹果的APNs服务器
        [application registerForRemoteNotificationTypes:type];
    }else {
        // iOS8
        UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        // 注册通知类型
        [application registerUserNotificationSettings:settings];
        
        // 申请试用通知
        [application registerForRemoteNotifications];
    }
    
    //初始化环信
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"jilindaxue#wmmanager" apnsCertName:@"guanjia_development" otherConfig:@{kSDKConfigEnableConsoleLogger:@(NO)}];
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //设置Bmob秘钥
    [Bmob registerWithAppKey:@"cf350ffb99e19618402682922e6b4c3e"];
    //获取当前用户
    BmobUser *bUser = [BmobUser getCurrentUser];
    
    // 2.设置根控制器
    NSString *key = @"CFBundleVersion";
    // 上一次的使用版本（存储在沙盒中的版本号）
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    // 当前软件的版本号（从Info.plist中获得）
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[key];

    if (![currentVersion isEqualToString:lastVersion]) {
        // 将当前的版本号存进沙盒
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor whiteColor];
        GuideVC *guide = [[GuideVC alloc] init];
        self.window.rootViewController = guide;
        [self.window makeKeyAndVisible];
    }else if (bUser && [currentVersion isEqualToString:lastVersion]) {//如果用户登陆过
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *pwd = [userDefault objectForKey:@"password"];
        //自动登陆到Ease
        BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
        if (!isAutoLogin) {
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:bUser.username password:pwd completion:^(NSDictionary *loginInfo, EMError *error) {
                if (!error) {
                    // 设置自动登录
                    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                    NSLog(@"Ease>>>>>>自动登录成功");
                    
                }
            } onQueue:nil];
        }else {
            NSLog(@"Ease>>>>>>用户已经在线");
        }
        //自动登录到Bmob
        [BmobUser loginInbackgroundWithAccount:bUser.username andPassword:pwd block:^(BmobUser *user, NSError *error) {
            if (user) {
                NSLog(@"%@",user);
                [MBProgressHUD showSuccess:@"登录成功!" toView:self.window];
            } else {
                NSLog(@"%@",error);
            }
        }];
        // 1.创建Window
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor whiteColor];
        // 2.将window的主窗口设置为tabBarController
        BaseTabBarController *tb = [[BaseTabBarController alloc] init];
        // 3.设置根控制器
        self.window.rootViewController = tb;
        // 4.显示Window
        [self.window makeKeyAndVisible];
    }else{
        //对象为空时，可打开用户注册界面
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor whiteColor];
        LoginVC *login = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
    }
    
    return YES;
}

//连接APNs失败时候调用
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"连接APNs失败");
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

//成功连接到APNs时候调用
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //将deviceToken存起来
    NSLog(@"%@",deviceToken);
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"token"];
    // 将得到的deviceToken传给环信服务器
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
}

// App进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

// App将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}

#pragma mark - 接收好友的添加请求
-(void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message{
    
    // 赋值
    self.buddyUsername = username;
    
    // 对话框
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加请求" message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alert show];
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {//拒绝好友请求
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:self.buddyUsername reason:@"我不认识你" error:nil];
    }else{//同意好友请求
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:self.buddyUsername error:nil];
        
    }
}

#pragma mark 好友请求被同意
-(void)didAcceptedByBuddy:(NSString *)username{
    
    // 提醒用户，好友请求被同意
    NSString *message = [NSString stringWithFormat:@"%@ 同意了你的好友请求",username];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加消息" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark 好友请求被拒绝
-(void)didRejectedByBuddy:(NSString *)username{
    // 提醒用户，好友请求被同意
    NSString *message = [NSString stringWithFormat:@"%@ 拒绝了你的好友请求",username];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加消息" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
    
}



@end
