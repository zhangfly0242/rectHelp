//
//  cardGroupDisplayController.m
//  reciteHelper
//
//  Created by zhangliang on 2017/5/8.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "cardGroupDisplayController.h"
#import "card_manage.h"
#import "cardGroup.h"
#import "cellContentView.h"
#import "home_page_tableViewController.h"

#define MAX_ITEM_NUM (2)
/* 当只有一个分组时，弹出键盘上移还有个问题，暂时去掉 */
#define NO_AUTO_UP_GROUP

@interface cardGroupDisplayController ()

@end

@implementation cardGroupDisplayController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.makeTabBarShowLater)
    {
        self.makeTabBarShowLater = NO;
        /* 弹出该页面时显示tabBar */
        [[NSNotificationCenter defaultCenter]postNotificationName:@"betterShowTabBar" object:nil];
    }
    
    UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
    flowLayout.headerReferenceSize = CGSizeMake(20, 40);
    /* 定制item的大小 */
    flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width/2 - 10,
                                     [UIScreen mainScreen].bounds.size.height/3);
    
    /* 创建collectionView */
    self.myCollectionView = [[UICollectionView alloc]
                             initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)
                             collectionViewLayout:flowLayout];
    
    /* 设置collectionView的背景颜色 */
    self.myCollectionView.backgroundColor = [UIColor lightGrayColor];
    
    /* 设置重用cell */
    [self.myCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myCell"];
    
    /* 设置dataSource,和delegate */
    self.myCollectionView.dataSource = self;
    self.myCollectionView.delegate = self;
    
    [self.view addSubview:self.myCollectionView];
    
#ifdef NO_AUTO_UP_GROUP
    
    
#else
    /* 监听键盘弹出 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    /* 监听键盘隐藏 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
#endif
    
}


- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSLog(@" keyboardWillShow1 self.myCollectionView %d", self.myCollectionView.scrollEnabled);

    /* 获取弹出的键盘的高度*/
    NSValue *aValue = [aNotification.userInfo valueForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGFloat height = [aValue CGRectValue].size.height;
    
    self.myCollectionView.contentOffset = CGPointMake(self.myCollectionView.contentOffset.x, self.myCollectionView.contentOffset.y + height/2);
    
    NSLog(@" keyboardWillShow2 self.myCollectionView %d", self.myCollectionView.scrollEnabled);
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    /* 获取弹出的键盘的高度*/
    NSValue *aValue = [aNotification.userInfo valueForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGFloat height = [aValue CGRectValue].size.height;
    
    self.myCollectionView.contentOffset = CGPointMake(self.myCollectionView.contentOffset.x, self.myCollectionView.contentOffset.y - height/2);
    NSLog(@" keyboardWillHide ");
}


/* 隐藏“电池栏” */
- (BOOL)prefersStatusBarHidden
{
    return YES; // 返回NO表示要显示，返回YES将hiden
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (0 == self.grpArr.count%MAX_ITEM_NUM)
    {
        return self.grpArr.count/MAX_ITEM_NUM;
    }
    else
    {
        return self.grpArr.count/MAX_ITEM_NUM + 1;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger sectionNum = 0;
    
    if (0 == self.grpArr.count%MAX_ITEM_NUM)
    {
        sectionNum = self.grpArr.count/MAX_ITEM_NUM;
    }
    else
    {
        sectionNum = self.grpArr.count/MAX_ITEM_NUM + 1;
    }
    
    /* 正好除尽，或者不是最后一行 , 则显示全部的item*/
    if ((0 == self.grpArr.count%MAX_ITEM_NUM)
        || (section != sectionNum - 1))
    {
       return MAX_ITEM_NUM;
    }
    else /*  最后一行 */
    {
        return self.grpArr.count%MAX_ITEM_NUM;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [self.myCollectionView dequeueReusableCellWithReuseIdentifier:@"myCell"
                                forIndexPath:indexPath];
    
    cellContentView * contentView = [cell viewWithTag:20];
    
    if (!contentView)
    {
        NSArray * arr = [[NSBundle mainBundle] loadNibNamed:@"cellContentView" owner:self options:nil];
        for (id view in arr)
        {
            if ([view isKindOfClass:[cellContentView class]])
            {
                contentView = view;
                break;
            }
        }
        
        contentView.frame = CGRectMake(0, 0, [cell frame].size.width, [cell frame].size.height);
        /* 附在cell上的contentView的tag是20，方便后续访问cell上的contentView */
        contentView.tag = 20;
        [contentView configDeleteButton];

        /* 在contView上添加tap手势，因为contentView上的textView设置的是不可点击，使得点击textView上没有效果 */
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTap:)];
        [contentView addGestureRecognizer:tapGes];
        
        [cell addSubview:contentView];
    }
    
    /* 重设隐藏按钮 */
    contentView.hiddenDelete = YES;
    contentView.delete_buttion.hidden = YES;
    
    /* 获得对应数据 */
    NSInteger index = indexPath.row + indexPath.section * MAX_ITEM_NUM;

    cardGroup * grp = self.grpArr[index];
    
    contentView.groupName.text = grp.grpName;
    contentView.backGroup = grp;

    /* 可操作 */
    if (grp.operation)
    {
        contentView.countDescription.text = [[NSString alloc]initWithFormat:@"%lu张卡片", (unsigned long)grp.cardArr.count];
        /* 组名暂时不可更改 */
        contentView.groupName.editable  = NO;
    }
    else
    {
        contentView.countDescription.text = @"新分组";
        [contentView setTextViewKeyBoard:contentView.groupName];
        /* 组名可以更改 */
        contentView.groupName.editable  = YES;
    }
    contentView.countDescription.editable = FALSE;
    
    /* 可选 : 设置cell外观 : 圆角 */
    cell.layer.cornerRadius = 8;
    cell.layer.masksToBounds = YES;
    
    return cell;
}

/* 用户在cellContentView上点击了（由于cellContentView上两个占大块面积的textView设置的是不可编辑，所以应该是直接忽略了点击事件，并不往响应者链后传->UICollectionViewCell） */
-(void)handelTap:(UITapGestureRecognizer *)gestureRecognizer{
        UICollectionViewCell * cell = (UICollectionViewCell *)[gestureRecognizer.view superview];
    
        NSIndexPath * path = [self.myCollectionView indexPathForCell:cell];
        [self collectionView:self.myCollectionView didSelectItemAtIndexPath:path];
    
        [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];//双击事件取消延时
 }

//
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionReusableView * suppleView = collectionView dequeueReusableSupplementaryViewOfKind:@"" withReuseIdentifier:<#(nonnull NSString *)#> forIndexPath:<#(nonnull NSIndexPath *)#>
//    suppleView.backgroundColor = [UIColor blueColor];
//    return suppleView;
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}

-(void) kvoHandleGrpAddDelete:(NSDictionary *)change KeyPath:(NSString *)keyPath
{
    cardGroup * grp = nil;
    
    /* 发生了添加组事件 */
    if ([keyPath isEqualToString:@"addGrp"])
    {
        grp = [change valueForKey:@"new"];
        [self.grpArr addObject: grp];
        [self observeOneGrp:grp];
        
        NSIndexPath * newPath = [self locationToIndex:self.grpArr.count - 1];
        
        /* 新加的这个导致换行，即导致section增加了 */
        if (0 == newPath.item)
        {
            [self.myCollectionView reloadData];
            /* zhang-attention : 下面的方法不行, 会挂起，在网上查了下，好像是好几个人都遇到了，没有看到整体的解决方法 */
            //[self.myCollectionView insertSections:[NSIndexSet indexSetWithIndex: newPath.section]];
        }
        else
        {
            [self.myCollectionView reloadData];
            /* zhang-attention : 下面的方法不行, 偶尔会挂起，打印:
             [UICollectionView _endItemAnimationsWithInvalidationContext:tentativelyForReordering:animator:], /BuildRoot/Library/Caches/com.apple.xbs/Sources/UIKit/UIKit-3600.7.47/UICollectionView.m:5781*/
           // [self.myCollectionView insertItemsAtIndexPaths:[NSArray arrayWithObjects:newPath , nil]];
        }
        
    }/* 发生了删除组事件 */
    else if ([keyPath isEqualToString:@"deleteGrp"])
    {
        cardGroup * deleteGrp = [change valueForKey:@"new"];
        /* 取消对该分组的关注 */
        [self unObserveOneGrp:deleteGrp];
        /* 从自身结构中删除 */
        [self.grpArr removeObject: [change valueForKey:@"new"]];
        /* 更新页面 */
        [self.myCollectionView reloadData];
    }/* 组内其它变化 */
    else
    {
        NSLog(@" ERROR : %s unknown change %@",__FUNCTION__, change);
    }

    return ;
}


/* 组自身的变化的处理：组名字变化，或可操作标记发生变化，或卡片个数发生了变化 */
-(void) kvoHandleGrpChange: (cardGroup *)grp change:(NSDictionary *)change KeyPath:(NSString *)keyPath
{
    /* 表明是第几个组 */
    NSInteger location = [self.grpArr indexOfObject:grp];
    
    NSIndexPath * path = [self locationToIndex:location];
    
    /* 获得该组对应的cell */
    UICollectionViewCell * cell = [self.myCollectionView cellForItemAtIndexPath:path];
    if (!cell)
    {
        return ;
    }
    
    /* 获得cell上的contentView*/
    cellContentView * contentView = [cell viewWithTag:20];

    /* 如果此时cell没有加载，那么它上面的contentView是nil的, 此时不需要进行后续的三个处理，到时显示时会直接获取最新的*/
    if (!contentView)
    {
        NSLog(@" ERROR : %s ,RETURN ",__FUNCTION__);
        return ;
    }
    
    /* 组名变化 */
    if ([keyPath isEqualToString:@"grpName"])
    {
        contentView.groupName.text = grp.grpName;
    }/* 组的属性变化 */
    else if ([keyPath isEqualToString:@"operation"])
    {
        /* 修改组的描述 */
        contentView.countDescription.text = [[NSString alloc]initWithFormat:@"%lu张卡片", (unsigned long)grp.cardArr.count];
        /* 组名暂时不可更改 */
        contentView.groupName.editable = NO;
//        
//        /* 注册通知，根据情况显示或隐藏删除按钮 */
//        [contentView configDeleteButton];
    }/* 组内卡片个数发生变化 */
    else if ([keyPath isEqualToString:@"cardArr"])
    {
        /* 不需要特殊处理，直接reload即可 */
        contentView.countDescription.text = [[NSString alloc]initWithFormat:@"%lu张卡片", (unsigned long)grp.cardArr.count];
    }
    else
    {
        NSLog(@" ERROR : %s  unknown keypath %@",__FUNCTION__, keyPath);
    }
    
    return ;
}

/* 监听总数据的变化 , 先判断是发生了数量增加还是数量减少，然后相应地增加或删除本地数据*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    /* 组发生变化, 可能是组名发生变化，也可能是组的内卡片增多或者减少 */
    if ([object isKindOfClass:[cardGroup class]])
    {
        [self kvoHandleGrpChange: object change: change KeyPath: keyPath];
    }/* 组的整体个数发生变化 */
    else if ([object isKindOfClass:[card_manage class]]){
        [self kvoHandleGrpAddDelete: change KeyPath: keyPath];
    }
    else{
        NSLog(@"ERROR : %s , unknown type object %@ keyPaht %@",__FUNCTION__,
              object, keyPath);
    }
    
    return ;
}



