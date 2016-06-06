//
//  XMGChatViewController.m
//  xmg1chat
//
//  Created by xiaomage on 15/9/25.
//  Copyright © 2015年 小码哥. All rights reserved.
//
#define HKWidth [UIScreen mainScreen].bounds.size.width
#define HKHeight [UIScreen mainScreen].bounds.size.height

#import "ChatVC.h"
#import "XMGChatCell.h"
#import "EMCDDeviceManager.h"
#import "XMGAudioPlayTool.h"
#import "XMGTimeCell.h"
#import "XMGTimeTool.h"
#import "GifView.h"
#import "EmotionKeyboard.h"



@interface ChatVC ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,EMChatManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

/**输入工具条底部的约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolBarBottomConstraint;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSources;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** 计算高度的cell工具对象 */
@property (nonatomic, strong) XMGChatCell *chatCellTool;

/** InputToolBar 高度的约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolBarHegihtConstraint;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;


/** 当前添加的时间 */
@property (nonatomic, copy) NSString *currentTimeStr;
/** 当前会话对象 */
@property (nonatomic, strong) EMConversation *conversation;

//定时器对象
@property (nonatomic, strong) NSTimer *timer;
//和文字对应的数字
@property (nonatomic, assign) int number;
@property (nonatomic, strong) GifView *gifView;

/** 表情键盘 */
@property (nonatomic, strong) EmotionKeyboard *emotionKeyboard;
/** 是否正在切换键盘 */
@property (nonatomic, assign) BOOL switchingKeybaord;
/**
 *  表情按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *faceBtn;


@end



@implementation ChatVC

#pragma mark - 懒加载方法
- (NSMutableArray *)dataSources
{
    if (!_dataSources) {
        _dataSources = [NSMutableArray array];
    }
    
    return _dataSources;
}

- (EmotionKeyboard *)emotionKeyboard
{
    if (!_emotionKeyboard) {
        self.emotionKeyboard = [[EmotionKeyboard alloc] init];
        self.emotionKeyboard.width = self.view.width;
        self.emotionKeyboard.height = 216;
    }
    return _emotionKeyboard;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置背景颜色
    self.tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    // 给计算高度的cell工具对象 赋值
    self.chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:ReceiverCell];
    // 显示好友的名字
    self.title = self.buddy.username;
    // 加载本地数据库聊天记录（MessageV1）
    [self loadLocalChatRecords];
    // 设置聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    // 监听键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

// 加载本地数据库聊天记录（MessageV1）
-(void)loadLocalChatRecords{
    //假设在数组的第一位置添加时间
    //    [self.dataSources addObject:@"16:06"];
    
    // 要获取本地聊天记录使用 会话对象
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    self.conversation = conversation;
    
    // 加载与当前聊天用户所有聊天记录
    NSArray *messages = [conversation loadAllMessages];
    
    // 添加到数据源
    for (EMMessage *msgObj in messages) {
        [self addDataSourcesWithMessage:msgObj];
    }
    [self scrollToBottom];
}

- (void)keyboardWillChangeFrame:(NSNotification *)note {
    // 取出键盘最终的frame
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 取出键盘弹出需要花费的时间
    double duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 修改约束
    CGFloat Y = [UIScreen mainScreen].bounds.size.height - rect.origin.y;
    self.view.transform = CGAffineTransformMakeTranslation(0, -Y);
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark 表格数据源
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSources.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //时间cell的高度是固定
    if ([self.dataSources[indexPath.row] isKindOfClass:[NSString class]]) {
        return 18;
    }
    
    // 设置label的数据
    // 1.获取消息模型
    EMMessage *msg = self.dataSources[indexPath.row];
    
    self.chatCellTool.message = msg;
    //    self.chatCellTool.messageLabel.text = self.dataSources[indexPath.row];
    return [self.chatCellTool cellHeghit];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //判断数据源类型
    if ([self.dataSources[indexPath.row] isKindOfClass:[NSString class]]) {//显示时间cell
        XMGTimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"TimeCell"];
        timeCell.timeLabel.text = self.dataSources[indexPath.row];
        return timeCell;
        
    }
    
    
    //1.先获取消息模型
    EMMessage *message = self.dataSources[indexPath.row];
    //    EMMessage
    /* from:xmgtest1 to:xmgtest7 发送方（自己）
     * from:xmgtest7 to:xmgtest1 接收方 （好友）
     */
    
    XMGChatCell *cell = nil;
    if ([message.from isEqualToString:self.buddy.username]) {//接收方
        cell = [tableView dequeueReusableCellWithIdentifier:ReceiverCell];
    }else{//发送方
        cell = [tableView dequeueReusableCellWithIdentifier:SenderCell];
    }
    //显示内容
    cell.message = message;
    
    return cell;
    
    
}


