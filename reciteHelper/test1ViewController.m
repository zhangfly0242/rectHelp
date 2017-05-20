//
//  test1ViewController.m
//  reciteHelper
//
//  Created by zhangliang on 2017/5/15.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "test1ViewController.h"

@interface test1ViewController ()

@end

@implementation test1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


/* 返回自己的单例 */
+(instancetype) itSelf
{
    static test1ViewController * it_self = nil;
    if (!it_self)
    {
        it_self = [[test1ViewController alloc] init];
        /*  */
        it_self.view.backgroundColor = [UIColor grayColor];
    }
    
    return it_self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
