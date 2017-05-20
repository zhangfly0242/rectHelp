//
//  test1ViewController.h
//  reciteHelper
//
//  Created by zhangliang on 2017/5/15.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface test1ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textField;

/* 返回自己的单例 */
+(instancetype) itSelf;

@end
