//
//  ReverseVC.m
//  未名管家
//
//  Created by apple on 15/11/18.
//  Copyright (c) 2015年 eight. All rights reserved.
//
#define HKWidth [UIScreen mainScreen].bounds.size.width

#import "ReverseVC.h"
#import "LoginVC.h"
#import "NSString+anyDay.h"
#import "MBProgressHUD+MJ.h"
#import "HistoryVC.h"
#import "ComObj.h"
#import "UIColor+Random.h"
#import "MyCollectionViewCell.h"

#import <BmobUser.h>
#import <BmobObject.h>
#import <BmobEvent.h>
#import <BmobQuery.h>

#import <EaseMobSDKFull/EaseMob.h>

@interface ReverseVC () <UIAlertViewDelegate, UIActionSheetDelegate, BmobEventDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, EMChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
//时间段数组
@property (nonatomic, strong) NSArray *timeArray;
//当前页码
@property (nonatomic, assign) int weekNum;
//当前用户名
@property (nonatomic, copy) NSString *user;
//时间段
@property (nonatomic, copy) NSString *peroidStr;
//日期
@property (nonatomic, copy) NSString *dateStr;
//记录当前点击按钮的tag值
@property (nonatomic, assign) long tag;
//BmobEvent对象全局变量
@property (nonatomic, strong) BmobEvent *bmobEvent;
//数组用来存储数据库中所有查询的数据
@property (nonatomic, strong) NSMutableArray *userArray;
//用来存放当前一周的日期和星期
@property (nonatomic, strong) NSMutableArray *dateArray;
/** 预定界面的collectionView */
@property (nonatomic, strong) UICollectionView *mainCollectionView;
/** 当前颜色 */
@property (nonatomic, strong) UIColor *currentColor;
/** 历史会话记录,用来在第二个tab显示badge */
@property (nonatomic, strong) NSArray *conversations;

@end

@implementation ReverseVC
static NSString * const ID = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化当前页码
    self.weekNum = 0;
    //查询数据库
    [self getDataFromBmob];
    //监听数据改变
    [self listen];
    //设置会话监听的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    //显示第二个tab和application的badge
    [self showBadgeValue];
    self.title = @"预定";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(logoutClicked)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"预定历史" style:UIBarButtonItemStylePlain target:self action:@selector(historyClicked)];
    //初始化时间段数组
    self.timeArray = @[@"08-10",
                       @"10-12",
                       @"12-14",
                       @"14-16",
                       @"16-18",
                       @"18-20",
                       @"20-22"];
    //1,初始化布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    long width = (HKWidth - 7)/8;
    layout.itemSize = CGSizeMake(width, width);
    
    //2.初始化collectionView
    self.mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, HKWidth, HKWidth) collectionViewLayout:layout];
    self.mainCollectionView.backgroundColor = [UIColor whiteColor];
    //3.注册collectionViewCell
    [self.mainCollectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:ID];
    
    //4.设置代理,数据源
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
    
    [self.view addSubview:self.mainCollectionView];
}

- (void)showBadgeValue{
    //1.从内存获取历史会话记录
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    //2.如果内存里没有会话记录，从数据库Conversation表
    if (conversations.count == 0) {
        conversations =  [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    }
    self.conversations = conversations;
    //显示总的未读数
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in self.conversations) {
        totalUnreadCount += [conversation unreadMessagesCount];
    }
    //显示第二个tab和application的badge
    self.tabBarController.tabBar.items[1].badgeValue = [NSString stringWithFormat:@"%zd",totalUnreadCount];
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = totalUnreadCount;
    if (totalUnreadCount == 0) {
        self.tabBarController.tabBar.items[1].badgeValue = nil;
    }
}

//初始化视图
- (void)loadViews{
    //初始化日期数组
    self.dateArray = [NSMutableArray array];
    self.userArray = [NSMutableArray array];
    for (NSMutableDictionary *dict in g().userArray) {
        [self.userArray addObject:dict];
    }
    [self.mainCollectionView reloadData];
    
}

