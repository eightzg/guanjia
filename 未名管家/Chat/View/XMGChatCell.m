//
//  XMGChatCell.m
//  xmg1chat
//
//  Created by xiaomage on 15/9/25.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "XMGChatCell.h"
#import "EMCDDeviceManager.h"
#import "XMGAudioPlayTool.h"
#import "UIImageView+WebCache.h"

@interface XMGChatCell()
/** 聊天图片控件 */
@property (nonatomic, strong) UIImageView *chatImgView;

@end



@implementation XMGChatCell


-(UIImageView *)chatImgView{
    if (!_chatImgView) {
        _chatImgView = [[UIImageView alloc] init];
    }
    
    return _chatImgView;
}

-(void)awakeFromNib{
    // 在此方法做一些初始化操作
    // 1.给label添加敲击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageLabelTap:)];
    [self.messageLabel addGestureRecognizer:tap];
    
}

#pragma mark messagelabel 点击的触发方法
-(void)messageLabelTap:(UITapGestureRecognizer *)recognizer{
    NSLog(@"%s",__func__);
    //播放语音
    //只有当前的类型是为语音的时候才播放
    //1.获取消息体
    id body = self.message.messageBodies[0];
    if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        NSLog(@"播放语音");
        BOOL receiver = [self.reuseIdentifier isEqualToString:ReceiverCell];
        [XMGAudioPlayTool playWithMessage:self.message msgLabel:self.messageLabel receiver:receiver];
        
    }
//    EMTextMessageBody
//    EMVoiceMessageBody
//    EMImageMessageBody
    

}

-(void)setMessage:(EMMessage *)message{

    //重用时，把聊天图片控件移除
    [self.chatImgView removeFromSuperview];
    
    _message = message;
    
    // 1.获取消息体
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {//文本消息
        EMTextMessageBody *textBody = body;
        self.messageLabel.text = textBody.text;
    }else if([body isKindOfClass:[EMVoiceMessageBody class]]){//语音消息
//        self.messageLabel.text = @"【语音】";
        self.messageLabel.attributedText = [self voiceAtt];
    }else if([body isKindOfClass:[EMImageMessageBody class]]){//图片消息
        [self showImage];
    }
    else{
        self.messageLabel.text = @"未知类型";
    }
    

}


-(void)showImage{
    
    // 获取图片消息体
    EMImageMessageBody *imgBody = self.message.messageBodies[0];
    CGRect thumbnailFrm = (CGRect){0,0,imgBody.thumbnailSize};
    
    // 设置Label的尺寸足够显示UIImageView
    NSTextAttachment *imgAttach = [[NSTextAttachment alloc] init];
    imgAttach.bounds = thumbnailFrm;
    NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttach];
    self.messageLabel.attributedText = imgAtt;
    
    //1.cell里添加一个UIImageView
    [self.messageLabel addSubview:self.chatImgView];
    
    //2.设置图片控件为缩略图的尺寸
    self.chatImgView.frame = thumbnailFrm;
    
    //3.下载图片
//    NSLog(@"thumbnailLocalPath %@",imgBody.thumbnailLocalPath);
//    NSLog(@"thumbnailRemotePath %@",imgBody.thumbnailRemotePath);
    NSFileManager *manager = [NSFileManager defaultManager];
    // 如果本地图片存在，直接从本地显示图片
    UIImage *palceImg = [UIImage imageNamed:@"downloading"];
    if ([manager fileExistsAtPath:imgBody.thumbnailLocalPath]) {
#warning 本地路径使用fileURLWithPath方法
        [self.chatImgView sd_setImageWithURL:[NSURL fileURLWithPath:imgBody.thumbnailLocalPath] placeholderImage:palceImg];
    }else{
        // 如果本地图片不存，从网络加载图片
        [self.chatImgView sd_setImageWithURL:[NSURL URLWithString:imgBody.thumbnailRemotePath] placeholderImage:palceImg];
    }
    
    
}

#pragma mark 返回语音富文本
-(NSAttributedString *)voiceAtt{
    // 创建一个可变的富文本
    NSMutableAttributedString *voiceAttM = [[NSMutableAttributedString alloc] init];
    
    // 1.接收方： 富文本 ＝ 图片 + 时间
    if ([self.reuseIdentifier isEqualToString:ReceiverCell]) {
        // 1.1接收方的语音图片
        UIImage *receiverImg = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
        
        // 1.2创建图片附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = receiverImg;
        imgAttachment.bounds = CGRectMake(0, -7, 30, 30);
        // 1.3图片富文本
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        [voiceAttM appendAttributedString:imgAtt];
        
        // 1.4.创建时间富文本
        // 获取时间
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%ld'",duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
    }else{
    // 2.发送方：富文本 ＝ 时间 + 图片
        // 2.1 拼接时间
        // 获取时间
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%ld'",duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
        
        // 2.1拼接图片
        UIImage *receiverImg = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
        
        // 创建图片附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = receiverImg;
        imgAttachment.bounds = CGRectMake(0, -7, 30, 30);
        // 图片富文本
        NSAttributedString *imgAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        [voiceAttM appendAttributedString:imgAtt];
        
    }
    
    return [voiceAttM copy];

}


/** 返回cell的高度*/
-(CGFloat)cellHeghit{
    //1.重新布局子控件
    [self layoutIfNeeded];
    
    return 5 + 10 + self.messageLabel.bounds.size.height + 10 + 5;

}


@end
