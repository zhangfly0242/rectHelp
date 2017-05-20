//
//  cardGroup.h
//  reciteHelper
//
//  Created by zhangliang on 2017/5/9.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "card.h"

@interface cardGroup : NSObject

@property(nonatomic, strong) NSString * grpName;
@property(nonatomic, strong) NSMutableArray * cardArr;


/* 通过比较 grpCountLast 和 grpCount 谁大谁小，KVO观察者确定是发生了添加还是删除事件，
 如果是删除事件，删除的具体数据记录在deleteCd中 */
@property(nonatomic) NSInteger grpCountLast;
@property(nonatomic) NSInteger grpCount;

/* 是否处于被操作的状态 ，默认是。如果不是，那么就不能往里面添加，删除card。它是最后一个，只有等这个operation变为TRUE后，才成为正常的分组*/
@property(nonatomic) BOOL operation;

/* 最近一次添加的group*/
@property(nonatomic) cardGroup * addGrp;
/* 最近一次删除的group*/
@property(nonatomic) cardGroup * deleteGrp;

/* 在该组中添加一个card */
-(void) addOneCard: (card *) grp;
/* 在该组中删除一个card */
-(void) deleteOneCard: (card *) grp;

@end
