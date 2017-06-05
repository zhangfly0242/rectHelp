//
//  cardJustInfoEdit.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/30.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "card.h"

@interface cardJustInfoEdit : UIView <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *content;

@property (nonatomic) CGAffineTransform originTransform;

/* 若点击了最下面的文字，弹出键盘时，需要将整个textView上移，否则键盘会遮住。设置这个标记，当键盘消失，若这个标记存在，还要将内容下移 */
@property (nonatomic) BOOL temp_go_up;
@property (weak, nonatomic) card * backCard;

/* 设置它的tag，位置(frame)，以及内容(backCard) */
-(void) configWithTag :(NSInteger) tag backCard: (card *) backCard size: (CGSize) size;

/* 设置“原文”， “模式一”，“模式二” 的内容, 由于之前已经设置了tag以及backCard，内部知道获取内容(根据内部backCard信息)，也知道显示的类型(根据内部tag信息)*/
-(void) setItsContent;

@end
