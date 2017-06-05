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
    
    self.content.returnKeyType = UIReturnKeyNext;
    
    /* masksToBounds属性关掉，因为阴影设置的方式就是加offset给超出视图部分设置颜色来实现的，一旦不让子视图超出，阴影也就看不出了 */
    self.layer.masksToBounds = NO;
    
    /* 通过kvo监听 self.backCard.detailText */
    [self oberveCard : self.backCard];
    
    /* “模式一” 和 “模式二” 都不可以编辑, 这样只有“原文"才会涉及取消键盘时，保存内容的处理，然后触发kvo*/
    if ((11 == self.tag) || (12 == self.tag))
    {
        self.content.editable = NO;
    }
    
    /* 设置键盘，以及实现代理方法(保存数据，以及隐藏键盘) */
    [self setTextViewKeyBoard : self.content];
    
    /* 监听键盘弹出 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    /* 监听键盘隐藏 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
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

-(NSString *) getXString : (NSInteger) xCount
{
    NSInteger i = 0;
    NSString * x = @"乂";
    
    for (i = 1; i < xCount; i++)
    {
        x = [x stringByAppendingString:@"乂"];
    }
    
    return x;
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
    
    i = 0;
    while (i <= self.backCard.detailText.length - 1)
    {
        range.length = self.backCard.empty_size;
        range.location = i;
        
        if (jump_count < self.backCard.empty_jump)
        {
            jump_count++;
            i++;
            continue;
        }
        else{
            jump_count = 0;
            
            range.location = i;
            range.length = self.backCard.empty_size;
            
            /* 如果到了最后，range可能会超出，那么直接将最后的部分替换就行了 */
            if (i + self.backCard.empty_size >= self.backCard.detailText.length - 1)
            {
                NSLog(@"1");
                range.length = (self.backCard.detailText.length - 1) - i;
            }
            
            if ([self special_str_no_handle: [self.backCard.detailText substringWithRange:range]])
            {
                i = i + self.backCard.empty_size;
                continue;
            }
            
            NSString * stringX = [self getXString : range.length];
            str1 = [str1 stringByReplacingCharactersInRange:range withString: stringX];
            
            i = i + self.backCard.empty_size;
        }
        
    }
    
    jump_count = 0;
    handle = FALSE;
    i = self.backCard.empty_jump;
    while (i <= self.backCard.detailText.length - 1)
    {
        range.length = self.backCard.empty_size;
        range.location = i;
        
        if (jump_count < self.backCard.empty_jump)
        {
            jump_count++;
            i++;
            continue;
        }
        else{
            jump_count = 0;
            
            range.location = i;
            range.length = self.backCard.empty_size;
            
            /* 如果到了最后，range可能会超出，那么直接将最后的部分替换就行了 */
            if (i + self.backCard.empty_size >= self.backCard.detailText.length - 1)
            {
                NSLog(@"1");
                range.length = (self.backCard.detailText.length - 1) - i;
            }
            
            if ([self special_str_no_handle: [self.backCard.detailText substringWithRange:range]])
            {
                i = i + self.backCard.empty_size;
                continue;
            }

            NSString * stringX = [self getXString : range.length];
            str2 = [str2 stringByReplacingCharactersInRange:range withString:stringX];
            
            i = i + self.backCard.empty_size;
        }
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
        if ([keyPath isEqualToString:@"detailText"])
        {
            /* 更新它的内容 */
            [self setItsContent];
        }
        else if ([keyPath isEqualToString:@"word_size"])
        {
            NSLog(@" font size %f", self.content.font.pointSize);
            /* 用新size创建 UIFont ，并赋值给self.content*/
            self.content.font = [self.content.font fontWithSize:self.backCard.word_size];
        }
        else if ([keyPath isEqualToString:@"empty_size"])
        {
            /* 重新设置更新它的内容 */
            [self setItsContent];
        }
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
    NSLog(@" textViewDidEndEditing");
    
    [self contentViewDidEndEditing : textView];
}



-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@" text : %@", text);
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        return NO;
    }
    
    return YES;
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

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSLog(@"keyboardWillShow");
    
    // 延迟一下，否则获得的是上一次的，因为点击后，立刻进来了，此时还没有来得及设置最新的光标位置，即[textView caretRectForPosition:textView.selectedTextRange.start].origin.y。 参考自https://segmentfault.com/q/1010000003825991
    [self performSelector:@selector(keyBoardShowTryUpTextView:) withObject:aNotification afterDelay:0.1f];
}

- (void)keyBoardShowTryUpTextView:(NSNotification *)aNotification {
    
    CGFloat cursorPosition_y = 0;
    
    NSLog(@" textViewDidChange , aNotification %@",aNotification);
    
    if (self.content.selectedTextRange) {
        cursorPosition_y = [self.content caretRectForPosition:self.content.selectedTextRange.start].origin.y;
    } else {
        cursorPosition_y = 0;
    }
    
    NSLog(@" cursorPosition-0 : %f %f [%f]", self.content.contentSize.height,cursorPosition_y,
          self.content.contentSize.height - cursorPosition_y);
    
    /* 获取弹出的键盘的高度*/
    NSValue *aValue = [aNotification.userInfo valueForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGFloat height = [aValue CGRectValue].size.height;
    
    /* textView因为键盘遮挡输入，自动上移套路：三个关键点
      一，需要延迟下，再获取当前光标位置
     
      二，要区别对待，不是点击所有位置都上移: (需要光标位置，contetnSize, 以及键盘高度三个变量来判断) :
            当前光标距离底部的距离已经小于 键盘的高度了(这里键盘的高度默认为100) , 那么弹出的键盘会遮挡，将textView上移
    
      三，上移的距离和键盘高度一样 */
    if (self.content.contentSize.height - cursorPosition_y < height)
    {
        self.content.contentOffset = CGPointMake(0, self.content.contentOffset.y + height);
        self.temp_go_up = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSLog(@" keyboardWillHide ");
    
    /* 获取弹出的键盘的高度*/
    NSValue *aValue = [aNotification.userInfo valueForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGFloat height = [aValue CGRectValue].size.height;
    
    /* textView因为键盘弹出，临时上移了，此时若键盘消失，需要再次将textView下移 */
    if (self.temp_go_up)
    {
        self.content.contentOffset = CGPointMake(0, self.content.contentOffset.y - height);
        self.temp_go_up = NO;
    }
}

-(void) oberveCard: (card *)backCard
{
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
    
    /* 监听 字体大小 的变化 */
    [backCard addObserver:self
               forKeyPath:@"word_size"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
    
    /* 监听 扣空的间隔 的变化 */
    [backCard addObserver:self
               forKeyPath:@"empty_jump"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    
    /* 监听 扣空的空的大小 的变化 */
    [backCard addObserver:self
               forKeyPath:@"empty_size"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    
    return ;
}

-(void) unOberveCard: (card *)card
{
    /* 取消对card的监听 */
    [card removeObserver:self forKeyPath:@"headText"];
    [card removeObserver:self forKeyPath:@"detailText"];
    [card removeObserver:self forKeyPath:@"word_size"];
    [card removeObserver:self forKeyPath:@"empty_jump"];
    [card removeObserver:self forKeyPath:@"empty_size"];
    
    return ;
}

-(void) dealloc
{
    [self unOberveCard:self.backCard];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
