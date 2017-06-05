//
//  profile_vc.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/8.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "profile_vc.h"
#import "icloudManager.h"
#import <WebKit/WebKit.h>

@interface profile_vc ()

@end

@implementation profile_vc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
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

- (IBAction)click_use_statement:(id)sender {
    UIViewController * webVC = [[UIViewController alloc]init];
    [self.navigationController pushViewController:webVC animated:YES];
    
    WKWebView * webView = [[WKWebView alloc]initWithFrame:webVC.view.bounds];
    [webVC.view addSubview:webView];
    NSURLRequest * req = [NSURLRequest requestWithURL: [NSURL URLWithString: @"https://faded12.github.io/declare/"]];
    [webView loadRequest: req];
}

- (IBAction)clieck_privacy_statement:(id)sender {
    
    UIViewController * webVC = [[UIViewController alloc]init];
    [self.navigationController pushViewController:webVC animated:YES];
    
    WKWebView * webView = [[WKWebView alloc]initWithFrame:webVC.view.bounds];
    [webVC.view addSubview:webView];
    NSURLRequest * req = [NSURLRequest requestWithURL: [NSURL URLWithString: @"https://faded12.github.io/provision/"]];
    [webView loadRequest: req];
}
@end