-(instancetype)init
{
    self = [super init];

    self.grpArr = [[NSMutableArray alloc]init];
    for (cardGroup * grp in [card_manage card_mng].array)
    {
        NSLog(@" addgrp %@",grp.grpName);
        [self.grpArr addObject:grp];
        [self observeOneGrp:grp];
    }
    
    /* 监听分组整体个数的变化, 更新界面 */
    [[card_manage card_mng] addObserver:self
         forKeyPath:@"addGrp"
            options:NSKeyValueObservingOptionNew
            context:nil];
    
    /* 监听分组整体个数的变化, 更新界面 */
    [[card_manage card_mng] addObserver:self
          forKeyPath:@"deleteGrp"
             options:NSKeyValueObservingOptionNew
             context:nil];
    
    /* zhang-attention : 创建右上角的编辑button  */
    UIBarButtonItem * addBar = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit_click)];
    
    self.navigationItem.rightBarButtonItems = @[addBar];

    return self;
}

-(void) observeOneGrp: (cardGroup *)grp
{
    /* 监听 每一个card ，发生变化，则更新界面 */
    [grp addObserver:self
         forKeyPath:@"grpName"
            options:NSKeyValueObservingOptionNew
            context:nil];
    
    [grp addObserver:self
          forKeyPath:@"operation"
             options:NSKeyValueObservingOptionNew
             context:nil];
    
    [grp addObserver:self
         forKeyPath:@"cardArr"
            options:NSKeyValueObservingOptionNew
            context:nil];
}

