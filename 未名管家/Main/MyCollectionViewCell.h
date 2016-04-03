//
//  AppDelegate.m
//  UICollectionView
//
//  Created by apple on 16/4/2.
//  Copyright © 2016年 eight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCollectionViewCell : UICollectionViewCell
/**
 *  cell顶部的用户标签
 */
@property (nonatomic, strong) UILabel *userLabel;
/**
 *  cell顶部的占用原因
 */
@property (nonatomic, strong) UILabel *reasonLabel;
/**
 *  cell常量文字
 */
@property (nonatomic, strong) UILabel *commonLabel;
@end
