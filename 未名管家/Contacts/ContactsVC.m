//
//  ContactsVC.m
//  未名管家
//
//  Created by apple on 16/3/4.
//  Copyright © 2016年 eight. All rights reserved.
//

#import "ContactsVC.h"
#import "ChatVC.h"
#import <EaseMobSDKFull/EaseMob.h>

@interface ContactsVC () <EMChatManagerDelegate>

/** 好友列表数据源 */
@property (nonatomic, strong) NSArray *buddyList;

@end

@implementation ContactsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    //获取好友列表
    self.buddyList =  [[EaseMob sharedInstance].chatManager buddyList];
    NSLog(@"=== %@",self.buddyList);
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buddyList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    // 1。获取“好友”模型
    EMBuddy *buddy = self.buddyList[indexPath.row];
    
    // 2.显示头像
    cell.imageView.image = [UIImage imageNamed:@"联系人"];
    
    // 3.显示名称
    cell.textLabel.text = buddy.username;

    
    return cell;
}

#pragma mark - chatmanger的代理
#pragma mark - 监听自动登录成功
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (!error) {//自动登录成功，此时buddyList就有值
        self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
        NSLog(@"=== %@",self.buddyList);
        [self.tableView reloadData];
    }
}


#pragma mark 好友添加请求同意
-(void)didAcceptedByBuddy:(NSString *)username{
    // 把新的好友显示到表格
    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    NSLog(@"好友添加请求同意 %@",buddyList);
#warning buddyList的个数，仍然是没有添加好友之前的个数，从新服务器获取
    [self loadBuddyListFromServer];
    
    
}

#pragma mark 从新服务器获取好友列表
-(void)loadBuddyListFromServer{
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        NSLog(@"从服务器获取的好友列表 %@",buddyList);
        
        // 赋值数据源
        self.buddyList = buddyList;
        
        // 刷新
        [self.tableView reloadData];
        
    } onQueue:nil];
}

#pragma mark 好友列表数据被更新
-(void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd{
    
    NSLog(@"好友列表数据被更新 %@",buddyList);
    // 重新赋值数据源
    self.buddyList = buddyList;
    // 刷新
    [self.tableView reloadData];
}

#pragma mark 被好友删除
-(void)didRemovedByBuddy:(NSString *)username{
    
    // 刷新表格
    [self loadBuddyListFromServer];
    
}

#pragma mark  实现下面的方法就会出现表格的Delete按钮
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // 获取移除好友的名字
        EMBuddy *buddy = self.buddyList[indexPath.row];
        NSString *deleteUsername = buddy.username;
        
        // 删除好友
        [[EaseMob sharedInstance].chatManager removeBuddy:deleteUsername removeFromRemote:YES error:nil];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进入到聊天控制器
    //1.从storybaord加载聊天控制器
    ChatVC *chatVc = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"Chat"];
    //2,获取点击的行,传递好友的值
    NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
    chatVc.buddy = self.buddyList[selectedRow];
    //3.展现聊天界面
    [self.navigationController pushViewController:chatVc animated:YES];
    
    
}




@end
