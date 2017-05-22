//
//  cardEditController.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/30.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tinyGroupListController.h"
#import "card.h"

@interface cardEditController : UIViewController <UITextViewDelegate, UIScrollViewDelegate>

/* "收藏" button */
@property (weak, nonatomic) IBOutlet UIButton *collect_button;
/* "备注" button*/
@property (weak, nonatomic) IBOutlet UIButton *note_button;
@property (weak, nonatomic) IBOutlet UIButton *doubleShowButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

/* 左下角字数统计 */
@property (weak, nonatomic) IBOutlet UILabel *numbers;
/* 右下角"删除"按钮 */
@property (weak, nonatomic) IBOutlet UIButton *little_delete_button;

@property (weak, nonatomic) card * backCard;
@property (nonatomic) BOOL shouldShowTabBar;


/* 标记当前是否正在显示“收藏卡” */
@property (nonatomic) BOOL have_show_gather;
/* 标记当前是否正在显示“备注卡” */
@property (nonatomic) BOOL have_show_note;

/* 维护一个tinyGroupController，用来显示分组 */
@property(strong, nonatomic) tinyGroupListController * grpController;

/* 从下方弹出的备注 view */
@property (strong, nonatomic) UITextView * noteView;

/* 从下方弹出的双框 view 下面的那个*/
@property (strong, nonatomic) UITextView * downView;

/* 用户点击收藏 */
- (IBAction)gatherCard:(id)sender;
- (IBAction)noteCard:(id)sender;
- (IBAction)doubleViewModule:(id)sender;

@end