#pragma mark - actions
//左侧按钮点击
- (IBAction)leftBtnClicked:(id)sender {
    self.weekNum -= 7;
    [self loadViews];
}

//右侧按钮点击
- (IBAction)rightBtnClicked:(id)sender {
    self.weekNum += 7;
    [self loadViews];
}
- (IBAction)backToNowClicked:(id)sender {
    self.weekNum = 0;
    [self loadViews];
}

//注销按钮点击
- (void)logoutClicked {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确定要注销吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
    
}

//预定按钮点击
- (void)historyClicked {
    HistoryVC *his = [[HistoryVC alloc] init];
    [self.navigationController  pushViewController:his animated:YES];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //退出登录Ease,YES代表主动退出登录
        [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
            if (!error) {
                NSLog(@"退出成功");
            }
        } onQueue:nil];
        //退出登录Bmob
        [BmobUser logout];
        //回到登录界面
        LoginVC *login = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
        self.view.window.rootViewController = nav;

    }
}

#pragma mark - Bmob request
/**
 *  保存到数据
 *
 *  @param user      用户名
 *  @param periodStr 时间段
 *  @param dateStr   日期
 *  @param reason    原因
 *  @param tag       按钮的tag值
 */
- (void)saveToBmobWithName:(NSString *)user period:(NSString *)periodStr date:(NSString *)dateStr reason:(NSString *)reason andTag:(long)tag{
    BmobObject *timeObj = [[BmobObject alloc] initWithClassName:@"Time"];
    [timeObj setObject:[NSNumber numberWithLong:tag] forKey:@"tag"];
    [timeObj setObject:user forKey:@"userName"];
    [timeObj setObject:periodStr forKey:@"timePeriod"];
    [timeObj setObject:dateStr forKey:@"date"];
    [timeObj setObject:reason forKey:@"reason"];
    
    //保存预定那天的日期和时间段到数据库，便于预订历史的排序
    NSString *month = [dateStr substringWithRange:NSMakeRange(0, 2)];
    NSString *day = [dateStr substringWithRange:NSMakeRange(3, 2)];
    NSString *hour = [periodStr substringWithRange:NSMakeRange(0, 2)];
    NSString *time = [NSString stringWithFormat:@"%@%@%@",month,day,hour];
    [timeObj setObject:time forKey:@"time"];
    
    [timeObj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //打印objectId
            NSLog(@"objectid :%@",timeObj);
        } else if (error){
            NSLog(@"%@",error);
        } else {
            NSLog(@"Unknow error");
        }
    }];
}

//从数据库查询
- (void)getDataFromBmob {
    
    self.currentColor = [UIColor randomColor];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Time"];
    //查找GameScore表的数据
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"error is:%@",error);
        } else{
            g().userArray = array;
            [self loadViews];
        }
    }];
}

#pragma mark - BmobEvent Delegate

//连接到服务器进行监听
- (void)listen{
    self.bmobEvent = [BmobEvent defaultBmobEvent];
    self.bmobEvent.delegate = self;
    //启动连接
    [self.bmobEvent start];
}

//可以进行监听或者取消监听事件
-(void)bmobEventCanStartListen:(BmobEvent *)event{
    //监听Post表更新
    [self.bmobEvent listenTableChange:BmobActionTypeUpdateTable tableName:@"Time"];
}

//接收到得数据
-(void)bmobEvent:(BmobEvent *)event didReceiveMessage:(NSString *)message{
    //更新数据
    [self getDataFromBmob];
}

#pragma mark - tag转row&col row&col转tag
- (long)tagFromRow:(long)row andCol:(long)col {
    long tag = 8 * row + col;
    return tag;
}

- (long)rowFormTag:(long)tag {
    long row = tag / 8;
    return row;
}

