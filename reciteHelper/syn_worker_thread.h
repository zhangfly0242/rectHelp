//
//  syn_worker_thread.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/16.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface syn_worker_thread : NSObject

/* 返回自己的单例 */
+(instancetype) worker;

-(void) threadMain;

-(void) recvMsg;
-(void) sendMsg;

@end
