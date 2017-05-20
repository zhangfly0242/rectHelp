//
//  cardMO.m
//  reciteHelper
//
//  Created by zhangliang on 2017/5/14.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "cardMO.h"

@implementation cardMO

/* subclass NSManagedObject 需要定义 @dynamic 。参见https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/CreatingObjects.html#//apple_ref/doc/uid/TP40001075-CH5-SW1*/

@dynamic createTime;
@dynamic headText;
@dynamic detailText;
@dynamic mark;
@dynamic groupName;

@end