#pragma mark - collectionView代理方法

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 64;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];

    
    if (indexPath.item == 0) {
        cell.commonLabel.text = [NSString stringOfYearWithDaysInterval:self.weekNum];
    }else if (indexPath.item > 0 && indexPath.item < 8) {
        //第一行除了第0个位置，都填充时间信息
        NSString *theDayStr = [NSString stringWithDaysInterval:(int)(indexPath.item-1+self.weekNum)];
        //把当前一周的时间字符串保存到数组
        [self.dateArray addObject:theDayStr];
        cell.commonLabel.text = theDayStr;
        
        
    }else if (indexPath.item % 8 == 0 && indexPath.item != 0) {
        cell.commonLabel.text = self.timeArray[indexPath.item / 8 - 1];
    }else {
        cell.commonLabel.text = @"";
        
        //禁用已经预定的日期和时间段对应的按钮,并且设置标题内容
        for (int j = 0; j < self.userArray.count; j ++) {
            NSDictionary *dict = self.userArray[j];
            long tag = [[dict objectForKey:@"tag"] longValue];
            long row = [self rowFormTag:tag];
            
            NSString *dateStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]];
            long currentTag = 0;
            //获取数据库查询的日期，如果和当前的一周时间匹配，设置按钮状态
            if ([dateStr isEqualToString:self.dateArray[0]]) {
                currentTag = [self tagFromRow:row andCol:1];
            }else if ([dateStr isEqualToString:self.dateArray[1]]) {
                currentTag = [self tagFromRow:row andCol:2];
            }else if ([dateStr isEqualToString:self.dateArray[2]]) {
                currentTag = [self tagFromRow:row andCol:3];
            }else if ([dateStr isEqualToString:self.dateArray[3]]) {
                currentTag = [self tagFromRow:row andCol:4];
            }else if ([dateStr isEqualToString:self.dateArray[4]]) {
                currentTag = [self tagFromRow:row andCol:5];
            }else if ([dateStr isEqualToString:self.dateArray[5]]) {
                currentTag = [self tagFromRow:row andCol:6];
            }else if ([dateStr isEqualToString:self.dateArray[6]]) {
                currentTag = [self tagFromRow:row andCol:7];
            }
            
            //用户名和原因
            NSString *content = [NSString stringWithFormat:@"%@\n%@",[dict objectForKey:@"userName"],[dict objectForKey:@"reason"]];
            if (indexPath.item == currentTag) {
                cell.commonLabel.text = content;
            }
        }

    }
    
    cell.backgroundColor = self.currentColor;
    return cell;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionViewCell *cell = (MyCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //如果不是点击区域，让item没有响应
    
    if (cell.commonLabel.text.length > 1) {
        [MBProgressHUD showError:@"哎呀,已经被预定啦！" toView:self.view];
        return;
    }
    
    if (indexPath.item % 8 == 0 || (indexPath.item>0 && indexPath.item<8)) return;
    cell.backgroundColor = [UIColor grayColor];
    
    self.user = [BmobUser getCurrentUser].username;
    //计算的是第几行第几列
    long row = indexPath.item / 8;
    long col = indexPath.item % 8;
    
    //保存当前点击的cell的位置
    self.tag = indexPath.item;
    self.peroidStr = self.timeArray[row - 1];
    self.dateStr = self.dateArray[col-1];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入要占用实验室的理由" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //点击确定获取文本框的内容
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text isEqualToString:@""]) {
            [MBProgressHUD showError:@"原因不得为空" toView:self.view];
            [self.mainCollectionView reloadData];
            return;
        }else if (textField.text.length > 6) {
            [MBProgressHUD showError:@"原因过长" toView:self.view];
            [self.mainCollectionView reloadData];
            return;
        }
        //保存到数据库
        [self saveToBmobWithName:self.user period:self.peroidStr date:self.dateStr reason:textField.text andTag:self.tag];
        [MBProgressHUD showSuccess:@"预订成功" toView:self.view];
    }else {
        [self.mainCollectionView reloadData];
    }
}

#pragma mark - 监听会话监听回调
#pragma mark 历史会话列表更新
-(void)didUpdateConversationList:(NSArray *)conversationList{
    
    //给数据源重新赋值
    self.conversations = conversationList;
    //显示总的未读数
    [self showBadgeValue];
    
}

#pragma mark 未读消息数改变
- (void)didUnreadMessagesCountChanged{
    //显示总的未读数
    [self showBadgeValue];
    
}



@end
