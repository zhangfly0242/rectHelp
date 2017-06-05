//
//  mainTabBarController.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/26.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "mainTabBarController.h"
#import "root_navViewController.h"
#import "home_page_tableViewController.h"
#import "cardSquareController.h"
#import "cardGroupDisplayController.h"
#import "test1ViewController.h"
#import "cardAddController.h"
#import "card_manage.h"
#import "cardEditController.h"
#import "test1ViewController.h"
#import "profile_vc.h"
#import "AppDelegate.h"
#import "card.h"

/* 显示最近页面 */
#define NO_SHOW_CURRENT_CARD

@interface mainTabBarController ()

@end

@implementation mainTabBarController

/* 将图片缩小到tabBar的大小范围内 */
-(UIImage *) scaleImgeFitTabBar: (UIImage *) originImg
{
    CGSize size = CGSizeMake(self.tabBar.frame.size.height, self.tabBar.frame.size.height);
    
    NSLog(@" size %f %f",size.height,size.width);
    
    UIGraphicsBeginImageContext(size);
    [originImg drawInRect:CGRectMake(0, 0, size.height, size.height)];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

/* 系统刚来时，获取当前背诵的卡片，默认是第一张 */
-(cardEditController *) getCurrentRectCardVC
{
    NSMutableArray * arr = [card_manage card_mng].array;
    
    cardEditController * cardEdit = [[cardEditController alloc]init];
    /* 默认获取分组的第一个卡片 */
    if (arr.count > 0)
    {
        for (cardGroup * grp in arr)
        {
            if (grp.cardArr.count > 0)
            {
                card * card = grp.cardArr[0];
                self.current_card = card;
                cardEdit.backCard = card;
        
                /* 不隐藏tabBar */
                cardEdit.shouldShowTabBar = YES;
                return cardEdit;
            }
        }
    }
    
    return nil;
}

-(void) initWithTabBar
{
    /* “卡片列表”视图 */
    home_page_tableViewController * home_table = [[home_page_tableViewController alloc]initWithData: [card_manage card_mng].array grpName:ALL_GROUP];
    
    UIImage * img1 = [UIImage imageNamed:@"home_list.jpg"];
    img1 = [UIImage imageWithCGImage:img1.CGImage scale:1.88 orientation:UIImageOrientationUp];
    
    UIImage * img1_1 = [UIImage imageNamed:@"home_list_selected.jpg"];
    img1_1 = [UIImage imageWithCGImage:img1_1.CGImage scale:1.88 orientation:UIImageOrientationUp];
    
    /* 设置tabBarItem套路一 : 必须要设置这个，否则显示tabBar显示的是一个色块 */
    img1 = [img1 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    img1_1 = [img1_1 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    
    /* 设置tabBarItem套路二，创建barItem，注意这里不设置名字，因为后续会偏移barItem中的img，但无法偏移这里的名字。
     (所以这里不要显示名字，这样就不会有img偏移，文字不偏移的问题了。实际上点击barItem的时候，就是要点击img所在的位置的, 所以偏移的是img，从效果上(外观以及点击)完全可以认为是在偏移barItem)*/
    UITabBarItem * barItem1 = [[UITabBarItem alloc] initWithTitle:@" " image:img1 selectedImage:img1_1];

    /* 设置tabBarItem套路三，设置barItem 的位置 , 这会在barItem layout时对其偏移其frame
     （注意设置的值要对称 上左下右中，上和下的值要一样，左和右要一样, 否则会有问题，试验了确实有问题）*/
    barItem1.imageInsets = UIEdgeInsetsMake(5, -2, -5, 2);
    
    /* 设置tabBarItem套路四， 设置barItem 的大小: 大小和barItem创建时使用的img一样*/
    //略
    
    /* 设置tabBarItem套路五， 设置barItem 的的位置，即互相之间的间隔:
     self.tabBar.itemPositioning = UITabBarItemPositioningCentered;
    self.tabBar.itemSpacing = 3;
     具体可以参见 viewDidLoad 对这两个值的设置和解释
    */
    
    /* tableViewController 要承载在navigationcontroller里面 */
    root_navViewController * root_nav = [[root_navViewController alloc]init];
    [root_nav pushViewController:home_table animated:NO];
    root_nav.tabBarItem = barItem1;
    
    /* “卡片组”视图 */
    cardGroupDisplayController * cardGroup = [[cardGroupDisplayController alloc]init];
    
    UIImage * img2 = [UIImage imageNamed:@"classify_card.jpg"];
    img2 = [UIImage imageWithCGImage:img2.CGImage scale:1.88 orientation:UIImageOrientationUp];
    img2 = [img2 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage * img2_2 = [UIImage imageNamed:@"classify_card_selected.jpg"];
    img2_2 = [UIImage imageWithCGImage:img2_2.CGImage scale:1.88 orientation:UIImageOrientationUp];
    img2_2 = [img2_2 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UITabBarItem * barItem2 = [[UITabBarItem alloc] initWithTitle:@" " image:img2 selectedImage:img2_2];

    barItem2.imageInsets = UIEdgeInsetsMake(5, -1, -5, 1);
    
    /* 创建navcontroller */
    UINavigationController * groupNavController = [[UINavigationController alloc]initWithRootViewController:cardGroup];
    groupNavController.tabBarItem = barItem2;
    /* zhang-attention : 套路 ：注意设置navigation bar非透明 ，否则默认会自动让navigation bar遮住中的视图，这往往不是想要的效果*/
    groupNavController.navigationBar.translucent = NO;
    
    /* 没有图标，另外没有进行存储，最后，界面也不好，先放弃 */
#ifdef NO_SHOW_CURRENT_CARD
    /* “最近”视图 */
    cardEditController * latest = nil;
    latest = [self getCurrentRectCardVC];
    /* 最近一次查看的是空，比如刚下载app，第一次启动时 */
    if (!latest)
    {
        NSLog(@"latest is nil");
        latest = (cardEditController *)[[UIViewController alloc]init];
    }
    
    UIImage * img3 = [UIImage imageNamed:@"current_recite.png"];
    img3 = [UIImage imageWithCGImage:img3.CGImage scale:1.88 orientation:UIImageOrientationUp];
    img3 = [img3 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIImage * img3_2 = [UIImage imageNamed:@"current_recite_selsect.png"];
    img3_2 = [UIImage imageWithCGImage:img3_2.CGImage scale:1.88 orientation:UIImageOrientationUp];
    img3_2 = [img3_2 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UITabBarItem * barItem3 = [[UITabBarItem alloc] initWithTitle:@" " image:img3 selectedImage:img3_2];

    barItem3.imageInsets = UIEdgeInsetsMake(5, 1, -5, -1);
    UINavigationController * nav3 = [[UINavigationController alloc]initWithRootViewController:latest];
    nav3.tabBarItem = barItem3;
    nav3.navigationBar.translucent = NO;
#endif
    
    /* “我的”视图 */
    profile_vc * aboutMe = [[profile_vc alloc]init];
    
    UIImage * img4 = [UIImage imageNamed:@"persion_info.jpg"];
    img4 = [UIImage imageWithCGImage:img4.CGImage scale:1.88 orientation:UIImageOrientationUp];
    img4 = [img4 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    
    UIImage * img4_2 = [UIImage imageNamed:@"persion_info_selected.jpg"];
    img4_2 = [UIImage imageWithCGImage:img4_2.CGImage scale:1.88 orientation:UIImageOrientationUp];
    img4_2 = [img4_2 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UITabBarItem * barItem4 = [[UITabBarItem alloc] initWithTitle:@" " image:img4 selectedImage:img4_2];
    
    barItem4.imageInsets = UIEdgeInsetsMake(5, 2, -5, -2);
    
    root_navViewController * aboutMeNav = [[root_navViewController alloc]init];
    [aboutMeNav pushViewController:aboutMe animated:NO];
    aboutMeNav.tabBarItem = barItem4;
    
#ifdef NO_SHOW_CURRENT_CARD
    NSArray * array = @[root_nav, groupNavController, aboutMeNav];
#else
    NSArray * array = @[root_nav, groupNavController, nav3, aboutMeNav];
#endif
    self.viewControllers = array;
}

/* 返回自己的单例 */
+(instancetype) TABBAR
{
    static mainTabBarController * it_self = nil;
    if (!it_self)
    {
        it_self = [[mainTabBarController alloc]init];
        it_self.delegate = it_self;
        [it_self initWithTabBar];
        
        [[NSNotificationCenter defaultCenter]addObserver:it_self selector:@selector(hiddenTabBar) name:@"betterHiddenTabBar" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:it_self selector:@selector(showTabBar) name:@"betterShowTabBar" object:nil];
    }
    
    return it_self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 一 ：tabBar外观定制 ： 注意 tabBar 的背景颜色设置不能通过 background来做，其会忽略该值，要通过barTintColor来设置。用处 ：设置这个颜色可以和barItem图片颜色一样，使得融为一体 */
    //self.tabBar.barTintColor = [UIColor grayColor];
    
    /* 获取任意颜色的UIColor ：先用取色器工具取出想要颜色的rgb数值，得到98D0B0 ，对应值为152，208，176，然后传入参数时记得传入.0(必须要带.0，否则除了后的结果没有小小数部分，只有0！)并除以255即可。*/
    self.tabBar.barTintColor = [UIColor colorWithRed:254.0/255 green:255.0/255 blue:254.0/255 alpha:1];
    
    self.tabBar.translucent = NO;
    self.tabBar.barStyle = UIBarStyleBlack;
    self.tabBar.alpha = 1.0;
    
    /* 套路 ：设置了tabBar的颜色，就必须同时设置非透明，这样可以避免受后面内容颜色的影响。
    //  self.tabBar.translucent = NO;
     (设置translucent = NO后，就不能通过tabBar = hidden 来隐藏tabBar（app的bug），可以通过
     hidesBottomBarWhenPushed = TRUE 来做)*/
    
    /* 二 ：tabBar外观定制 : 隐藏 tabBar 。用处 ：当进入某个特别的页面时，可能需要隐藏.
      隐藏tabBar的做法，有个细节要注意。如果设置tabBar的颜色为非透明时使用tabBar.translucent = NO ，则不能设置 self.tabBar.hidden = YES; 来隐藏tabBar
        
        通过如下方式来实现隐藏tabBar样做: addViewController.hidesBottomBarWhenPushed = YES;  （搜索关键字hidesBottomBarWhenPushed用的） 
     */
    
    /* 三 ：tabBar中barItem位置定制 : 
     
        方法一 ：请见didFinishLaunchingWithOptions中各个viewController中对tabBarItem的设置 。
    
        方法二:
     a, 设置barItem的间隔(即位置)一，指定 position 类型 为UITabBarItemPositioningCentered*/
        self.tabBar.itemPositioning = UITabBarItemPositioningCentered;
    /* b, 设置barItem的间隔(即位置)二，设定itemSpacing的值 (大于0，但如果barItem太多了，
         这里就不能太大，否则会认为无法塞下那么多barItem同时使得间隔那么大，就会忽略你这里的间隔设置)*/
    self.tabBar.itemSpacing = 3;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController
{
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController
{
    return ;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIView * view = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    view.backgroundColor = [UIColor grayColor];
    //[self.tabBar addSubview:view];
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(void) hiddenTabBar
{
    self.tabBar.translucent = YES;
    
    [UIView animateWithDuration:0.6 animations:^{
            self.tabBar.alpha = 0.0;
    }];

    return;
}

-(void) showTabBar
{
    self.tabBar.translucent = NO;
    self.tabBar.alpha = 1.0;
    return ;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
#ifdef NO_SHOW_CURRENT_CARD
    /* 目前没有第三个“正在背诵” 界面，先直接返回*/
    return;
#else
    NSLog(@" didSelectItem 1 current_cardEdit %@ %p", self.current_cardEdit, self.current_cardEdit);
    /* 用户点击了某个卡片，将currentVC切换为最新的卡片 */

    if (tabBar.items[2] == item)
    {
        NSLog(@" didSelectItem 2 ");
        
        UINavigationController * current_vc_nav = self.viewControllers[2];
      //  [current_vc_nav popViewControllerAnimated:NO];
        
        cardEditController * new_cardEdit = [[cardEditController alloc]init];
        new_cardEdit.backCard = self.current_card;
        
        [current_vc_nav setViewControllers:@[new_cardEdit] animated:NO];
      //  [current_vc_nav pushViewController:new_cardEdit animated:NO];
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
