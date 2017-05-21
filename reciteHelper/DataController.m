//
//  DataController2.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/9.
//  Copyright © 2017年 zhangliang. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataController.h"
#import "card_manage.h"
#import "card.h"
#import "cardMO.h"
#import "cardGroup.h"
#import "cardGroup.h"
#import "groupMO.h"

@implementation DataController

/* 返回自己的单例 */
+(instancetype) dataController
{
    static DataController * it_self = nil;
    if (!it_self)
    {
        it_self = [[DataController alloc] init];
        it_self.persistentContainer = [[NSPersistentContainer alloc] initWithName:@"dataController"];
        
        [it_self.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *description, NSError *error) {
            if (error != nil) {
                NSLog(@"ERROR : Failed to load Core Data stack: %@", error);
                abort();
            }
        }];
        
    }
    
    return it_self;
}


/* 插入一个新分组 , */
-(void) InsertOneGrp:(cardGroup *) grp
{
    /* 对其观察，进行kvo */
   // [self observeOneCd:cd];
    
    /* 调用performBackgroundTask时：
     apple 帮你创建了一个back_ground_moc，并传入。
     */
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * backMoc) {
        
        groupMO * grpMo = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:backMoc];
        grpMo.grpName = grp.grpName;
        NSLog(@" insertOnegrp group name %@  thread %@",grpMo.grpName,[NSThread currentThread]);
        
        NSMutableSet * set = [NSMutableSet set];
//        for (card * cd in grp.cardArr)
//        {
//            cardMO * cdMo = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:backMoc];
//            cdMo.createTime = cd.createTime;
//            cdMo.headText = cd.headText;
//            cdMo.detailText = cd.detailText;
//            cdMo.mark = cd.mark;
//            cdMo.groupName = cd.groupName;
//            [set addObject:cdMo];
//        }
        
        grpMo.relationCard = set;
        
        NSError *error = nil;
        if ([backMoc save:&error] == NO) {
            NSAssert(NO, @"Error ：%s saving context: %@\n%@", __FUNCTION__,[error localizedDescription], [error userInfo]);
        }
        else{
            NSLog(@"CORRECT : %s , save success , %@",__FUNCTION__, [NSThread currentThread]);
        }

        
        
        
        
        
        
        
        
        /* 先找到添加到的组 */
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
        
        // 精确匹配 ，更多匹配见 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/FetchingObjects.html#//apple_ref/doc/uid/TP40001075-CH6-SW1
        [request setPredicate:[NSPredicate predicateWithFormat:@"grpName == %@",grp.grpName]];
        
        NSError *error2 = nil;
        NSArray * results2 = [backMoc executeFetchRequest:request error:&error2];
        if (!results2) {
            NSLog(@"ERROR fetching Employee objects: %@\n%@", [error2 localizedDescription], [error2 userInfo]);
            abort();
        }
        
        /* 没有对应分组，则保存分组，保存分组内部会保存卡片 */
        if (0 == results2.count)
        {
            NSLog(@"ERROR : %s , there is not group with name %@ , thread %@",__FUNCTION__,grp.grpName, [NSThread currentThread]);
            return ;
        }
        else{
           NSLog(@"CORRECT : %s , there is group with name %@ , thread %@",__FUNCTION__,grp.grpName, [NSThread currentThread]);
        }

    }];

    return ;
}

/* 更新一个指定分组的内容，由于可能更改了名字，所以需要传入老的分组名 */
-(void) EditOneGroup:(cardGroup *) group oldGroupName:(NSString *)oldGrpName
{
    /* 调用performBackgroundTask时：
     apple 帮你创建了一个back_ground_moc，并传入。
     */
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * backMoc) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
        // 精确匹配 ，更多匹配见 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/FetchingObjects.html#//apple_ref/doc/uid/TP40001075-CH6-SW1
        [request setPredicate:[NSPredicate predicateWithFormat:@"grpName == %@",oldGrpName]];
        
        NSError *error = nil;
        NSArray * results = [backMoc executeFetchRequest:request error:&error];
        
        /* 找不到或找到多个数据 */
        if (!results || 1 != results.count) {
            NSLog(@"WARNING %s  fetching objects: %@\n%@ ,  search result : %lu", __FUNCTION__, [error localizedDescription], [error userInfo], (long)(results.count));
            //abort();
        }
        
        groupMO * grp = results[0];
        grp.grpName = group.grpName;

        if ([backMoc save:&error] == NO) {
            NSAssert(NO, @"Error ：%s saving context: %@\n%@", __FUNCTION__,[error localizedDescription], [error userInfo]);
        }
    }];
    
    return ;
}

