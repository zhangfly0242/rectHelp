//
//  home_page_tableViewController.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/6.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALL_GROUP @"group"

@interface home_page_tableViewController : UITableViewController

@property(nonatomic, strong) NSMutableArray * data;
@property(nonatomic, strong) NSMutableArray* cell_arr;
@property(nonatomic, strong) NSString * grp_name;

-(instancetype)initWithData: (NSMutableArray *)data grpName: (NSString *)name ;
-(void)add_button_click;

@end