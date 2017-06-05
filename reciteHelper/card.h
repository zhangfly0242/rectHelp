//
//  card.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/6.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface card : NSObject <NSCoding>

@property(nonatomic, strong) NSString * createTime;
@property(nonatomic, strong) NSString * headText;
@property(nonatomic, strong) NSString * detailText;
/* 备注信息 */
@property(nonatomic, strong) NSString * mark;
/* 分组 */
@property(nonatomic, strong) NSString * groupName;

/* 字体大小 */
@property(nonatomic) NSInteger word_size;

/* 扣空的间隔 */
@property(nonatomic) NSInteger empty_jump;

/* 扣空的空的大小 */
@property(nonatomic) NSInteger empty_size;


@end
