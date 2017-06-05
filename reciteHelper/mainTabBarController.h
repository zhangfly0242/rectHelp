//
//  mainTabBarController.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/26.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cardEditController.h"
#import "card.h"

@interface mainTabBarController : UITabBarController <UITabBarControllerDelegate>

/* 返回自己的单例 */
+(instancetype) TABBAR;

@property(weak, nonatomic) cardEditController * current_cardEdit;
@property(weak, nonatomic) card * current_card;

/* 用户点击了某个卡片，将currentVC切换为最新的卡片 */
-(void) changeCurrentRectCardVC : (cardEditController *) new_cardEdit;

@end
