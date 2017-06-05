//
//  cardAddController.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/11.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "cardAddController.h"
#import "card_manage.h"

@interface cardAddController ()

@end

@implementation cardAddController

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
    self.detailText.layer.cornerRadius = 8;
    self.detailText.layer.masksToBounds = YES;
    
    /* 获取当前时间 */
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"yyyy年MM月dd日 hh时mm分ss秒"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    self.createTime = locationString;
    
    /* not show vertical scroll indicator */
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
    /* 这是新建页面，如果数据长度为0，那么不走后续的添加数据流程 */
    if (0 == self.headText.text.length)
    {
        return YES;
    }
    
    if (!self.backCard)
    {
        self.backCard = [[card alloc]init];
        
        self.backCard.createTime = self.createTime;
        /* 后面这两个数据为空，先添加 */
        self.backCard.headText = textField.text;
        self.backCard.detailText = @" ";
        
        NSLog(@"self.backCard.createTime ");
        
        [[card_manage card_mng] createNewCard:self.backCard toGrp:@"未归档"];
    }
    else{
        self.backCard.headText = textField.text;
    }
    
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
    
    /* 设置accessoryView : 在系统键盘上方添加一个小图标*/
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
    
    /* 这是新建页面，如果数据长度为0，那么不走后续的添加数据流程 */
    if (0 == self.detailText.text.length)
    {
        return ;
    }
    
    if (!self.backCard)
    {
        self.backCard = [[card alloc]init];
        
        self.backCard.createTime = self.createTime;
        self.backCard.headText = @" ";
        self.backCard.detailText = textView.text;
        
        [[card_manage card_mng] createNewCard:self.backCard toGrp:@"未归档"];
    }
    else{
        self.backCard.detailText = textView.text;
    }
    
    return ;
}


-(void )viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /* 进入该页面时隐藏tabBar */
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

/* 用户点击“分组”，退回到分组界面 */
-(void)exit_click
{
    [self.navigationController popViewControllerAnimated:self];
    
    /* 弹出该页面时显示tabBar */
    [[NSNotificationCenter defaultCenter]postNotificationName:@"betterShowTabBar" object:nil];

}

@end
