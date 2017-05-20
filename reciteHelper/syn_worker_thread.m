//
//  syn_worker_thread.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/16.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "syn_worker_thread.h"
#import "syn_main_thread.h"

@implementation syn_worker_thread

+(instancetype) worker
{
    static syn_worker_thread * it_self = nil;
    if (!it_self)
    {
        it_self = [[syn_worker_thread alloc] init];
    }
    
    return it_self;
}

/* 来自 博客《小笨狼漫谈多线程：NSThread》 */
- (void)threadMain {
    [[NSThread currentThread] setName:@"myThread"]; // ①给线程设置名字
    
    /* 第二线程的三部设置 ：主线程不需要下面的创建runloop以及对runloop的设置 */
    
    /* 一给线程添加runloop */
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    /* zhang-attention : 这里添加的这个[NSMachPort port] 是 ？*/
    /* 二给runloop添加数据源和mode, mode一般用NSDefaultRunLoopMode */
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    /* 三开启runloop一 ：定期检查是否被 cancle */
    while (![[NSThread currentThread] isCancelled]) {
        /* 三开启runloop二 ：定期返回，检查是否被 cancle */
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]]; 
    }
}

/* 线程通信流程 */
/* 接收消息处理 */
-(void) recvMsg
{
    [self sendMsg];
}

/* 线程通信流程 */
/* 发送消息处理 */
-(void) sendMsg
{
    [[syn_main_thread manager] performSelector:@selector(recvMsg) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
}


@end
