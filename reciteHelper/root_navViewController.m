//
//  root_navViewController.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/8.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "root_navViewController.h"
#import "profile_vc.h"

@interface root_navViewController ()

@end

@implementation root_navViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.x -= rect.size.width;
    
    profile_vc * profile = [[profile_vc alloc]init];
    profile.view.frame = rect;
    /* 设置背景颜色 */
    self.navigationBar.barTintColor = [UIColor colorWithRed:254.0/255 green:255.0/255 blue:254.0/255 alpha:1];
    /* 设置非透明 */
    self.navigationBar.translucent = NO;
    
    [self.view addSubview:profile.view];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* 优化点 ：1, 右滑有动画  ( 2，右滑之后可以通过左滑归位，而不是一定要点击 "我")*/
-(void)profile_click
{
    /* 标记当前是否已经偏移了 */
    static BOOL shift = FALSE;
    
    CGRect frame = self.view.frame;
    
    /* 未偏移则偏移 */
    if (!shift)
    {
        /* autoLayout attention : 注意这里的偏移数是写死的，真正使用autoLayout时不能这样 */
        /* 偏移，漏出profile view */
        frame.origin.x += 162;
        shift = TRUE;
    }/* 已偏移则归位 */
    else
    {
        /* autoLayout attention : 注意这里的偏移数是写死的，真正使用autoLayout时不能这样 */
        /* 偏移，漏出profile view */
        frame.origin.x -= 162;
        shift = FALSE;
    }
    self.view.frame = frame;
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
