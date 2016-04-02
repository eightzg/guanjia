//
//  ReverseVC.m
//  未名管家
//
//  Created by apple on 15/11/18.
//  Copyright (c) 2015年 eight. All rights reserved.
//

#import "ReverseVC.h"
#import "LoginVC.h"
#import "NSString+anyDay.h"
#import "MBProgressHUD+MJ.h"
#import "HistoryVC.h"
#import "ComObj.h"
#import "UIColor+Random.h"

#import <BmobUser.h>
#import <BmobObject.h>
#import <BmobEvent.h>
#import <BmobQuery.h>

#import <EaseMobSDKFull/EaseMob.h>

@interface ReverseVC () <UIAlertViewDelegate, UIActionSheetDelegate, BmobEventDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
//时间段数组
@property (nonatomic, strong) NSArray *timeArray;
//当前页码
@property (nonatomic, assign) int weekNum;
@property (nonatomic, assign) long col;
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

@end

@implementation ReverseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化当前页码
    self.weekNum = 0;
    self.col = 0;
    //查询数据库
    [self getDataFromBmob];
    //监听数据改变
    [self listen];
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
}
//初始化视图
- (void)loadViewsWithWeekChanged:(int)week {
    UIColor *randomColor = [UIColor randomColor];
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //初始化数组
    self.userArray = [NSMutableArray array];
    self.dateArray = [NSMutableArray array];
    
    for (NSMutableDictionary *dict in g().userArray) {
        [self.userArray addObject:dict];
    }
    
    //创建九宫格视图
    CGFloat padding = 0.5;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - padding * 7) / 8;
    CGFloat height = width;
    
    for (int i = 0; i < 64; i++) {
        // 计算位置
        int row = i/8;
        int column = i%8;
        CGFloat x = padding + column * (width + padding);
        CGFloat y = padding + row * (height + padding);
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectMake(x, y, width, height);
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        //设置按钮文字换行
        button.titleLabel.lineBreakMode = UIBaselineAdjustmentAlignBaselines;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundColor:randomColor];
        button.tag = i;
        
        if (i == 0) {
            button.enabled = NO;
            NSString *year = [NSString stringOfYearWithDaysInterval:week];
            [button setTitle:year forState:UIControlStateNormal];
        }
        else if (i > 0 && i < 8) {
            //第一行除了第0个位置，都填充时间信息
            NSString *theDayStr = [NSString stringWithDaysInterval:i-1+week];
            //把当前一周的时间字符串保存到数组
            [self.dateArray addObject:theDayStr];
            [button setTitle:theDayStr forState:UIControlStateNormal];
            button.enabled = NO;
        }else if (i % 8 == 0 && i != 0) {
            //第一列除了第0个位置，都填充时间段信息
            [button setTitle:[NSString stringWithFormat:@"%@",self.timeArray[i / 8 - 1]] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.enabled = NO;
        }
        else {
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
                }else {
                    currentTag = 70;
                }   
                
                UIButton *btn = (UIButton *)[self.contentView viewWithTag:currentTag];
                //用户名和原因
                NSString *content = [NSString stringWithFormat:@"%@\n%@",[dict objectForKey:@"userName"],[dict objectForKey:@"reason"]];
                [btn setTitle:content forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:13];
                //文字换行
                button.titleLabel.lineBreakMode = UIBaselineAdjustmentAlignBaselines;
                btn.enabled = NO;
            }
        }
        
        [self.contentView addSubview:button];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //点击确定获取文本框的内容
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text isEqualToString:@""]) {
            [MBProgressHUD showError:@"原因不得为空" toView:self.view];
            return;
        }else if (textField.text.length > 4) {
            [MBProgressHUD showError:@"原因过长" toView:self.view];
            return;
        }
        //保存到数据库
        [self saveToBmobWithName:self.user period:self.peroidStr date:self.dateStr reason:textField.text andTag:self.tag];
        [MBProgressHUD showSuccess:@"预订成功" toView:self.view];
    }
}

#pragma mark - actions
//列表按钮点击
- (void)buttonClicked:(UIButton *)button{
    UIButton *btn = (UIButton *)[self.contentView viewWithTag:button.tag];
    self.user = [BmobUser getCurrentUser].username;
    //计算的是第几行第几列
    long row = btn.tag / 8;
    long col = btn.tag % 8;
    self.peroidStr = self.timeArray[row - 1];
    //获取顶部的日期按钮
    UIButton *startBtn = (UIButton *)[self.contentView viewWithTag:col];
    //获取顶部的日期按钮的文字
    self.dateStr = startBtn.titleLabel.text;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入要占用实验室的理由" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //保存button的tag到全局属性
    self.tag = button.tag;
    [alert show];
}

//左侧按钮点击
- (IBAction)leftBtnClicked:(id)sender {
    //把所有的子视图从父视图中移除
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.weekNum -= 7;
    [self loadViewsWithWeekChanged:self.weekNum];
}

//右侧按钮点击
- (IBAction)rightBtnClicked:(id)sender {
    //把所有的子视图从父视图中移除
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.weekNum += 7;
    [self loadViewsWithWeekChanged:self.weekNum];
}
- (IBAction)backToNowClicked:(id)sender {
    //把所有的子视图从父视图中移除
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.weekNum = 0;
    [self loadViewsWithWeekChanged:self.weekNum];
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
            //发生错误后的动作
            NSLog(@"%@",error);
        } else {
            NSLog(@"Unknow error");
        }
    }];
}

//从数据库查询
- (void)getDataFromBmob {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Time"];
    //查找GameScore表的数据
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"error is:%@",error);
        } else{
            g().userArray = array;
            [self loadViewsWithWeekChanged:self.weekNum];
        }
    }];
}

//连接到服务器进行监听
- (void)listen{
    self.bmobEvent = [BmobEvent defaultBmobEvent];
    self.bmobEvent.delegate = self;
    //启动连接
    [self.bmobEvent start];
}

#pragma mark - BmobEvent Delegate
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

- (long)colFromTag:(long)tag {
    long col = tag % 8;
    return col;
}



@end
