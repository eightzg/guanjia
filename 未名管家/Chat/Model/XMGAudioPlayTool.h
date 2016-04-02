//
//  XMGAudioPlayTool.h
//  xmg1chat
//
//  Created by xiaomage on 15/9/28.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EaseMobSDKFull/EaseMob.h>

@interface XMGAudioPlayTool : NSObject

+(void)playWithMessage:(EMMessage *)msg msgLabel:(UILabel *)msgLabel receiver:(BOOL)receiver;

+(void)stop;

@end