#pragma mark - UITextView代理
-(void)textViewDidChange:(UITextView *)textView{
    
    
    //    NSLog(@"contentOffset %@",NSStringFromCGPoint(textView.contentOffset));
    // 1.计算TextView的高度，
    CGFloat textViewH = 0;
    CGFloat minHeight = 33;//textView最小的高度
    CGFloat maxHeight = 68;//textView最大的高度
    
    // 获取contentSize的高度
    CGFloat contentHeight = textView.contentSize.height;
    if (contentHeight < minHeight) {
        textViewH = minHeight;
    }else if (contentHeight > maxHeight){
        textViewH = maxHeight;
    }else{
        textViewH = contentHeight;
    }
    
    
    
    // 2.监听Send事件--判断最后的一个字符是不是换行字符
    if ([textView.text hasSuffix:@"\n"]) {
        NSLog(@"发送操作");
        [self sendText:textView.text];
        
        // 清空textView的文字
        textView.text = nil;
        
        // 发送时，textViewH的高度为33
        textViewH = minHeight;
        
    }
    
    // 3.调整整个InputToolBar 高度
    if(self.switchingKeybaord) return;
    self.inputToolBarHegihtConstraint.constant = 6 + 7 + textViewH;
    // 加个动画
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
    // 4.记光标回到原位
#warning 技巧
    [textView setContentOffset:CGPointZero animated:YES];
    [textView scrollRangeToVisible:textView.selectedRange];
    //开始动画
    
}

#pragma mark 发送文本消息
-(void)sendText:(NSString *)text{
    
    // 把最后一个换行字符去除
    text = [text substringToIndex:text.length - 1];
    
    // 创建一个聊天文本对象
    EMChatText *chatText = [[EMChatText alloc] initWithText:text];
    
    //创建一个文本消息体
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    
    [self sendMessage:textBody];
    
    [self initAnmiate:self.textView.text];
    
}

#pragma mark 发送语音消息
-(void)sendVoice:(NSString *)recordPath duration:(NSInteger)duration{
    // 1.构造一个 语音消息体
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:recordPath displayName:@"[语音]"];
    //    chatVoice.duration = duration;
    
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];
    voiceBody.duration = duration;
    
    [self sendMessage:voiceBody];
}

#pragma mark 发送图片
-(void)sendImg:(UIImage *)selectedImg{
    
    //1.构造图片消息体
    /*
     * 第一个参数：原始大小的图片对象 1000 * 1000
     * 第二个参数: 缩略图的图片对象  120 * 120
     */
    EMChatImage *orginalChatImg = [[EMChatImage alloc] initWithUIImage:selectedImg displayName:@"【图片】"];
    
    EMImageMessageBody *imgBody = [[EMImageMessageBody alloc] initWithImage:orginalChatImg thumbnailImage:nil];
    
    [self sendMessage:imgBody];
    
}

