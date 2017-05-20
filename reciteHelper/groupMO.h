//
//  groupMO.h
//  reciteHelper
//
//  Created by zhangliang on 2017/5/14.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "cardMO.h"

@interface groupMO : NSManagedObject

@property(nonatomic, strong) NSString * grpName;
@property(nonatomic, strong) NSMutableSet * relationCard;

@end
