//
//  cardInfoController.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/8.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "cardInfoController.h"
#import "card.h"

@interface cardInfoController ()

@end

@implementation cardInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    /* 将 textFiled的 代理设置自己，这样当点击输入键盘的确定时，会通知到方法
     textFieldShouldReturn，在textFieldShouldReturn中调用resignFirstResponder实现取消键盘*/
    self.headText.delegate = self;
    self.detailText.delegate = self;
    //UIReturnKeyDone
    /* 定制键盘的 return 显示类型，是“返回”，还是“搜索” */
    self.headText.returnKeyType = UIReturnKeyDone;
    /* 定制键盘的 return 显示类型，是“返回”，还是“搜索” */
    self.detailText.returnKeyType = UIReturnKeyNext;
    
    /* uiTextView的键盘设置通用方法(在弹出的小键盘上增加一个done按钮的) */
    [self setTextViewKeyBoard:self.detailText];
    
    /* 可选 : 设置UITextView外观 : 圆角 */
    self.detailText.layer.cornerRadius = 1;
    self.detailText.layer.masksToBounds = YES;
    
    self.createTime.text = self.backCard.createTime;
    self.headText.text = self.backCard.headText;
    self.detailText.text = self.backCard.detailText;
    
    /* 隐藏 scroll indicator */
    self.detailText.showsVerticalScrollIndicator = NO;
    
    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* 用户点击return时，uiTextFiled会调用这个代理方法 ，之前已经将代理设置为这个了，在这里实现点击return，取消输入框*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.headText resignFirstResponder];
    return YES;
}

/* 和上面的方法有什么区别 ? */
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.headText.text = textField.text;
    self.backCard.headText = textField.text;

    return YES;
}

/* 定制UITextView的键盘的固定做法 */
-(void) setTextViewKeyBoard : (UITextView * ) textView
{
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissKeyBoard)];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView setItems:buttonsArray];
    
    /* 设置accessoryView */
    [textView setInputAccessoryView:topView];
}

-(void)dismissKeyBoard
{
    [self.detailText resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.detailText resignFirstResponder];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.detailText.text = textView.text;
    self.backCard.detailText = textView.text;
    return ;
}



-(void )viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /* 弹出该页面时隐藏tabBar */
    [[NSNotificationCenter defaultCenter]postNotificationName:@"betterHiddenTabBar" object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    /* 弹出该页面时显示tabBar */
    [[NSNotificationCenter defaultCenter]postNotificationName:@"betterShowTabBar" object:nil];
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