/* 删除一个分组(不需要再对分组内的卡片进行移动等操作，删分组之前这个已经做了) */
-(void) DeleteOneGrp:(cardGroup *) grp
{
    /* 调用performBackgroundTask时：
     apple 帮你创建了一个back_ground_moc，并传入。
     */
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * backMoc) {
        /* zhang-attention : core data还有这种情况吗，难道每次执行前别的在执行，这里同时操作，就会挂到，不是应该等待吗? 
         目前的临时做法，可能前面的移动分组还在进行中，所以这里等一下，。 */
        sleep(8);
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"grpName == %@",grp.grpName]];
        
        NSError *error = nil;
        NSArray * results = [backMoc executeFetchRequest:request error:&error];
        
        /* 找不到或找到多个数据 */
        if (!results || 1 != results.count) {
            NSLog(@" WARNING %s fetching Employee objects: %@\n%@ ,  search result : %lu", __FUNCTION__,[error localizedDescription], [error userInfo], results.count);
            //abort();
        }
        
        [backMoc deleteObject:results[0]];
 
        if ([backMoc save:&error] == NO) {
            NSAssert(NO, @"Error ：%s saving context: %@\n%@", __FUNCTION__,[error localizedDescription], [error userInfo]);
        }
        else{
            NSLog(@" delete grp success!!!!!!!!!!!!! ");
        }
    }];
    return ;
}


/* 编辑一个指定数据 */
-(void) EditOneCard:(card *) cd
{
    /* 调用performBackgroundTask时：
     apple 帮你创建了一个back_ground_moc，并传入。
     */
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * backMoc) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
        // 精确匹配 ，更多匹配见 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/FetchingObjects.html#//apple_ref/doc/uid/TP40001075-CH6-SW1
        [request setPredicate:[NSPredicate predicateWithFormat:@"createTime == %@",cd.createTime]];
        
        NSError *error = nil;
        NSArray * results = [backMoc executeFetchRequest:request error:&error];
        
        /* 找不到或找到多个数据 */
        if (!results || 1 != results.count) {
            NSLog(@"WARNING %s  fetching Employee objects: %@\n%@ ,  search result : %lu", __FUNCTION__, [error localizedDescription], [error userInfo], (long)(results.count));
            //abort();
        }
        
        cardMO * cardTemp = (cardMO *)results[0];
        cardTemp.headText = cd.headText;
        cardTemp.detailText = cd.detailText;
        cardTemp.mark = cd.mark;
        cardTemp.groupName = cd.groupName;
        
        if ([backMoc save:&error] == NO) {
            NSAssert(NO, @"Error ：%s saving context: %@\n%@", __FUNCTION__,[error localizedDescription], [error userInfo]);
        }
    }];
    
    return ;
}

/* 向一个分组插入一个新卡片，分组必须先存在，否则可以判断业务逻辑和预想的不一样 */
-(void) moveOneCard:(card *) cd fromOldGroup:(NSString *)oldgGrpName toGroup:(NSString *)newGrpName;
{
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * backMoc) {
        
        NSLog(@" move thread : %@  <=================> backMoc %@", [NSThread currentThread],
              backMoc);
    
        /* 先找到老分组 */
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"grpName == %@",oldgGrpName]];
        
        NSError *error = nil;
        NSArray * results = [backMoc executeFetchRequest:request error:&error];
        if (!results) {
            NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        
        /* 再找到新分组 */
        NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
        [request2 setPredicate:[NSPredicate predicateWithFormat:@"grpName == %@",newGrpName]];
        
        NSError *error2 = nil;
        NSArray * results2 = [backMoc executeFetchRequest:request2 error:&error2];
        if (!results2) {
            NSLog(@"Error fetching Employee objects: %@\n%@", [error2 localizedDescription], [error2 userInfo]);
            abort();
        }
        
        /* 再找到移动的card */
        NSFetchRequest *request3 = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
        [request3 setPredicate:[NSPredicate predicateWithFormat:@"createTime == %@",cd.createTime]];
        
        NSError *error3 = nil;
        NSArray * results3 = [backMoc executeFetchRequest:request3 error:&error3];
        if (!results3) {
            NSLog(@"Error fetching Employee objects: %@\n%@", [error3 localizedDescription], [error3 userInfo]);
            abort();
        }
        
        /* 没有对应分组，则保存分组，保存分组内部会保存卡片 */
        if ((1 != results.count) || (1 != results2.count) || (1 != results3.count))
        {
            if (1 != results.count)
            {
                NSLog(@"ERROR : %s , can not find old group with name %@ , or count %lu is not 1",__FUNCTION__,oldgGrpName,(unsigned long)results.count);
            }
            
            if (1 != results2.count)
            {
                NSLog(@"ERROR : %s , can not find new group with name %@ , or count %lu is not 1",__FUNCTION__,newGrpName,(unsigned long)results2.count);
            }
            
            if (1 != results2.count)
            {
                NSLog(@"ERROR : %s , can not moving card create time %@ , or count %lu is not 1",__FUNCTION__,cd.createTime,(unsigned long)results3.count);
            }
            return ;
        }
        else{
            
            groupMO * grpMO1 = results[0];
            groupMO * grpMO2 = results2[0];
            cardMO * cdMO = results3[0];
            cdMO.groupName = grpMO2.grpName;
            
            [[grpMO1 mutableSetValueForKeyPath:@"relationCard"] removeObject:cdMO];
            [[grpMO2 mutableSetValueForKeyPath:@"relationCard"] addObject:cdMO];
            
            NSError *error4 = nil;
            
            @try {
                if ([backMoc save:&error4] == NO) {
                    NSAssert(NO, @"Error ：%s saving context: %@\n%@", __FUNCTION__,[error4 localizedDescription], [error4 userInfo]);
                }
                else{
                    NSLog(@" move thread : %@ done <=================> backMoc %@.", [NSThread currentThread],
                          backMoc);
                }
            } @catch (NSException *exception) {
                NSLog(@" WARNING %s : exception %@.", __FUNCTION__,exception);
                /* 再执行一次 */
                [self moveOneCard:cd fromOldGroup:oldgGrpName toGroup:newGrpName];
            } @finally {
                /* do nothing */
            }
        }
    }];
    
    return ;
}

