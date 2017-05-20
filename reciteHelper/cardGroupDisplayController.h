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


@end
