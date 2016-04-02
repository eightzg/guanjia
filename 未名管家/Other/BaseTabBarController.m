//
//  BaseTabBarController.m
//  未名管家
//
//  Created by apple on 16/3/2.
//  Copyright © 2016年 eight. All rights reserved.
//  tabBar的父类

#import "BaseTabBarController.h"
#import "ReverseVC.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.translucent = YES;
    // 3.加载3个Nav
    //代码动态创建
    ReverseVC *reverse = [[ReverseVC alloc] init];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:reverse];
    //storyBoard创建
    UIStoryboard *chatSB = [UIStoryboard storyboardWithName:@"Conversation" bundle:nil];
    UIStoryboard *settingsSB = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UIStoryboard *contactsSB = [UIStoryboard storyboardWithName:@"Contacts" bundle:nil];
    // 4.创建并将3个Storyboard添加到TabBarCongtroller中
    self.viewControllers = @[nav1,
                           chatSB.instantiateInitialViewController,
                        contactsSB.instantiateInitialViewController,
                           settingsSB.instantiateInitialViewController
                           ];
    
    [self initWithNum:0 title:@"预定" imageName:@"预定.png" highName:@"预定高亮.png"];
    [self initWithNum:1 title:@"会话" imageName:@"聊天.png" highName:@"聊天高亮.png"];
    [self initWithNum:2 title:@"联系人" imageName:@"联系人.png" highName:@"联系人高亮.png"];
    [self initWithNum:3 title:@"设置" imageName:@"设置.png" highName:@"设置高亮.png"];
    
}

//设置tabBar文字和图片方法
- (void)initWithNum:(int)num title:(NSString *)title imageName:(NSString *)imageName highName:(NSString *)highName {
    UITabBarItem *thirdItem = self.tabBar.items[num];
    thirdItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    thirdItem.selectedImage = [[UIImage imageNamed:highName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    thirdItem.title = title;
    
}


@end
