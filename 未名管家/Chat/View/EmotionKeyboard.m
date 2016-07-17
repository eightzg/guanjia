//
//  EmotionKeyboard.m
//  未名管家
//
//  Created by apple on 16/6/6.
//  Copyright © 2016年 eight. All rights reserved.
//

#import "EmotionKeyboard.h"
#import "EmotionListView.h"
#import "EmotionTabBar.h"
#import "Emotion.h"
#import "MJExtension.h"

@interface EmotionKeyboard() <EmotionTabBarDelegate>
/** 容纳表情内容的控件 */
@property (nonatomic, weak) UIView *contentView;
/** 表情内容 */
@property (nonatomic, strong) EmotionListView *recentListView;
@property (nonatomic, strong) EmotionListView *defaultListView;
@property (nonatomic, strong) EmotionListView *emojiListView;
@property (nonatomic, strong) EmotionListView *lxhListView;
/**
 *  表情底部的工具条
 */
@property (nonatomic, strong) EmotionTabBar *tabBar;

@end

@implementation EmotionKeyboard
#pragma mark - 懒加载
- (EmotionListView *)recentListView
{
    if (!_recentListView) {
        self.recentListView = [[EmotionListView alloc] init];
        self.recentListView.backgroundColor = HKRandomColor;
    }
    return _recentListView;
}

- (EmotionListView *)defaultListView
{
    if (!_defaultListView) {
        self.defaultListView = [[EmotionListView alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmotionIcons/default/info.plist" ofType:nil];
        self.defaultListView.emotions = [Emotion objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
        self.defaultListView.backgroundColor = HKRandomColor;
    }
    return _defaultListView;
}

- (EmotionListView *)emojiListView
{
    if (!_emojiListView) {
        self.emojiListView = [[EmotionListView alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmotionIcons/emoji/info.plist" ofType:nil];
        self.emojiListView.emotions = [Emotion objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
        self.emojiListView.backgroundColor = HKRandomColor;
    }
    return _emojiListView;
}

- (EmotionListView *)lxhListView
{
    if (!_lxhListView) {
        self.lxhListView = [[EmotionListView alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmotionIcons/lxh/info.plist" ofType:nil];
        self.lxhListView.emotions = [Emotion objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
        self.lxhListView.backgroundColor = HKRandomColor;
    }
    return _lxhListView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1.contentView
        UIView *contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        self.contentView = contentView;
        
        // 2.tabbar
        EmotionTabBar *tabBar = [[EmotionTabBar alloc] init];
        tabBar.delegate = self;
        [self addSubview:tabBar];
        self.tabBar = tabBar;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.tabbar
    self.tabBar.width = self.width;
    self.tabBar.height = 44;
    self.tabBar.x = 0;
    self.tabBar.y = self.height - self.tabBar.height;
    
    // 2.表情内容
    self.contentView.x = self.contentView.y = 0;
    self.contentView.width = self.width;
    self.contentView.height = self.tabBar.y;
    
    // 3.设置frame
    UIView *child = [self.contentView.subviews lastObject];
    child.frame = self.contentView.bounds;
}

#pragma mark - HWEmotionTabBarDelegate
- (void)emotionTabBar:(EmotionTabBar *)tabBar didSelectButton:(EmotionTabBarButtonType)buttonType
{
    // 移除contentView之前显示的控件
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    switch (buttonType) {
        case EmotionTabBarButtonTypeRecent: // 最近
            [self.contentView addSubview:self.recentListView];
            break;
            
        case EmotionTabBarButtonTypeDefault: // 默认
            [self.contentView addSubview:self.defaultListView];
            break;
            
        case EmotionTabBarButtonTypeEmoji: // Emoji
            [self.contentView addSubview:self.emojiListView];
            break;
            
        case EmotionTabBarButtonTypeLxh: // Lxh
            [self.contentView addSubview:self.lxhListView];
            break;
    }
    
    [self setNeedsLayout];
}

@end