/* 向一个分组插入一个新卡片，分组必须先存在，否则可以判断业务逻辑和预想的不一样 */
-(void) InsertOneCard:(card *) cd toGroup:(NSString *)groupName;
{
    [self.persistentContainer performBackgroundTask:^(NSManagedObjectContext * backMoc) {
        NSInteger retry_count = 0;
        NSArray * results = nil;
        while(retry_count < 3)
        {
            /* 先找到添加到的组 */
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
            
            // 精确匹配 ，更多匹配见 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/FetchingObjects.html#//apple_ref/doc/uid/TP40001075-CH6-SW1
            [request setPredicate:[NSPredicate predicateWithFormat:@"grpName == %@",groupName]];
            
            NSError *error = nil;
            results = [backMoc executeFetchRequest:request error:&error];
            if (!results) {
                NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
            }
            
            /* 没有对应分组，则保存分组，保存分组内部会保存卡片 */
            if (0 == results.count)
            {
                NSLog(@"WARNING : %s , there is not group with name %@ error %@ thread %@, retry %ld times",__FUNCTION__,groupName, error, [NSThread currentThread],(long)retry_count);
                retry_count++;
                sleep(1);
                continue;
            }
            else{
                break;
            }
        }
        
        if (0 == results.count)
        {
            NSLog(@"ERROR : %s , there is not group with name %@ thread %@",__FUNCTION__,groupName, [NSThread currentThread]);
        }
        
        groupMO * grpMO = results[0];
        cardMO * cdMo = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:backMoc];
        
        cdMo.createTime = cd.createTime;
        cdMo.headText = cd.headText;
        cdMo.detailText = cd.detailText;
        cdMo.mark = cd.mark;
        cdMo.groupName = cd.groupName;
        
        [[grpMO mutableSetValueForKeyPath:@"relationCard"] addObject:cdMo];

        NSError *error = nil;
        if ([backMoc save:&error] == NO) {
            NSAssert(NO, @"Error ：%s saving context: %@\n%@", __FUNCTION__,[error localizedDescription], [error userInfo]);
        }
    }];
    
    [self observeOneCd:cd];
    
    return ;
}

