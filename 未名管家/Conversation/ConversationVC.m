//
//  ChatVC.m
//  未名管家
//
//  Created by apple on 16/2/29.
//  Copyright © 2016年 eight. All rights reserved.
//

#import "ConversationVC.h"
#import "ChatVC.h"
#import <EaseMobSDKFull/EaseMob.h>

@interface ConversationVC ()<EMChatManagerDelegate,UIAlertViewDelegate>
/** 好友的名称 */
@property (nonatomic, copy) NSString *buddyUsername;
/** 历史会话记录 */
@property (nonatomic, strong) NSArray *conversations;
@end

@implementation ConversationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会话";
    //设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    //获取历史会话记录
    [self loadConversations];
    
}

- (void)loadConversations{
    //获取历史会话记录
    //1.从内存获取历史会话记录
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    
    //2.如果内存里没有会话记录，从数据库Conversation表
    if (conversations.count == 0) {
        conversations =  [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    }
    
    NSLog(@"zzzzzzz %@",conversations);
    self.conversations = conversations;
    
    //显示总的未读数
    [self showTabBarBadge];
}

#pragma mark - chatManager代理方法
//1.监听网络状态
- (void)didConnectionStateChanged:(EMConnectionState)connectionState{
    //    eEMConnectionConnected,   //连接成功
    //    eEMConnectionDisconnected,//未连接
    if (connectionState == eEMConnectionDisconnected) {
        NSLog(@"网络断开，未连接...");
        self.title = @"未连接.";
    }else{
        NSLog(@"网络通了...");
    }
    
}


-(void)willAutoReconnect{
    NSLog(@"将自动重连接...");
    self.title = @"连接中....";
}

-(void)didAutoReconnectFinishedWithError:(NSError *)error{
    if (!error) {
        NSLog(@"自动重连接成功...");
        self.title = @"会话";
    }else{
        NSLog(@"自动重连接失败... %@",error);
    }
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID =  @"ConversationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //获取会话模型
    EMConversation *conversaion = self.conversations[indexPath.row];
    
    // 显示数据
    // 1.显示用户名
    cell.textLabel.text = [NSString stringWithFormat:@"%@ ==== 未读消息数:%zd",conversaion.chatter,[conversaion unreadMessagesCount]];
    
    // 2.显示最新的一条记录
    // 获取消息体
    id body = conversaion.latestMessage.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody = body;
        cell.detailTextLabel.text = textBody.text;
    }else if ([body isKindOfClass:[EMVoiceMessageBody class]]){
        EMVoiceMessageBody *voiceBody = body;
        cell.detailTextLabel.text = [voiceBody displayName];
    }else if([body isKindOfClass:[EMImageMessageBody class]]){
        EMImageMessageBody *imgBody = body;
        cell.detailTextLabel.text = imgBody.displayName;
    }else{
        cell.detailTextLabel.text = @"未知消息类型";
    }
    
    return cell;
    
}


#pragma mark 自动登录的回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (!error) {
        NSLog(@"%s 自动登录成功 %@",__FUNCTION__, loginInfo);
    }else{
        NSLog(@"自动登录失败 %@",error);
    }
    
}

#pragma mark 监听被好友删除
-(void)didRemovedByBuddy:(NSString *)username{
    
    NSString *message = [username stringByAppendingString:@" 把你删除"];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"xxxx" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)dealloc
{
    //移除聊天管理器的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

#pragma mark 历史会话列表更新
-(void)didUpdateConversationList:(NSArray *)conversationList{
    
    //给数据源重新赋值
    self.conversations = conversationList;
    
    //刷新表格
    [self.tableView reloadData];
    
    //显示总的未读数
    [self showTabBarBadge];
    
}

#pragma mark 未读消息数改变
- (void)didUnreadMessagesCountChanged{
    //更新表格
    [self.tableView reloadData];
    //显示总的未读数
    [self showTabBarBadge];
    
}

-(void)showTabBarBadge{
    //遍历所有的会话记录，将未读取的消息数进行累
    
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in self.conversations) {
        totalUnreadCount += [conversation unreadMessagesCount];
    }
    
    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",totalUnreadCount];
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = totalUnreadCount;
    if (totalUnreadCount == 0) {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进入到聊天控制器
    //1.从storybaord加载聊天控制器
    ChatVC *chatVc = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"Chat"];
    //会话
    EMConversation *conversation = self.conversations[indexPath.row];
    EMBuddy *buddy = [EMBuddy buddyWithUsername:conversation.chatter];
    //2.设置好友属性
    chatVc.buddy = buddy;
    
    //3.展现聊天界面
    [self.navigationController pushViewController:chatVc animated:YES];
    
    
}



@end
