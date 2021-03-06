//
//  cellContentView.m
//  reciteHelper
//
//  Created by zhangliang on 2017/5/11.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "cellContentView.h"
#import "card_manage.h"
@implementation cellContentView

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
    
    textView.delegate = self;
}


/* 注册通知，随时显示和再次隐藏 */
-(void)configDeleteButton
{
    /* 接收通知，当点击“编辑”时，显示删除组的delete_button */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(click_edit) name:@"group_display_enter_edit" object: nil];
}

-(void)dismissKeyBoard
{
    [self.groupName resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.groupName resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text)
    self.backGroup.grpName = textView.text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/* 用户点击了一下“编辑”按钮 ，所有的cell都会出现 “删除”图标*/
-(void) click_edit
{
    /* 如果当前分组是"未归档"，或者"添加新组"，那么都不能删除，也不显示删除图标 */
    if ([self.backGroup.grpName isEqualToString:@"未归档"]
        || [self.backGroup.grpName isEqualToString:@"添加新组"])
    {
        return ;
    }
    
    if (self.hiddenDelete)
    {
        self.hiddenDelete = NO;
        self.delete_buttion.hidden = NO;
    }
    else{
        self.hiddenDelete = YES;
        self.delete_buttion.hidden = YES;
    }
}

- (IBAction)click_delete:(id)sender {
    [[card_manage card_mng] deleteGrp:self.backGroup];
}
@end
