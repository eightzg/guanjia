//
//  ChangeNickVC.h
//  未名管家
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 eight. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeNickVCBlock)(NSString *string);

@interface ChangeNickVC : UIViewController

@property (nonatomic, strong) ChangeNickVCBlock block;
/**
 *  昵称
 */
@property (nonatomic, copy) NSString *nick;

@end
