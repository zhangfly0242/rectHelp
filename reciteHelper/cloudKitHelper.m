//
//  cloudKitHelper.m
//  reciteHelper
//
//  Created by zhangliang on 2017/5/25.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "cloudKitHelper.h"
#import <CloudKit/CloudKit.h>
#import "card_manage.h"
#import "cardGroup.h"
#import "card.h"

#define INIT (0)
#define READY (1)

@implementation cloudKitHelper

/* 返回自己的单例 */
+(instancetype) KIT
{
    static cloudKitHelper * it_self = nil;
    if (!it_self)
    {
        it_self = [[cloudKitHelper alloc]init];
        it_self.grpArr = [[NSMutableArray alloc]init];
        it_self.cardArr = [[NSMutableArray alloc]init];
        it_self.getDataDone = NO;
        it_self.state = INIT;
    }
    
    return it_self;
}

-(void) saveOneGrp : (cardGroup *) grp
{
    //1, Create a record ID specifying a unique record name.
    CKRecordID * grpRecordID = [[CKRecordID alloc] initWithRecordName:grp.grpName];
    
    //2, Create a record object.
    CKRecord * oneRecord = [[CKRecord alloc] initWithRecordType:@"cardGroup" recordID:grpRecordID];
    
    //3, Set the record’s fields.
    oneRecord[@"grpName"] = grp.grpName;
    
    //4, get container
    CKContainer *myContainer = [CKContainer containerWithIdentifier:@"iCloud.recite.reciteHelper"];
    // get publicDatabase
    CKDatabase *privateDatabase = [myContainer privateCloudDatabase];
    
    //5, save
    [privateDatabase saveRecord:oneRecord completionHandler:^(CKRecord *artworkRecord, NSError *error){
        if (error) {
            // Insert error handling
            /* 因为重复存储，也会报错，目前还不考虑其他的错误。这里也算存储成功 */
            self.currentWaitAddCountGrp--;
            NSLog(@" ERROR : save to private fail %@.",error);
            return;
        }
        // Insert successfully saved record code
        self.currentWaitAddCountGrp--;
        NSLog(@" save to private success.");
    }];
    
    return ;
}

-(void) saveOneCard : (card *) cd
{
    //1, Create a record ID specifying a unique record name.
    CKRecordID * oneCdID = [[CKRecordID alloc] initWithRecordName:cd.createTime];
    
    //2, Create a record object.
    CKRecord * oneRecord = [[CKRecord alloc] initWithRecordType:@"card" recordID:oneCdID];
    
    //3, Set the record’s fields.
    oneRecord[@"createTime" ] = cd.createTime;
    oneRecord[@"headText" ] = cd.headText;
    oneRecord[@"detailText" ] = cd.detailText;
    oneRecord[@"mark" ] = cd.mark;
    oneRecord[@"groupName" ] = cd.groupName;
    
    //4, get container
    CKContainer *myContainer = [CKContainer containerWithIdentifier:@"iCloud.recite.reciteHelper"];
    // get publicDatabase
    CKDatabase *privateDatabase = [myContainer privateCloudDatabase];
    
    //5, save
    [privateDatabase saveRecord:oneRecord completionHandler:^(CKRecord *artworkRecord, NSError *error){
        if (error) {
            // Insert error handling
            /* 因为重复存储，也会报错，目前还不考虑其他的错误。这里也算存储成功 */
            self.currentWaitAddCountCard--;
            NSLog(@" ERROR : save to private fail %@.",error);
            return;
        }
        self.currentWaitAddCountCard--;
        // Insert successfully saved record code
        NSLog(@" save to private success.");
    }];
    
    return ;
}

/* 将当前所有数据存储到cloudkit(目前是全部删除，再全部存储，没有增量的动作，效率低) */
-(void) justSaveAll
{
    /* 当前还在删除所有数据的过程中 */
    if (0 != self.currentWaitDelCountGrp || 0 != self.currentWaitDelCountCard)
    {
        return;
    }
    else{
        /* 正式进入删除流程，去掉定时器，定时器的目的就是等待 */
        [self.timer invalidate];
    }
    

    
    NSArray * arr = [card_manage card_mng].array;
    for (cardGroup * grp in arr)
    {
        [self saveOneGrp:grp];
        
        for (card * cd in grp.cardArr)
        {
            [self saveOneCard:cd];
        }
    }
    
    return ;
}

#if 0
/* 保存所有数据前，保证所有数据都被清空了 */
-(void) saveAllDataPreCheck
{
    // 1, get container
    CKContainer *myContainer = [CKContainer containerWithIdentifier:@"iCloud.recite.reciteHelper"];
    
    // 2, 获得私人数据库
    CKDatabase *privateDatabase = [myContainer privateCloudDatabase];
    
    /* 返回所有数据 */
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"cardGroup" predicate:predicate];
    [privateDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"WATING : fetch failed results %@",results);
        }
        else {
            /* 已经清空，正式开始保存的动作 */
            if (!results || 0 == results.count)
            {
                [self justSaveAll];
            }
            else{
                NSLog(@" try check again .. ");
                [self saveAllDataPreCheck];
            }
        }
    }];
    
}
#endif


