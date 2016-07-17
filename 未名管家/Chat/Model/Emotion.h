//
//  Emotion.h
//  未名管家
//
//  Created by apple on 16/7/17.
//  Copyright © 2016年 eight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Emotion : NSObject
/** 表情的文字描述 */
@property (nonatomic, copy) NSString *chs;
/** 表情的png图片名 */
@property (nonatomic, copy) NSString *png;
/** emoji表情的16进制编码 */
@property (nonatomic, copy) NSString *code;

@end