-(void)unObserveOneGrp: (cardGroup *)grp
{
    /* zhang-attention : 对象被删除，需要移除观察者 */
    [grp removeObserver:self forKeyPath:@"grpName"];
    [grp removeObserver:self forKeyPath:@"operation"];
    [grp removeObserver:self forKeyPath:@"cardArr"];
}

/* 根据在数组中的下标location，返回在collectionView中的index */
-(NSIndexPath *) locationToIndex: (NSInteger) location
{
    NSInteger section = 0;
    NSInteger item = 0;
    
    location++;
    
    if (location < MAX_ITEM_NUM)
    {
        section = 0;
        item = location - 1;
    }
    else if(0 == location%MAX_ITEM_NUM)
    {
        section = location/MAX_ITEM_NUM - 1;
        item = MAX_ITEM_NUM - 1;
    }
    else
    {
        section = location/MAX_ITEM_NUM;
        item = location%MAX_ITEM_NUM - 1;
    }
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    /* 获得点击的cell */
    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    /* 获得cell上的contentView*/
    cellContentView * contentView = [cell viewWithTag:20];
    
    /* 如果此时cell没有加载，那么它上面的contentView是nil的, 此时不需要进行后续的三个处理，到时显示时会直接获取最新的*/
    if (!contentView)
    {
        NSLog(@" ERROR : %s ,RETURN ",__FUNCTION__);
        return ;
    }
    
    NSMutableArray * arr = [[NSMutableArray alloc]init];
    [arr addObject:contentView.backGroup];
    
    home_page_tableViewController * list_table = [[home_page_tableViewController alloc]initWithData:arr grpName: contentView.backGroup.grpName];
    
    [self.navigationController pushViewController:list_table animated:YES];
    
    /* 随后负责显示该tabBar */
    self.makeTabBarShowLater = YES;
    /* 隐藏tabBar */
     [[NSNotificationCenter defaultCenter]postNotificationName:@"betterHiddenTabBar" object:nil];
    return;
}

/* 用户点击了 “编辑” 按钮 */
-(void)edit_click
{
#ifdef NO_AUTO_UP_GROUP
    
#else
    /* 发送通知，使得所有的cell进入编辑状态 */
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"group_display_enter_edit" object:nil]];
#endif
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
#if 0
    UINavigationController * nav = self.tabBarController.selectedViewController;
    NSLog(@" vie will disappear  %@", [self.tabBarController.selectedViewController class]);
    if (self.navigationController == nav)
    {
        NSLog(@" vie will disappear 1");
        /* 弹出该页面时隐藏tabBar */
        [[NSNotificationCenter defaultCenter]postNotificationName:@"betterHiddenTabBar" object:nil];
    }
#endif
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
