//
//  XMGChatCell.h
//  xmg1chat
//
//  Created by xiaomage on 15/9/25.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseMobSDKFull/EaseMob.h>
static NSString *ReceiverCell = @"ReceiverCell";
static NSString *SenderCell = @"SenderCell";
@interface XMGChatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

/** 消息模型，内部set方法 显示文字 */
@property (nonatomic, strong) EMMessage *message;

-(CGFloat)cellHeghit;

@end
