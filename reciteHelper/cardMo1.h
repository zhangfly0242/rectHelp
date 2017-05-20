//
//  cardMo.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/9.
//  Copyright © 2017年 zhangliang. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface cardMo1 : NSManagedObject

@property(nonatomic, strong) NSString * headText;
@property(nonatomic, strong) NSString * createTime;
@property(nonatomic, strong) NSString * detailText;
/* 标签 ，如@"自然*诗*随想"  ，注意*被当作多个标签的分隔符 */
@property(nonatomic, strong) NSString * mark;
/* 分组 */
@property(nonatomic, strong) NSString * groupName;


@end
