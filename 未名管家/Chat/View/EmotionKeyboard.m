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

@interface EmotionKeyboard()
/**
 *  表情内容
 */
@property (nonatomic, strong) EmotionListView *listView;
/**
 *  表情底部的工具条
 */
@property (nonatomic, strong) EmotionTabBar *tabBar;

@end

@implementation EmotionKeyboard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1.表情内容
        EmotionListView *listView = [[EmotionListView alloc] init];
        listView.backgroundColor = [UIColor redColor];
        [self addSubview:listView];
        self.listView = listView;
        
        // 2.tabbar
        EmotionTabBar *tabBar = [[EmotionTabBar alloc] init];
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
    self.listView.x = self.listView.y = 0;
    self.listView.width = self.width;
    self.listView.height = self.tabBar.y;
}

@end
