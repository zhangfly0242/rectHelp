//
//  tinyGroupCell.h
//  reciteHelper
//
//  Created by zhangliang on 2017/5/6.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tinyGroupCell : UITableViewCell

/* 显示分组的名字，如“生活起居” */
@property (weak, nonatomic) IBOutlet UILabel *group_name;

/* 下面有一行小字，显示分组的简要信息，目前是显示个数，如“2条” */
@property (weak, nonatomic) IBOutlet UILabel *group_brief;

/* 如果卡片属于该分组，那么该分组右边显示出一个绿色的小勾 */
@property (weak, nonatomic) IBOutlet UIImageView *grpSelectImg;

@end