-(void)sendMessage:(id<IEMMessageBody>)body{
    //1.构造消息对象
    EMMessage *msgObj = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[body]];
    msgObj.messageType = eMessageTypeChat;
    
    //2.发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送图片");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"图片发送成功 %@",error);
    } onQueue:nil];
    
    // 3.把消息添加到数据源，然后再刷新表格
    [self addDataSourcesWithMessage:msgObj];
    [self.tableView reloadData];
    // 4.把消息显示在顶部
    [self scrollToBottom];
    
}
-(void)scrollToBottom{
    //1.获取最后一行
    if (self.dataSources.count == 0) {
        return;
    }
    
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.dataSources.count - 1 inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark 接收好友回复消息
-(void)didReceiveMessage:(EMMessage *)message{
#warning from 一定等于当前聊天用户才可以刷新数据
    
    NSLog(@">>>>>>>>>%@",message);
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {//文本消息
        EMTextMessageBody *textBody = body;
        [self initAnmiate:textBody.text];
    }
    
    if ([message.from isEqualToString:self.buddy.username]) {
        //1.把接收的消息添加到数据源
        //        [self.dataSources addObject:message];
        [self addDataSourcesWithMessage:message];
        
        //2.刷新表格
        [self.tableView reloadData];
        
        //3.显示数据到底部
        [self scrollToBottom];
        
    }
}


#pragma mark - Action
- (IBAction)faceBtnClicked:(id)sender {
    HKLog(@"表情按钮点击");
    [self switchKeyboard];
}

/**
 *  切换键盘
 */
- (void)switchKeyboard {
    if (self.textView.inputView == nil) { // 切换为自定义的表情键盘
        self.textView.inputView = self.emotionKeyboard;
        //切换按钮为键盘
        [self.faceBtn setImage:[UIImage imageNamed:@"keyboard_normal"] forState:UIControlStateNormal];
        [self.faceBtn setImage:[UIImage imageNamed:@"keyboard_highlighted"] forState:UIControlStateHighlighted];
    } else { // 切换为系统自带的键盘
        self.textView.inputView = nil;
        
        //切换按钮为表情
        [self.faceBtn setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
        [self.faceBtn setImage:[UIImage imageNamed:@"chat_bottom_smile_press"] forState:UIControlStateHighlighted];
    }

    // 开始切换键盘
    self.switchingKeybaord = YES;
    
    // 退出键盘
    [self.textView endEditing:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 弹出键盘
        [self.textView becomeFirstResponder];
        
        // 结束切换键盘
        self.switchingKeybaord = NO;
    });
}

- (IBAction)voiceAction:(UIButton *)sender {
    
    // 1.显示录音按钮
    self.recordBtn.hidden = !self.recordBtn.hidden;
    self.textView.hidden = !self.textView.hidden;
    
    if (self.recordBtn.hidden == NO) {//录音按钮要显示
        //InputToolBar 的高度要回来默认(46);
        self.inputToolBarHegihtConstraint.constant = 46;
        // 隐藏键盘
        [self.view endEditing:YES];
    }else{
        //当不录音的时候，键盘显示
        [self.textView becomeFirstResponder];
        
        // 恢复InputToolBar高度
        [self textViewDidChange:self.textView];
    }
    
}
#pragma mark 按钮点下去开始录音
- (IBAction)beginRecordAction:(id)sender {
    // 文件名以时间命名
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    NSLog(@"按钮点下去开始录音");
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        if (!error) {
            NSLog(@"开始录音成功");
            
        }
    }];
}

#pragma mark 手指从按钮范围内松开结束录音
- (IBAction)endRecordAction:(id)sender {
    NSLog(@"手指从按钮松开结束录音");
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            NSLog(@"录音成功");
            NSLog(@"%@",recordPath);
            // 发送语音给服务器
            [self sendVoice:recordPath duration:aDuration];
            
        }else{
            NSLog(@"== %@",error);
            
        }
    }];
}
#pragma mark 手指从按钮外面松开取消录音
- (IBAction)cancelRecordAction:(id)sender {
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    
}

