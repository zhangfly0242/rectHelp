//
//  AppDelegate.h
//  reciteHelper
//
//  Created by zhangliang on 2017/3/30.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "cardEditController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;
/* 显示当前正在背的卡片，系统一起来时，默认背的是第一张卡片 */
@property (strong, nonatomic) cardEditController * currentRectCard;

- (void)saveContext;


@end