-(void) kvoHandleAddDelete
{
    /* 发生了添加事件 */
    if ([card_manage card_mng].grpCount > [card_manage card_mng].grpCountLast)
    {
        /* zhang-attention : 1, 怎么控制加入的位置 ？ 2, 后续应该放在后台线程做这种事，以免影响主线程 */
        /* 添加的数据默认是放在第一个的 */
        card * cd = [card_manage card_mng].array[0];
        
        /* CORE DATA监听新创建的card */
        [cd addObserver:self
             forKeyPath:@"createTime"
                options:NSKeyValueObservingOptionNew
                context:nil];
        
        [cd addObserver:self
             forKeyPath:@"headText"
                options:NSKeyValueObservingOptionNew
                context:nil];
        
        [cd addObserver:self
             forKeyPath:@"detailText"
                options:NSKeyValueObservingOptionNew
                context:nil];
        
        [cd addObserver:self
             forKeyPath:@"mark"
                options:NSKeyValueObservingOptionNew
                context:nil];
        
        [cd addObserver:self
             forKeyPath:@"group"
                options:NSKeyValueObservingOptionNew
                context:nil];
        
      //  [self InsertOneCard:cd];
    }
    else if([card_manage card_mng].grpCount < [card_manage card_mng].grpCountLast)
    {
        /* zhang-attention : 对象被删除，需要移除观察者 */
        [[card_manage card_mng].deleteGrp removeObserver:self forKeyPath:@"createTime"];
        [[card_manage card_mng].deleteGrp removeObserver:self forKeyPath:@"headText"];
        [[card_manage card_mng].deleteGrp removeObserver:self forKeyPath:@"detailText"];
        [[card_manage card_mng].deleteGrp removeObserver:self forKeyPath:@"mark"];
        [[card_manage card_mng].deleteGrp removeObserver:self forKeyPath:@"group"];
        
      //  [self DeleteOneCard:[card_manage card_mng].deleteGrp];
    }
    else{
        /* do nothing */
    }
}

/* KVO function， 只要object的keyPath属性发生变化，就会调用此函数*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass: [card class]])
    {
        card * backCard = (card *)object;
        [self EditOneCard : backCard];
    }
    else if([object isKindOfClass: [card_manage class]])
    {
        [self kvoHandleAddDelete];
    }
    else{
        NSLog(@"ERROR : %s , unknown type",__FUNCTION__);
    }
    
    return ;
}

-(void) observeOneCd:(card *) newCd
{
    /* CORE DATA 监听数据的变化 */
    [newCd addObserver:self
            forKeyPath:@"createTime"
               options:NSKeyValueObservingOptionNew
               context:nil];
    
    [newCd addObserver:self
            forKeyPath:@"headText"
               options:NSKeyValueObservingOptionNew
               context:nil];
    
    [newCd addObserver:self
            forKeyPath:@"detailText"
               options:NSKeyValueObservingOptionNew
               context:nil];
    
    [newCd addObserver:self
            forKeyPath:@"mark"
               options:NSKeyValueObservingOptionNew
               context:nil];
    
    /* 不关心分组名的变化，分组名变化在 -(void) moveOneCard:(card *) cd fromOldGroup:(NSString *)oldgGrpName toGroup:(NSString *)newGrpName; 中同时完成了 */
//    [newCd addObserver:self
//            forKeyPath:@"groupName"
//               options:NSKeyValueObservingOptionNew
//               context:nil];
}

-(void) unObserveOneCd:(card *) newCd
{
    /* CORE DATA 不再监听数据的变化 */
    [newCd removeObserver:self forKeyPath:@"createTime"];
    [newCd removeObserver:self forKeyPath:@"headText"];
    [newCd removeObserver:self forKeyPath:@"detailText"];
    [newCd removeObserver:self forKeyPath:@"mark"];
    [newCd removeObserver:self forKeyPath:@"groupName"];
    [newCd removeObserver:self forKeyPath:@"createTime"];
}

/* 查询一个指定数据 */
-(NSArray *) FetchOneCard : (NSString *) createTime
{
    NSManagedObjectContext *moc = [self.persistentContainer viewContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Card"];
    
    // 精确匹配 ，更多匹配见 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/FetchingObjects.html#//apple_ref/doc/uid/TP40001075-CH6-SW1
    [request setPredicate:[NSPredicate predicateWithFormat:@"createTime == %@",createTime]];
    
    NSError *error = nil;
    NSArray * results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    return results;
}

/* 获取所有数据 */
-(NSMutableArray *) FetchAllData
{
    NSManagedObjectContext *moc = [self.persistentContainer viewContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];

    NSError *error = nil;
    NSArray * results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    NSMutableArray * retArr = [[NSMutableArray alloc]init];

    for (groupMO * grp in results)
    {
        cardGroup * theGroup = [[cardGroup alloc]init];
        [retArr addObject:theGroup];
        
        theGroup.grpName = grp.grpName;
        theGroup.cardArr = [[NSMutableArray alloc]init];

        for (cardMO * cd in grp.relationCard)
        {
            card * theCard = [[card alloc] init];
            
            theCard.headText = cd.headText;
            theCard.createTime = cd.createTime;
            theCard.detailText = cd.detailText;
            theCard.mark = cd.mark;
            theCard.groupName = cd.groupName;
            
            [theGroup.cardArr addObject:theCard];
            /* core data关注这个card */
            [self observeOneCd:theCard];
        }
    }

    return retArr;
}

@end
