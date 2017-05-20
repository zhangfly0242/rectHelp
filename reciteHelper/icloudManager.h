//
//  icloudManager.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/19.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "textUIDocument.h"
#import "card_manage.h"

@interface icloudManager : NSObject

@property(nonatomic, strong) id currentiCloudToken;

@property(nonatomic, strong) textUIDocument * document;
@property(nonatomic, strong) NSString * stringWaitSave;
@property(nonatomic, strong) NSString * readFreshData;

@property(nonatomic, strong) NSData * writeData;
@property(nonatomic, strong) card_manage * card_manage;
@property(nonatomic) NSInteger icloudState;

/* 返回自己的单例 */
+(instancetype) icloud_mng;


-(void) saveToIcloud: (id) kindOfData;
-(void) readFromIcloud;

@end
