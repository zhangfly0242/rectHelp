//
//  cardAddController.h
//  reciteHelper
//
//  Created by zhangliang on 2017/4/11.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "card.h"

@interface cardAddController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *createTime;
@property (weak, nonatomic) IBOutlet UITextField *headText;
@property (weak, nonatomic) IBOutlet UITextView *detailText;

@property (strong, nonatomic) card * backCard;
@end
