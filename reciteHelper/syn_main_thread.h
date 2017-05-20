//
//  syn_main_thread.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/16.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface syn_main_thread : NSObject 

@property(nonatomic, strong) NSThread * workerThread;


/* 返回自己的单例 */
+(instancetype) manager;

- (void)launchWorkerThread;
-(void) recvMsg;
-(void) sendMsg;

-(void) try_send_test;

@end