//发送图片
- (IBAction)showImgPickerAction:(id)sender {
    //显示图片选择的控制器
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    
    // 设置源
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPicker.delegate = self;
    
    [self presentViewController:imgPicker animated:YES completion:NULL];
}

/**用户选中图片的回调*/
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //1.获取用户选中的图片
    UIImage *selectedImg =  info[UIImagePickerControllerOriginalImage];
    
    
    
    //2.发送图片
    [self sendImg:selectedImg];
    
    //3.隐藏当前图片选择控制器
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //停止语音播放
    [XMGAudioPlayTool stop];
}


-(void)addDataSourcesWithMessage:(EMMessage *)msg{
    // 1.判断EMMessage对象前面是否要加 "时间"
    //    if (self.dataSources.count == 0) {
    ////        long long timestamp = ([[NSDate date] timeIntervalSince1970] - 60 * 60 * 24 * 2) * 1000;
    //
    //    }
    
    NSString *timeStr = [XMGTimeTool timeStr:msg.timestamp];
    if (![self.currentTimeStr isEqualToString:timeStr]) {
        [self.dataSources addObject:timeStr];
        self.currentTimeStr = timeStr;
    }
    // 2.再加EMMessage
    [self.dataSources addObject:msg];
    
    // 3.设置消息为已读取
    [self.conversation markMessageWithId:msg.messageId asRead:YES];
    
}

#pragma mark - 表情雨动画模块
//开始动画
- (void)startTimer{
    //动画对应的数字不存在时候返回
    if (self.number == 0) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(randomAnimateWithDelay) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self performSelector:@selector(fireTimer) withObject:nil afterDelay:3];
    
}

//停止动画
- (void)fireTimer {
    [self.timer invalidate];
    self.timer = nil;
}

//延时随机动画
- (void)randomAnimateWithDelay {
    double time = arc4random() % 5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self randomAnimateGif];
    });
}

//随机动画（gif）
- (void)randomAnimateGif {
    if (self.number == 0) return;
    
    int i = HKWidth;
    /*
     *起始位置x1,终点位置x2
     */
    double x1 = arc4random() % i;
    double x2 = arc4random() % (i / 2);
    if (x1 > HKWidth / 2) {
        x2 = -x2;
    }
    NSString *nameStr = [NSString stringWithFormat:@"expression%d",self.number];
    NSString *path = [[NSBundle mainBundle] pathForResource:nameStr ofType:@"gif"];
    self.gifView = [[GifView alloc] initWithFrame:CGRectMake(x1, -50, 24, 24) filePath:path];
    if (x1 < 30 || x1 > (HKWidth - 30)) {
        self.gifView.frame = CGRectMake(x1, -HKHeight, 48, 48);
    }else if (x1 > 100 && x1 < 110) {
        self.gifView.frame = CGRectMake(x1, -HKHeight, 96, 96);
    }
    
    [UIView animateWithDuration:4 animations:^{
        self.gifView.transform = CGAffineTransformMakeTranslation(x2,2 * HKHeight);
    }];
    [self.view addSubview:self.gifView];
}

//按钮点击
- (void)initAnmiate:(NSString *)string {
    //再次点击按钮取消动画，动画文字对应的数字重置
    [self.timer invalidate];
    self.number = 0;
    
    NSString *text = string;
    if ([text containsString:@"羞"]) {
        self.number = 6;
    }
    if ([text containsString:@"色"]) {
        self.number = 3;
    }
    if ([text containsString:@"么么哒"]) {
        self.number = 75;
    }
    if ([text containsString:@"开心"]) {
        self.number = 13;
    }
    if ([text containsString:@"哈哈"]) {
        self.number = 19;
    }
    if ([text containsString:@"傻笑"]) {
        self.number = 27;
    }
    if ([text containsString:@"衰"]) {
        self.number = 33;
    }
    if ([text containsString:@"棒"]) {
        self.number = 65;
    }
    if ([text isEqualToString:@""]) {
        return;
    }else {
        [self startTimer];
    }
}

@end
