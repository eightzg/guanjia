#import "MyCollectionViewCell.h"

@implementation MyCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
        //设置标题标签在父控件的位置
        self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height/2)];
        self.userLabel.textAlignment = NSTextAlignmentCenter;
        self.userLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:self.userLabel];
        
        //设置原因标签在父控件的位置
        self.reasonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2, frame.size.width, frame.size.height/2)];
        self.reasonLabel.textAlignment = NSTextAlignmentCenter;
        self.reasonLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:self.reasonLabel];
        
        //设置原因标签在父控件的位置
        self.commonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.commonLabel.textAlignment = NSTextAlignmentCenter;
        self.commonLabel.font = [UIFont systemFontOfSize:13];
        self.commonLabel.numberOfLines = 2;
        [self.contentView addSubview:self.commonLabel];
    }
    
    return self;
}

@end