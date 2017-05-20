//
//  card_manage.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/6.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "card.h"
#import "cardGroup.h"

@interface card_manage : NSObject <NSCoding>

@property(nonatomic, strong) NSMutableArray* array;
/* 通过比较 grpCountLast 和 grpCount 谁大谁小，KVO观察者确定是发生了添加还是删除事件，
 如果是删除事件，删除的具体数据记录在deleteCd中 */
@property(nonatomic) NSInteger grpCountLast;
@property(nonatomic) NSInteger grpCount;


/* 最近一次添加的card*/
@property(nonatomic) card * addCard;
/* 最近一次删除的card*/
@property(nonatomic) card * deleteCard;

/* 最近一次添加的group*/
@property(nonatomic) cardGroup * addGrp;
/* 最近一次删除的group*/
@property(nonatomic) cardGroup * deleteGrp;


/* 返回自己的单例 */
+(instancetype) card_mng;
/* 当前所有card的统计 */
@property(nonatomic) NSInteger cardCount;

/* 返回所有的group */
-(NSArray *)allGrp;

/* 增加一个card到一个分组中, 这里core data只会保存card，分组core data已经存在了 */
-(void) createNewCard : (card *) cd toGrp:(NSString *) grpName;
/* 删除一个card */
-(void) deleteCard : (card *) card;

/* 将一个card移动到新的分组中 */
-(void) moveCardToNewGroup:(card *)cd groupName:(NSString *)newGrpName;

/* 创建一个新分组 */
-(void) createNewGrp:(NSString *)name;
/* 删除一个group */
-(void) deleteGrp : (cardGroup *) grp;

@end

