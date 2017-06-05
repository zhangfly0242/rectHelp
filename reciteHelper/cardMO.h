//
//  cardMO.h
//  reciteHelper
//
//  Created by zhangliang on 2017/5/14.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface cardMO : NSManagedObject

@property(nonatomic, strong) NSString * headText;
@property(nonatomic, strong) NSString * createTime;
@property(nonatomic, strong) NSString * detailText;
/* 标签 ，如@"自然*诗*随想"  ，注意*被当作多个标签的分隔符 */
@property(nonatomic, strong) NSString * mark;
/* 分组 */
@property(nonatomic, strong) NSString * groupName;

/* 字体大小 */
@property(nonatomic) NSNumber* word_size;
/* 扣空的间隔 */
@property(nonatomic) NSNumber* empty_jump;
/* 扣空的空的大小 */
@property(nonatomic) NSNumber* empty_size;


@end
