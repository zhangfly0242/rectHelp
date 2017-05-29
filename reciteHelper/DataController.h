//
//  DataController2.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/9.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "card.h"
#import "cardGroup.h"

@interface DataController : NSObject

@property (strong, nonatomic) NSPersistentContainer * persistentContainer;
@property (nonatomic) BOOL state;

/* 返回自己的单例 */
+(instancetype) dataController;

/* 插入一个分组 */
-(void) InsertOneGrp:(cardGroup *) grp;
/* 更新一个指定分组的内容，由于可能更改了名字，所以需要传入老的分组名 */
-(void) EditOneGroup:(cardGroup *) group oldGroupName:(NSString *)grpName;
/* 删除一个分组(不需要再对分组内的卡片进行移动等操作，删分组之前这个已经做了) */
-(void) DeleteOneGrp:(cardGroup *) grp;

/* 一个分组插入一个新卡片，分组必须先存在，否则可以判断业务逻辑和预想的不一样 */
-(void) InsertOneCard:(card *) cd toGroup:(NSString *)groupName;
/* 向一个分组插入一个新卡片，分组必须先存在，否则可以判断业务逻辑和预想的不一样 */
-(void) moveOneCard:(card *) cd fromOldGroup:(NSString *)oldgGrpName toGroup:(NSString *)newGrpName;
-(void) EditOneCard:(card *) cd;
/* 删除一个卡片*/
-(void) DeleteOneCard:(card *) cd;

@property(strong, atomic) NSManagedObjectContext * mainMoc;
@property(strong, atomic) NSManagedObjectContext * writeMoc;
@property(strong, atomic) NSManagedObjectContext * readMoc;

-(NSArray *) FetchOneCard : (NSString *) createTime;
/* 返回所有数据, 是一个包含分组的数组 */
-(NSMutableArray *) FetchAllData;

/* 观察一个分组 */
-(void) observeOneCd:(card *) newCd;
@end
