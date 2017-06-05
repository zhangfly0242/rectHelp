//
//  home_page_cell.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/7.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "home_page_cell.h"
#import "card.h"

@implementation home_page_cell


-(void) addSubViewOn
{
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    NSLog(@" scrollView %f %f",scrollView.frame.size.width, scrollView.frame.size.height);
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width + 20, scrollView.frame.size.height);
    
    UIView * view_content = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
    view_content.backgroundColor =[UIColor redColor];
    UIView * view_operate = [[UIView alloc]initWithFrame:CGRectMake(scrollView.frame.size.width, 0, 20, scrollView.frame.size.height)];
    view_operate.backgroundColor =[UIColor grayColor];
    
    [scrollView addSubview:view_content];
    [scrollView addSubview:view_operate];
    
    [self addSubview:scrollView];
    
    return ;
}

- (void)awakeFromNib {
    [super awakeFromNib];

/* 暂时屏蔽 */
#if 0
    [self addSubViewOn];
    NSLog(@" awakeFromNib ");
#endif
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
