//
//  tinyGroupListController.h
//  reciteHelper
//
//  Created by zhangliang on 2017/5/6.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "card.h"

@interface tinyGroupListController : UITableViewController

@property(nonatomic) CGAffineTransform originTransform;
@property(nonatomic, strong) NSMutableArray* grp_arr;
@property(nonatomic, weak) card * backCard;

/* 将自己添加到superView上，并且使用指定的frame */
-(void) showTinyGroupView: (UIView *) superView withframe: (CGRect) frame;

@end
