//
//  cardGroupDisplayController.h
//  reciteHelper
//
//  Created by zhangliang on 2017/5/8.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cardGroupDisplayController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout>


@property(strong, nonatomic) NSMutableArray * grpArr;
@property(strong, nonatomic) UICollectionView * myCollectionView;
/* 从它进入一个viewController后，会将该值置位，等回到该视图，再负责将tabBar显示 */
@property(nonatomic) BOOL makeTabBarShowLater;

@end
