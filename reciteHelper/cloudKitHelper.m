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
            NSLog(@" ERROR : save to private fail %@.",error);
            return;
        }
        // Insert successfully saved record code
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
            NSLog(@" ERROR : save to private fail %@.",error);
            return;
        }
        // Insert successfully saved record code
        NSLog(@" save to private success.");
    }];
    
    return ;
}

/* 将当前所有数据存储到cloudkit(目前是全部删除，再全部存储，没有增量的动作，效率低) */
-(void) justSaveAll
{
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
            for (CKRecord * record in results)
            {
                /* 删除所有的数据 */
                [privateDatabase deleteRecordWithID:record.recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                    //
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
            for (CKRecord * record in results2)
            {
                /* 删除所有的数据 */
                [privateDatabase deleteRecordWithID:record.recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
                    //
                }];
            }
        }
    }];
    
    return ;
}

-(void) saveAllToCloudKit
{
   // [self clearAllDrrata];
  //  [self saveAllDataPreCheck];
    
    /* 只有当前处于ready才可以存储，因为有可能处于刚刚从网络获取数据，往cardManage同步的过程中，此时cardManage由于有新数据，也会要求写数据，但此时不能写数据 */
    if (READY == self.state)
    {
        [self justSaveAll];
    }
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
            NSLog(@"fetch cardGroup success");
            
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
                NSLog(@"cloudKit fetch done1");
            }
        }
    }];
    
    
    CKQuery *query2 = [[CKQuery alloc] initWithRecordType:@"card" predicate:predicate];
    [privateDatabase performQuery:query2 inZoneWithID:nil completionHandler:^(NSArray *results2, NSError *error) {
        if (error) {
            NSLog(@"WATING : fetch failed results %@",results2);
        }
        else {
            NSLog(@"fetch card success");
            
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
                NSLog(@"cloudKit fetch done2");
            }
        }
    }];
    
    return;
}

































@end
