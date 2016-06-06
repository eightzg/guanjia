//
//  EmotionTabBar.h
//  未名管家
//
//  Created by apple on 16/6/6.
//  Copyright © 2016年 eight. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    EmotionTabBarButtonTypeRecent, // 最近
    EmotionTabBarButtonTypeDefault, // 默认
    EmotionTabBarButtonTypeEmoji, // emoji
    EmotionTabBarButtonTypeLxh, // 浪小花
} EmotionTabBarButtonType;

@class EmotionTabBar;

@protocol EmotionTabBarDelegate <NSObject>

@optional
- (void)emotionTabBar:(EmotionTabBar *)tabBar didSelectButton:(EmotionTabBarButtonType)buttonType;
@end

@interface EmotionTabBar : UIView
@property (nonatomic, weak) id<EmotionTabBarDelegate> delegate;
@end
