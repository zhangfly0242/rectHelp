//
//  cellContentView.h
//  reciteHelper
//
//  Created by zhangliang on 2017/5/11.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cardGroup.h"

@interface cellContentView : UIView <UITextViewDelegate>

/* 组名 */
@property (weak, nonatomic) IBOutlet UITextView *groupName;

/* 组的个数 */
@property (weak, nonatomic) IBOutlet UITextView *countDescription;
@property (weak, nonatomic) IBOutlet UIButton *delete_buttion;
@property (nonatomic) BOOL hiddenDelete;

- (IBAction)click_delete:(id)sender;

/* 对应的分组 */
@property(weak, nonatomic) cardGroup * backGroup;


-(void) configDeleteButton;
-(void) setTextViewKeyBoard : (UITextView * ) textView;

@end
