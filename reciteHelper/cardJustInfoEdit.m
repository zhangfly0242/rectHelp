//
//  cardJustInfoEdit.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/30.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "cardJustInfoEdit.h"

@implementation cardJustInfoEdit

-(void) configWithTag :(NSInteger) tag backCard: (card *) backCard size: (CGSize) size
{
    if ((10 != tag) && (11 != tag) && (12 != tag))
    {
        NSLog(@" Error, %s unknown tag %ld ",__FUNCTION__, tag);
    }
    
    self.tag = tag;
    self.backCard = backCard;
    
    /* 设置frame */
    [self setItsFrame : size];
    
    //if (10 == self.tag)
    /* 设置内容 这个操作比较耗时*/
   // [self setItsContent];
    
    /* masksToBounds属性关掉，因为阴影设置的方式就是加offset给超出视图部分设置颜色来实现的，一旦不让子视图超出，阴影也就看不出了 */
    self.layer.masksToBounds = NO;
    
    /* 设置键盘，以及实现代理方法(保存数据，以及隐藏键盘) */
    [self setTextViewKeyBoard : self.content];
    
    /* 通过kvo监听 self.backCard.detailText */
    /* 监听数据的变化 */
    [backCard addObserver:self
               forKeyPath:@"headText"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    
    /* 监听数据的变化 */
    [backCard addObserver:self
         forKeyPath:@"detailText"
            options:NSKeyValueObservingOptionNew
            context:nil];
    
    /* “模式一” 和 “模式二” 都不可以编辑, 这样只有“原文"才会涉及取消键盘时，保存内容的处理，然后触发kvo*/
    if ((11 == self.tag) || (12 == self.tag))
    {
        self.content.editable = NO;
    }
        
    return ;
}

-(void) setItsFrame : (CGSize) size
{
    CGFloat origin_x = 0;
    
    /* tag值， 10表示“原文”的view，11表示“模式一*的view，12表示“模式二”的view */
    if (10 == self.tag)
    {
        origin_x = 0;
    }
    else if (11 == self.tag)
    {
        origin_x = size.width;
    }
    else if (12 == self.tag)
    {
        origin_x = size.width * 2;
    }
    else
    {
        NSLog(@"Error , unknown tag %ld",(long)self.tag);
        return ;
    }
    
    /* 设置frame*/
    CGRect frame = CGRectMake(origin_x, 0, size.width, size.height);
    self.frame = frame;
    
}

/* 设置“原文”， “模式一”，“模式二” 的内容*/
-(void) setItsContent
{
    NSRange range;
    NSUInteger i = 0;
    NSString * str1 = self.backCard.detailText;
    NSString * str2 = self.backCard.detailText;
    BOOL handle = FALSE;
    NSInteger jump_count = 0;
    
    for (i = 0; i <= self.backCard.detailText.length - 1; i++)
    {
        range.length = 1;
        range.location = i;
        
        if ([self special_str_no_handle: [self.backCard.detailText substringWithRange:range]])
        {
            continue;
        }
        
        
        if (jump_count < 2)
        {
            jump_count++;
            continue;
        }
        else{
            jump_count = 0;
            range.length = 1;
            range.location = i;
            str1 = [str1 stringByReplacingCharactersInRange:range withString:@"x"];
        }
        
#if 0
        if (handle)
        {
            range.length = 1;
            range.location = i;
            str1 = [str1 stringByReplacingCharactersInRange:range withString:@"x"];
            handle = FALSE;
        }
        else
        {
            handle = TRUE;
        }
#endif
    }
    
    handle = FALSE;
    for (i = 1; i <= self.backCard.detailText.length - 1; i++)
    {
        range.length = 1;
        range.location = i;
        
        if ([self special_str_no_handle: [self.backCard.detailText substringWithRange:range]])
        {
            continue;
        }
        
        if (jump_count < 2)
        {
            jump_count++;
            continue;
        }
        else{
            jump_count = 0;
            range.length = 1;
            range.location = i;
            str1 = [str1 stringByReplacingCharactersInRange:range withString:@"x"];
        }
        
#if 0
        if (handle)
        {
            range.length = 1;
            range.location = i;
            str2 = [str2 stringByReplacingCharactersInRange:range withString:@"x"];
            handle = FALSE;
        }
        else
        {
            handle = TRUE;
        }
#endif
    }

    if (10 == self.tag)
    {
        if (![self.content.text isEqualToString:self.backCard.detailText])
        {
            self.content.text = self.backCard.detailText;
        }
    }
    else if (11 == self.tag)
    {
        if (![self.content.text isEqualToString: str1])
        {
            self.content.text = str1;
        }
    }
    else if (12 == self.tag)
    {
        if (![self.content.text isEqualToString: str2])
        {
            self.content.text = str2;
        }
    }
    
    return;
}


/* KVO function， 只要object的keyPath属性发生变化，就会调用此函数*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass: [card class]])
    {
        /* 更新它的内容 */
        [self setItsContent];
    }
    else{
    }
    
    return ;
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
    
    textView.delegate = self;
}

-(void)dismissKeyBoard
{
    [self.content resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.content resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self contentViewDidEndEditing : textView];
}

/* contentView结束编辑 ， 保存文本*/
- (void)contentViewDidEndEditing : (UITextView *) textView
{
    self.content.text = textView.text;
    self.backCard.detailText = textView.text;
    
    return ;
}

/* 扣空的处理中，这些符号, 空格，逗号，换行等不能被扣掉 */
-(BOOL) special_str_no_handle : (NSString *) str
{
    if ([str isEqualToString:@" "] || [str isEqualToString:@" "])
    {
        return TRUE;
    }
    else{
     
    }
    
    if ([str isEqualToString:@","] || [str isEqualToString:@"，"])
    {
        return TRUE;
    }
    
    if ([str isEqualToString:@";"] || [str isEqualToString:@"；"])
    {
        return TRUE;
    }
    
    if ([str isEqualToString:@"."] || [str isEqualToString:@"。"])
    {
        return TRUE;
    }
    
    if ([str isEqualToString:@"?"] || [str isEqualToString:@"？"])
    {
        return TRUE;
    }
    
    if ([str isEqualToString:@"!"] || [str isEqualToString:@"！"])
    {
        return TRUE;
    }
    
    if ([str isEqualToString:@":"] || [str isEqualToString:@"："])
    {
        return TRUE;
    }
    
    if ([str isEqualToString:@"<"] || [str isEqualToString:@"《"])
    {
        return TRUE;
    }
    
    if ([str isEqualToString:@">"] || [str isEqualToString:@"》"])
    {
        return TRUE;
    }
    
    /* 单引号 */
    if ([str isEqualToString:@"'"] || [str isEqualToString:@"‘"] || [str isEqualToString:@"’"])
    {
        return TRUE;
    }
    
    /* 双引号 */
    if ([str isEqualToString:[[NSString alloc]initWithFormat:@"%s", "\""]] || [str isEqualToString:@"“"] || [str isEqualToString:@"”"])
    {
        return TRUE;
    }
    
    if ([str isEqualToString:@"\n"])
    {
        return TRUE;
    }
    
    return FALSE;
}

-(void) dealloc
{
    [self.backCard removeObserver:self forKeyPath:@"headText"];
    [self.backCard removeObserver:self forKeyPath:@"detailText"];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
