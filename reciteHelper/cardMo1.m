//
//  cardMo.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/9.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "cardMo1.h"

@implementation cardMo1

/* subclass NSManagedObject 需要定义 @dynamic 。参见https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/CreatingObjects.html#//apple_ref/doc/uid/TP40001075-CH5-SW1*/

/* zhang-attention :  都已经有了 @property，为什么这里还需要这些，否则会报警 */
@synthesize createTime;
@synthesize headText;
@synthesize detailText;
@synthesize mark;
@synthesize groupName;

//@dynamic createTime;
//@dynamic headText;
//@dynamic detailText;

@end
