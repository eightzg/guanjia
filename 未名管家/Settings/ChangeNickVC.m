//
//  ChangeNickVC.m
//  未名管家
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 eight. All rights reserved.
//

#import "ChangeNickVC.h"

#import <BmobObject.h>
#import <BmobUser.h>

@interface ChangeNickVC ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
/**
 *  用户的昵称
 */
@property (nonatomic, copy) NSString *nickName;
@end

@implementation ChangeNickVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置textField的值为上一个控制器传过来的值
    self.textField.text = self.nick;
    
}

//点击修改按钮
- (IBAction)changeBtnClicked:(id)sender {
    //1，block逆向传值
    if (self.block) {
        self.block(self.textField.text);
    }
    //2，保存到服务器
    [self saveNickName];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)saveNickName {
    BmobUser *bUser = [BmobUser getCurrentUser];
    BmobObject *nickObj = [[BmobObject alloc] initWithClassName:@"Nick"];
    [nickObj setObject:bUser.username forKey:@"userName"];
    [nickObj setObject:self.textField.text forKey:@"nickName"];
    [nickObj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //打印objectId
            NSLog(@"objectid :%@",nickObj);
        } else if (error){
            NSLog(@"%@",error);
        } else {
            NSLog(@"Unknow error");
        }
    }];
}



@end
