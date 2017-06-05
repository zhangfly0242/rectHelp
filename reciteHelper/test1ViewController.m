//
//  test1ViewController.m
//  reciteHelper
//
//  Created by zhangliang on 2017/5/15.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "test1ViewController.h"
#import "testView.h"

@interface test1ViewController ()

@end

@implementation test1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    testView * view = [[testView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillLayoutSubviews
{
    NSLog(@" table list : viewWillLayoutSubviews");
    [super viewWillLayoutSubviews];
}

-(void) viewDidLayoutSubviews
{
    NSLog(@" table list : viewDidLayoutSubviews");
    [super viewDidLayoutSubviews];
}


-(void )viewWillAppear:(BOOL)animated
{
    NSLog(@" table list : viewWillAppear");
    [super viewWillAppear:animated];
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self
                                                    selector:@selector(layout_its_subviews) userInfo:nil repeats:true];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@" table list : viewDidAppear");
    [super viewDidAppear:animated];
    
    return ;
}


-(void) layout_its_subviews
{
    NSLog(@" setNeedsLayout");
    [self.view setNeedsLayout];
    //[self.view setNeedsDisplay];
}

/* 返回自己的单例 */
+(instancetype) itSelf
{
    static test1ViewController * it_self = nil;
    if (!it_self)
    {
        it_self = [[test1ViewController alloc] init];
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
