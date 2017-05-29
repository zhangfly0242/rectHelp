//
//  cloudKitHelper.h
//  reciteHelper
//
//  Created by zhangliang on 2017/5/25.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface cloudKitHelper : NSObject

/* 返回自己的单例 */
+(instancetype) KIT;

@property(nonatomic, strong) NSMutableArray* grpArr;
@property(nonatomic, strong) NSMutableArray* cardArr;
@property(nonatomic) NSInteger state;

/* app一启动时，获取初始的数据 */
@property(nonatomic) BOOL getDataDone;

/* 将当前所有数据存储到cloudkit(目前是全部都存储，效率低，并且不会删除已经删除的) */
-(void) saveAllToCloudKit;


/* 获取所有数据 */
-(void) getAllData;

#if 0
/* 存储测试数据 */
-(void) try_save_test_data;
#endif

@end