-(void) clearAllData
{
    // 1, get container
    CKContainer *myContainer = [CKContainer containerWithIdentifier:@"iCloud.recite.reciteHelper"];
    
    // 2, 获得私人数据库
    CKDatabase *privateDatabase = [myContainer privateCloudDatabase];
    
    /* 返回所有数据 */
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"cardGroup" predicate:predicate];
    [privateDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"WATING : fetch failed results %@",results);
        }
        else {
            self.currentWaitDelCountGrp = results.count;
            
            for (CKRecord * record in results)
            {
                /* 删除所有的分组 */
                [privateDatabase deleteRecordWithID:record.recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                    if (self.currentWaitDelCountGrp > 0)
                    {
                        self.currentWaitDelCountGrp--;
                    }/* 不可能小于0，否则就是出现了异常 */
                    else{
                        NSLog(@" ERROR : %s self.currentWaitDelCountGrp is %ld",
                              __FUNCTION__, (long)self.currentWaitDelCountGrp);
                    }
                }];
            }
        }
    }];
    
    
    CKQuery *query2 = [[CKQuery alloc] initWithRecordType:@"card" predicate:predicate];
    [privateDatabase performQuery:query2 inZoneWithID:nil completionHandler:^(NSArray *results2, NSError *error) {
        if (error) {
            NSLog(@"WATING : fetch failed results %@",results2);
        }
        else {
            self.currentWaitDelCountCard = results2.count;
            
            for (CKRecord * record in results2)
            {
                /* 删除所有的卡片 */
                [privateDatabase deleteRecordWithID:record.recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                    if (self.currentWaitDelCountCard > 0)
                    {
                        self.currentWaitDelCountCard--;
                    }/* 不可能小于0，否则就是出现了异常 */
                    else{
                        NSLog(@" ERROR : %s self.currentWaitDelCountCard is %ld",
                              __FUNCTION__, (long)self.currentWaitDelCountCard);
                    }
                }];
            }
        }
    }];
    
    return ;
}

-(void) saveAllToCloudKit
{
    
    NSLog(@"  saveAllToCloudKit  ");
    
    /* 只有当前处于ready才可以存储，因为有可能处于刚刚从网络获取数据，往cardManage同步的过程中，此时cardManage由于有新数据，也会要求写数据，但此时不能写数据 */
    if (READY != self.state)
    {
        return ;
    }
    
    /* 总的存储入口，全部删除，再全部添加，如果当前处于任何的删除或添加状态，直接返回 */
    if (0 != self.currentWaitAddCountGrp || 0 != self.currentWaitAddCountCard)
    {
        NSLog(@"WARNING : %s , try write when writing .self.currentWaitAddCountGrp %ld , self.currentWaitAddCountCard %ld",
              __FUNCTION__, (long)self.currentWaitAddCountGrp, (long)self.currentWaitAddCountCard);
        return ;
    }
    
    [self clearAllData];
    
    NSInteger cardCount  = 0;
    
    for (cardGroup * grp in [card_manage card_mng].array)
    {
        cardCount += grp.cardArr.count;
    }
    
    /* 把最终要存储的量记录下来，也是一个开始存储流程的标记，下一次存储必须在该次存储全部完成后，
     才能开始。 从设置这个标记，到最终标记变为0，中间经过了删除所有记录的等待，存储的等待，两个步骤*/
    self.currentWaitAddCountGrp = [card_manage card_mng].array.count;
    self.currentWaitAddCountCard = cardCount;
    
    /* 通过定时器，轮循等待删除完毕，如果删除完毕，才开始正式的存储 */
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                    selector:@selector(justSaveAll) userInfo:nil repeats:true];
    
}

-(void) getAllData
{
    // 1, get container
    CKContainer *myContainer = [CKContainer containerWithIdentifier:@"iCloud.recite.reciteHelper"];
    
    // 2, 获得私人数据库
    CKDatabase *privateDatabase = [myContainer privateCloudDatabase];
    
    /* 返回所有数据 */
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"cardGroup" predicate:predicate];
    [privateDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"WATING : fetch failed results %@",results);
        }
        else {
            NSLog(@"fetch cardGroup success  , current %lu",(unsigned long)self.cardArr.count);
            
            for (CKRecord * record in results)
            {
                cardGroup * grp = [[cardGroup alloc]init];
                /* zhang-attention : 这是什么写法  kvc ?  也可以用这个写法*/
                //grp.grpName = record[@"grpName"];
                grp.grpName = [record valueForKey:@"grpName"];
                NSLog(@" groName %@ ", grp.grpName);
                
                [self.grpArr addObject:grp];
            }
        
            /* card 也获取完毕，设置状态为完成，通知更新 */
            if (self.cardArr.count >0)
            {
                self.getDataDone = YES;
                self.state = READY;
            }
        }
    }];
    
    CKQuery *query2 = [[CKQuery alloc] initWithRecordType:@"card" predicate:predicate];
    [privateDatabase performQuery:query2 inZoneWithID:nil completionHandler:^(NSArray *results2, NSError *error) {
        if (error) {
            NSLog(@"WATING : fetch failed results %@",results2);
        }
        else {
            NSLog(@"fetch card success , current %lu",(unsigned long)self.grpArr.count);
            
            for (CKRecord * record in results2)
            {
                card * cd = [[card alloc]init];
                
                cd.createTime = record[@"createTime"];
                cd.headText = record[@"headText"];
                cd.detailText = record[@"detailText"];
                cd.mark = record[@"mark"];
                cd.groupName = record[@"groupName"];
                NSLog(@" cd.createTime %@ ", cd.createTime);
                
                [self.cardArr addObject:cd];
            }
            
            /* cardGrp 也获取完毕，设置状态为完成，通知更新 */
            if (self.grpArr.count >0)
            {
                self.getDataDone = YES;
                self.state = READY;
            }
        }
    }];
    
    return;
}

































@end
