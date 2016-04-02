//
//  UIColor+Random.m
//  未名管家
//
//  Created by apple on 15/11/24.
//  Copyright © 2015年 eight. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor (Random)

+ (UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.3];
}

@end
