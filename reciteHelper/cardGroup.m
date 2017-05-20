//
//  cardGroup.m
//  reciteHelper
//
//  Created by zhangliang on 2017/5/9.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "cardGroup.h"
#import "card.h"

@implementation cardGroup

-(instancetype)init
{
    self = [super init];
    
    /* 初始化内部的cardArr */
    _cardArr = [[NSMutableArray alloc]init];
    return self;
}

-(void) addOneCard : (card*) cd
{
    cd.groupName = self.grpName;
    [[self mutableArrayValueForKey:@"cardArr"] addObject:cd];
}
/* 在该组中删除一个card */
-(void) deleteOneCard : (card*) grp
{
    
}

@end
