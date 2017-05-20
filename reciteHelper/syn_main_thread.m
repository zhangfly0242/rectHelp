//
//  syn_main_thread.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/16.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "syn_main_thread.h"
#import "syn_worker_thread.h"

@implementation syn_main_thread

+(instancetype) manager
{
    static syn_main_thread * it_self = nil;
    if (!it_self)
    {
        it_self = [[syn_main_thread alloc] init];
        
        [it_self launchWorkerThread];
    }
    
    return it_self;
}

/* 来自 博客《小笨狼漫谈多线程：NSThread》 */
- (void)launchWorkerThread
{
    // This class handles incoming port messages.
    // Install the port as an input source on the current run loop.
    
    self.workerThread = [[NSThread alloc] initWithTarget:[syn_worker_thread worker] selector:@selector(threadMain) object:nil]; // ①创建线程
    
    self.workerThread.qualityOfService = NSQualityOfServiceDefault; //②设置线程优先级
    [self.workerThread start]; //③启动线程
}

/* 线程通信流程 */
-(void) recvMsg
{
    
}

/* 线程通信流程 */
-(void) sendMsg
{
    [[syn_worker_thread worker] performSelector:@selector(recvMsg) onThread:self.workerThread withObject:nil waitUntilDone:NO];
}

















/* 业务流程 */
-(void) try_send_test
{
    [self sendMsg];
}















@end
