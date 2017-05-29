//
//  home_page_tableViewController.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/6.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cardEditController.h"

#define ALL_GROUP @"group"

@interface home_page_tableViewController : UITableViewController

@property(nonatomic, strong) NSMutableArray * data;
@property(nonatomic, strong) NSMutableArray* cell_arr;
@property(nonatomic, strong) NSString * grp_name;
/* 从它进入一个viewController后，会将该值置位，等回到该视图，再负责将tabBar显示 */
@property(nonatomic) BOOL makeTabBarShowLater;

-(instancetype)initWithData: (NSMutableArray *)data grpName: (NSString *)name ;
-(void)add_button_click;

@end
