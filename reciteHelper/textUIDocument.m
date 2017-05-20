//
//  textUIDocument.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/20.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "textUIDocument.h"
#import "icloudManager.h"

@implementation textUIDocument

- (id)contentsForType:(NSString *)typeName
                error:(NSError * _Nullable *)outError
{
    /* 返回要存储的数据 : NSData */
    return [icloudManager icloud_mng].writeData;
}

- (BOOL)loadFromContents:(id)contents
                  ofType:(NSString *)typeName
                   error:(NSError * _Nullable *)outError
{
    [icloudManager icloud_mng].card_manage = [NSKeyedUnarchiver unarchiveObjectWithData: contents];

    return YES;
}


@end
