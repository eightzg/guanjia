//
//  RegistVC.h
//  未名管家
//
//  Created by apple on 15/11/18.
//  Copyright (c) 2015年 eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegistVCdelegate <NSObject>

- (void)registUser:(NSString *)user password:(NSString *)pwd;

@end

@interface RegistVC : UIViewController

@property (nonatomic, weak) id<RegistVCdelegate> delegate;

@end
