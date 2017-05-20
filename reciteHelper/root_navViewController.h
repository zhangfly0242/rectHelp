//
//  root_navViewController.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/8.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "profile_vc.h"

/* 这个类作为根 navigation view controller，
 1 : 一方面承载主要的tableView
 2 : 提前将profile view 添加到自己的view的隐藏的左侧。
 3 : 若用户点击了tableView上面的 “我” 的图标，tableView只是发一个通知，这里处理接下来的事情 : 右移自己的view,漏出提前添加好的subView - profile view */

@interface root_navViewController : UINavigationController

/* 自己管理的profile */
@property(nonnull, strong) profile_vc * profile;

-(void)profile_click;

@end
