//
//  icloudManager.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/19.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "icloudManager.h"
#import "textUIDocument.h"

@implementation icloudManager

/* 最初始的状态，不能从服务器下载数据 */
#define icloudUnInit (0)
/* 已经初始化了，可以从服务器下载数据以及上传了 */
#define icloudInit (1)
/* icloud正在card_manage以及ui主线程进行数据同步以及相关的UI更新，不允许进行向服务器进行写操作 */
#define icloudSyn (2)

+(instancetype) icloud_mng
{
    static icloudManager * it_self = nil;
    if (!it_self)
    {
        it_self = [[icloudManager alloc]init];
        it_self.icloudState = icloudUnInit;
    }
    
    return it_self;
}

/* 初始化 NSFileManager，并将icloudReady置位*/
-(void) initIcloud
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    self.currentiCloudToken = fileManager.ubiquityIdentityToken;
    
    /* zhang-attention :  填写你的icloud container的名字，查看capabilities -> icloud -> containers ->
     specify custom containers 中的选中项 (注意，在这之前，做过 ：在apple developer count 中，设置了app id(这里指定了该app使用的icloud tainers的列表，然后生成了profile文件(引用了该app id)，最后在xcode->general 选项卡中设置引用了该profile文件(不选手动生成)))*/
    
    /* Configure an iCloud container for use (The system configures the containerand returns the base URL of the container directory. Do not call it at main thread)*/
    NSURL * myContainer = [[NSFileManager defaultManager]
                           URLForUbiquityContainerIdentifier: @"iCloud.recite.reciteHelper"];
  
    /* You use that URL to build further URLs to specify files and directories */
    NSString * fileString = [myContainer.absoluteString stringByAppendingString:@"zhang5.txt"];
    NSURL * fileUrl = [[NSURL alloc]initWithString:fileString];

    /* When accessing files and directories in a container, iCloud apps are required to use file coordination to do so.
       Apps that use document objects UIDocument get file coordination */
    self.document = [[textUIDocument alloc] initWithFileURL:fileUrl];
    
    self.icloudState = icloudInit;
}

-(void) saveToIcloud: (id) kindOfData
{
    /* 内部与icloud连接，且不能时处于同步期间 ，才能执行后续动作*/
    if (icloudInit != self.icloudState)
    {
        return ;
    }
    
    if ([kindOfData isKindOfClass: [card_manage class]])
    {
        self.writeData = [NSKeyedArchiver archivedDataWithRootObject : kindOfData];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /* 如果为nil，直接返回，否则会挂机 */
        if (!self.writeData)
        {
            NSLog(@"ERROR : %s, writeData is nil ",__FUNCTION__);
            return ;
        }
        
        [self.document saveToURL:self.document.fileURL forSaveOperation:
         UIDocumentSaveForCreating completionHandler:^(BOOL success) {
             NSLog(@" write complete ");
         }];
    });
}

/* app启动时，初始化icloud, 并读取所有icloud数据 */
-(void) readFromIcloud
{
    /* 在后台线程读取icloud数据 */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self initIcloud];
        
        [self.document openWithCompletionHandler:^(BOOL success) {
            
            if (![icloudManager icloud_mng].card_manage.array
                || 0 == [icloudManager icloud_mng].card_manage.array.count)
            {
                return ;
            }
            
            /* 在主线程中更新整个 card_manage */
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL needAdd = TRUE;

                self.icloudState = icloudSyn;
                
                for (card * cd1 in [icloudManager icloud_mng].card_manage.array)
                {
                    needAdd = TRUE;
                    
                    /* 看下是否已经有了，不需要添加了 */
                    for (card * cd2 in [card_manage card_mng].array)
                    {
                        if ([cd1.createTime isEqualToString:cd2.createTime]
                            &&[cd1.headText isEqualToString:cd2.headText]
                               &&[cd1.detailText isEqualToString:cd2.detailText])
//                            &&[cd1.mark isEqualToString:cd2.mark]
//                            &&[cd1.group isEqualToString:cd2.group])
                        {
                            needAdd = FALSE;
                        }
                    }
                    
                    if (needAdd)
                    {
                        card * cd = [[card alloc]init];
                        cd.createTime = cd1.createTime;
                        cd.headText = cd1.headText;
                        cd.detailText = cd1.detailText;
                        cd.mark = cd1.mark;
                        cd.groupName = cd1.groupName;
                        
                     //   [[card_manage card_mng] addGrp:cd];
                    }
                }
                
                self.icloudState = icloudInit;
            });
        }];
        
    });
}

@end
