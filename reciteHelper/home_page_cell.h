//
//  home_page_cell.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/7.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface home_page_cell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *backGroundView;
@property (weak, nonatomic) IBOutlet UILabel *createTime;
@property (weak, nonatomic) IBOutlet UILabel *detailText;
@property (weak, nonatomic) IBOutlet UILabel *groupName;



@end
