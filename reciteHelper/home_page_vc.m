//
//  home_page_vc.m
//  reciteHelper
//
//  Created by zhangliang on 2017/3/30.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "home_page_vc.h"
#import <WebKit/WebKit.h>

@interface home_page_vc ()

@end

@implementation home_page_vc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 添加 wkWewView 到自己的view 上*/
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]
                                              init];
    WKWebView * webView = [[WKWebView alloc] initWithFrame:[[UIScreen mainScreen]bounds] configuration: configuration];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://faded12.github.io/conversion/"]];
    
    [webView loadRequest: request];
    [self.view addSubview:webView];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate
{
    return NO;
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
