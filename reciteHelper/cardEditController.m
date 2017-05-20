//
//  cardEditController.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/30.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "cardEditController.h"
#import "cardJustInfoEdit.h"
#import "tinyGroupListController.h"

@interface cardEditController ()

@end

@implementation cardEditController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initScrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exit_groupView) name:@"exit_group_list" object: nil];
    // Do any additional setup after loading the view.
}

-(void) initScrollView
{
    /* 设置scrollView的大小 */
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width * 3, [UIScreen mainScreen].bounds.size.height);
    self.scrollView.contentSize = size;
    /* 开启分页 */
    self.scrollView.pagingEnabled = YES;
    /* 禁止垂直方向的滑动 */
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    /* 在scrollView上添加“原文”view，tag是 0 */
    [self addThreeTabToScrollView: 10];
    /* 在scrollView上添加“模式一”view，tag是 1 */
    [self addThreeTabToScrollView: 11];
    /* 在scrollView上添加“模式二”view，tag是 2 */
    [self addThreeTabToScrollView: 12];
    
    /* 上面添加了三个view之后，还没有设置它们的内容, 由于耗时较长，采取了后续两个延迟设置的方式，这里先设置第一个 ，等到scrollView滑动到对应位置，再设置*/
    
    cardJustInfoEdit * view = [self.scrollView viewWithTag:10];
    [view setItsContent];
    
    
    /* 预先添加一个备注卡view , 后续用户点击备注时，上滑出来*/
    /* 创建备注 view*/
    self.noteView = [[UITextView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height ,
                                                                     [UIScreen mainScreen].bounds.size.width,
                                                                     [UIScreen mainScreen].bounds.size.height/2)];
    
    /* 设置键盘 */
    [self setTextViewKeyBoard: self.noteView];
    
    [self.scrollView addSubview:self.noteView];

    /* 预先添加一个view , 后续用户点击双框模式时，上滑出来*/
    self.downView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.scrollView.bounds.size.height ,
                                                                 self.scrollView.bounds.size.width,
                                                                 self.scrollView.bounds.size.height/2)];
    [self.view addSubview:self.downView];
    
    return ;
}

/* 添加 "原文" "模式一" "模式二" 到scrollView*/
-(void) addThreeTabToScrollView : (NSInteger) tag
{
    /* 即将添加到scrollView的“原文” “模式一” “模式二”*/
    cardJustInfoEdit * subView = nil;
    
    NSArray * arr = [[NSBundle mainBundle] loadNibNamed:@"cardJustInfoEdit" owner:self options:nil];
    
    for (id val in arr)
    {
        if ([val isKindOfClass: [cardJustInfoEdit class]])
        {
            subView = (cardJustInfoEdit *)val;
        }
    }
    
    if (!subView)
    {
        return ;
    }
    
    /* 将这个子view添加到scrollView*/
    [self.scrollView addSubview:subView];
    
    /* 设置这个子view的tag, 内容，和frame */
    [subView configWithTag:tag backCard:self.backCard size:self.scrollView.bounds.size];
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
    [self.noteView resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.noteView resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self noteViewDidEndEditing : textView];
}

/* noteView结束编辑 ，退回 备注框*/
- (void)noteViewDidEndEditing : (UITextView *) textView
{
    NSLog(@" 备注 : %@",textView.text);
    [self noteViewDisappear];
}

/* 从下方弹出备注框 */
- (void) noteViewAppear
{
    NSInteger tag = 0;
    if (self.scrollView.contentOffset.x < [UIScreen mainScreen].bounds.size.width)
    {
        tag = 10;
    }
    else if (self.scrollView.contentOffset.x < 2 * [UIScreen mainScreen].bounds.size.width)
    {
        tag = 11;
    }
    else if (self.scrollView.contentOffset.x < 3 * [UIScreen mainScreen].bounds.size.width)
    {
        tag = 12;
    }
    else
    {
        NSLog(@"ERROR : %s , unexpected contentOffset %f",__FUNCTION__,self.scrollView.contentOffset.x);
        return ;
    }
    
    /* 一，获得现在正在显示的view */
    cardJustInfoEdit * currentTab = (cardJustInfoEdit *)[self.scrollView viewWithTag:tag];
    
    /* 二，临时覆盖一个view, 实现变暗的效果，如果仅设置原tabBar的背景色为黑，无法将原tabBar中白色content部分也变黑 */
    UIView * tempCover = [[UIView alloc]initWithFrame:currentTab.bounds];
    tempCover.backgroundColor = [UIColor blackColor];
    /* 设置透明度，使得两者颜色叠加，实现变暗 */
    tempCover.alpha = 0.1;
    tempCover.tag = 20;
    [currentTab addSubview: tempCover];
    
    // 三，在tempCover 上添加单击手势识别，单击就取消备注状态
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(noteViewDisappear)];
    //点击的次数
    singleRecognizer.numberOfTapsRequired = 1;
    //给self.view添加一个手势监测；
    [tempCover addGestureRecognizer:singleRecognizer];
    
    
    /* 四，设置状态，当前不允许编辑文本，不允许滑动 ，备注状态退出了才可以*/
    self.scrollView.scrollEnabled = NO;
    currentTab.content.editable = NO;
    
    
    /* 五，开始动画: 将当前view上滑，缩小，加阴影，noteView已经创建好了，直接向上滑出，
     缩小，加阴影。
     
     zhang-attention : 这里面的动画的执行顺序和写的是一样吗 ？ */
    [UIView animateWithDuration:0.2 animations:^{
        /* 原文view */
        cardJustInfoEdit * currentTab = (cardJustInfoEdit *)[self.scrollView viewWithTag:tag];
        
        /* 缩小1/10 */
        currentTab.originTransform = currentTab.transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currentTab.transform, 0.9, 0.9);
        [currentTab setTransform:newTransform];
        
        CGPoint center = currentTab.center;
        center.y -= 40;
        currentTab.center = center;
        
        
        /* 加边框阴影 */
        currentTab.layer.shadowOpacity = 0.5;// 阴影透明度
        currentTab.layer.shadowColor = [UIColor grayColor].CGColor;// 阴影的颜色
        currentTab.layer.shadowRadius = 10;// 阴影扩散的范围控制
        currentTab.layer.shadowOffset  = CGSizeMake(0, 10);// 阴影矩形的位置
        
        /* 上滑出来 */
        CGRect noteViewFrame = self.noteView.frame;

        noteViewFrame.origin.y -= [UIScreen mainScreen].bounds.size.height/2;
        self.noteView.frame = noteViewFrame;


        /* 加边框阴影 */
        /* masksToBounds属性关掉，因为阴影设置的方式就是加offset给超出视图部分设置颜色来实现的，一旦不让子视图超出，阴影也就看不出了 */
        /* zhang-attention: 这个masksToBounds不是默认为no吗 */
        self.noteView.layer.masksToBounds = NO;
        self.noteView.layer.shadowOpacity = 0.5;// 阴影透明度
        self.noteView.layer.shadowColor = [UIColor blackColor].CGColor;// 阴影的颜色
        self.noteView.layer.shadowRadius = 10;// 阴影扩散的范围控制
        self.noteView.layer.shadowOffset  = CGSizeMake(0, -10);// 阴影矩形的位置
        
    }];
}


/* 向下方隐匿弹出的view */
-(void) noteViewDisappear
{
    [UIView animateWithDuration:0.2 animations:^{
        
        NSInteger tag = 0;
        
        if (self.scrollView.contentOffset.x < [UIScreen mainScreen].bounds.size.width)
        {
            tag = 10;
        }
        else if (self.scrollView.contentOffset.x < 2 * [UIScreen mainScreen].bounds.size.width)
        {
            tag = 11;
        }
        else if (self.scrollView.contentOffset.x < 3 * [UIScreen mainScreen].bounds.size.width)
        {
            tag = 12;
        }
        else
        {
            NSLog(@"ERROR : %s , unexpected contentOffset %f",__FUNCTION__,self.scrollView.contentOffset.x);
            return ;
        }
        
        /* 原文view */
        cardJustInfoEdit * currentTab = (cardJustInfoEdit *)[self.scrollView viewWithTag:tag];
    
        /* 移除临时覆盖在上面的coverTemp */
        UIView * coverTemp = [currentTab viewWithTag:20];
        [coverTemp removeFromSuperview];
        
        [currentTab setTransform:currentTab.originTransform];
        CGPoint center = currentTab.center;
        center.y += 40;
        currentTab.center = center;
        
        /* 去掉边框阴影 */
        currentTab.layer.shadowOpacity = 0;// 阴影透明度
        

        /* 隐匿 备注框 */
        CGRect noteViewFrame = self.noteView.frame;
        
        noteViewFrame.origin.y += [UIScreen mainScreen].bounds.size.height/2;
        self.noteView.frame = noteViewFrame;
        
        
        /* 去掉边框阴影 */
        self.noteView.layer.shadowOpacity = 0;// 阴影透明度
        
        
        /* 最后，设置状态，重新允许编辑文本，允许滑动*/
        self.scrollView.scrollEnabled = NO;
        currentTab.content.editable = NO;
        
        
    }];
    
    return ;
}


/* 开启双框模式，向downView添加subView, 并从下方弹出downView */
- (void) downViewAppear
{
    NSInteger tag = 0;
    NSInteger next_tag = 0;
    CGFloat origin_x = 0;
    
    if (self.scrollView.contentOffset.x < [UIScreen mainScreen].bounds.size.width)
    {
        tag = 10;
        next_tag = 11;
        origin_x = 0;
    }
    else if (self.scrollView.contentOffset.x < 2 * [UIScreen mainScreen].bounds.size.width)
    {
        tag = 11;
        next_tag = 12;
        origin_x = self.scrollView.bounds.size.width;
    }
    else if (self.scrollView.contentOffset.x < 3 * [UIScreen mainScreen].bounds.size.width)
    {
        tag = 12;
        next_tag = 10;
        origin_x = 2 * self.scrollView.bounds.size.width;
    }
    else
    {
        NSLog(@"ERROR : %s , unexpected contentOffset %f",__FUNCTION__,self.scrollView.contentOffset.x);
        return ;
    }
    
    /* 给即将弹出的downView添加子view , 相当于初始化*/
    cardJustInfoEdit * downView = (cardJustInfoEdit *)[self.scrollView viewWithTag:next_tag];
    [downView removeFromSuperview];
    
    /* 高度缩小一半，但还不够，因为这样会和容器view:downView的高度一样，会占满它，这样无法显示阴影，所以还要更小一些，
     故再减去4；*/
    
    CGRect frame = downView.frame;
    frame.origin.x = origin_x;
    frame.origin.y = self.scrollView.bounds.size.height;
    frame.size.height = self.scrollView.bounds.size.height/2 - 4;
    downView.frame = frame;
    
    /* 将comingDownTab缩小1/20 */
    downView.originTransform = downView.transform;
    CGAffineTransform newTransform2 = CGAffineTransformScale(downView.originTransform, 0.95, 0.95);
    [downView setTransform:newTransform2];
    
    /* 加边框阴影 */
    /* masksToBounds属性关掉，因为阴影设置的方式就是加offset给超出视图部分设置颜色来实现的，一旦不让子视图超出，阴影也就看不出了 */
    /* zhang-attention: 这个masksToBounds不是默认为no吗 */
    downView.layer.masksToBounds = NO;
    downView.layer.shadowOpacity = 0.6;// 阴影透明度
    downView.layer.shadowColor = [UIColor grayColor].CGColor;// 阴影的颜色
    downView.layer.shadowRadius = 5;// 阴影扩散的范围控制
    downView.layer.shadowOffset  = CGSizeMake(0, 0);// 阴影矩形的位置
    
    self.doubleShowButton.titleLabel.text = @"单框模式";

    UIImage * img = [UIImage imageNamed:@"single show.jpg"];
    img = [img imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    [self.doubleShowButton setImage:img forState:UIControlStateNormal];
    
    [self.scrollView addSubview:downView];
    
    /* 最后，设置状态，双框模式不允许编辑文本，不允许滑动*/
    self.scrollView.scrollEnabled = NO;
    downView.content.editable = NO;
    
    /* zhang-attention : 这里面的动画的执行顺序和写的是一样吗 ？ */
    [UIView animateWithDuration:0.2 animations:^{
        
        /* 原文view */
        cardJustInfoEdit * currentTab = (cardJustInfoEdit *)[self.scrollView viewWithTag:tag];
        /* 双框模式后不允许编辑 */
        currentTab.content.editable = NO;
        
        /* zhang-attention : 这里设置currentTab的alpha后，但是打印出来subview的alph都没有变化，那为什么整体看起来变透明了 ? */
        
        /* 高度缩小成原来的大小 */
        CGRect frame = currentTab.frame;
        frame.origin.y = 2;
        frame.size.height = self.scrollView.bounds.size.height/2 - 4;
        currentTab.frame = frame;
        
        /* 缩小2/10 */
        currentTab.originTransform = currentTab.transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currentTab.transform, 0.95, 0.95);
        [currentTab setTransform:newTransform];
        
        /* 加边框阴影 */
        currentTab.layer.shadowOpacity = 0.6;// 阴影透明度
        currentTab.layer.shadowColor = [UIColor grayColor].CGColor;// 阴影的颜色
        currentTab.layer.shadowRadius = 5;// 阴影扩散的范围控制
        currentTab.layer.shadowOffset  = CGSizeMake(0, 0);// 阴影矩形的位置
        
        UIImage * img2 = [UIImage imageNamed:@"single show.jpg"];
        img2 = [img2 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        [self.doubleShowButton setImage:img2 forState:UIControlStateNormal];
        
    
        /* 将downView上滑出来 */
         cardJustInfoEdit * comingDownTab = (cardJustInfoEdit *)[self.scrollView viewWithTag:next_tag];
         CGRect frame3 = comingDownTab.frame;
        /* origing.y 仅在中间还不够，还要向下一点，是要给上方留出一部分空间，显示阴影 */
         frame3.origin.y = self.scrollView.bounds.size.height/2 + 2;
         comingDownTab.frame = frame3;

    }];
}

/* 结束双框模式，将downView的subView放回原位，并隐匿downView */
-(void) downViewDisappear
{
    NSInteger tag = 0;
    NSInteger next_tag = 0;
    NSInteger new_origin_x = 0;
    
    if (self.scrollView.contentOffset.x < [UIScreen mainScreen].bounds.size.width)
    {
        tag = 10;
        next_tag = 11;
        new_origin_x = self.scrollView.bounds.size.width;
    }
    else if (self.scrollView.contentOffset.x < 2 * [UIScreen mainScreen].bounds.size.width)
    {
        tag = 11;
        next_tag = 12;
        new_origin_x = 2 * self.scrollView.bounds.size.width;
    }
    else if (self.scrollView.contentOffset.x < 3 * [UIScreen mainScreen].bounds.size.width)
    {
        tag = 12;
        next_tag = 10;
        new_origin_x = 0;
    }
    else
    {
        NSLog(@"ERROR : %s , unexpected contentOffset %f",__FUNCTION__,self.scrollView.contentOffset.x);
        return ;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
 
        /* 原文view */
        cardJustInfoEdit * currentTab = (cardJustInfoEdit *)[self.scrollView viewWithTag:tag];
        
        [currentTab setTransform:currentTab.originTransform];
        
        /* 恢复纵向的位置，以及高度 */
        CGRect frame1 = currentTab.frame;
        frame1.origin.y = 0;
        frame1.size.height = self.scrollView.bounds.size.height;
        currentTab.frame = frame1;
        
        /* 去掉边框阴影 */
        currentTab.layer.shadowOpacity = 0;// 阴影透明度
        
        UIImage * img = [UIImage imageNamed:@"double show.jpg"];
        img = [img imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        [self.doubleShowButton setImage:img forState:UIControlStateNormal];
        
        cardJustInfoEdit * downView = (cardJustInfoEdit *)[self.scrollView viewWithTag:next_tag];
        
        /* 向下隐匿 downView */
        CGRect downViewFrame = downView.frame;
        downViewFrame.origin.y = self.scrollView.bounds.size.height;
        downView.frame = downViewFrame;
        
        /* 最后，双框模式结束，再次允许编辑和滑动 */
        currentTab.content.editable = YES;
        
    } completion:^(BOOL finished) {
        cardJustInfoEdit * downView = (cardJustInfoEdit *)[self.scrollView viewWithTag:next_tag];
        
        [downView removeFromSuperview];
        
        /* 恢复大小*/
        [downView setTransform:downView.originTransform];

        /* 恢复frame */
        CGRect frame = downView.frame;
        frame.origin.x = new_origin_x;
        frame.origin.y = 0;
        frame.size.height = self.scrollView.bounds.size.height;
        downView.frame = frame;
        
        /* 去掉边框阴影 */
        downView.layer.shadowOpacity = 0;// 阴影透明度
        
        UIImage * img2 = [UIImage imageNamed:@"double show.jpg"];
        img2 = [img2 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        [self.doubleShowButton setImage:img2 forState:UIControlStateNormal];
        
        /* 将subView放回原位 */
        [self.scrollView addSubview:downView];
        
        /* 最后，双框模式结束，再次允许编辑和滑动 */
        self.scrollView.scrollEnabled = YES;
        downView.content.editable = YES;
        
    }];
    
    return ;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


/* 点击"收藏卡" */
- (IBAction)gatherCard:(id)sender {
    
    cardJustInfoEdit * currentTab  = [self gatCurrentTab];
    
    /* 二，临时覆盖一个view, 实现变暗的效果，如果仅设置原tabBar的背景色为黑，无法将原tabBar中白色content部分也变黑 */
    UIView * tempCover = [[UIView alloc]initWithFrame:currentTab.bounds];
    tempCover.backgroundColor = [UIColor blackColor];
    /* 设置透明度，使得两者颜色叠加，实现变暗 */
    tempCover.alpha = 0.1;
    tempCover.tag = 20;
    [currentTab addSubview: tempCover];
    
    // 三，在tempCover 上添加单击手势识别，单击就取消弹出的分组框状态
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(exit_groupView)];
    singleRecognizer.numberOfTapsRequired = 1;
    [tempCover addGestureRecognizer:singleRecognizer];
    
    /* 四，设置状态，当前不允许编辑文本，不允许滑动 ，备注状态退出了才可以*/
    self.scrollView.scrollEnabled = NO;
    currentTab.content.editable = NO;

    
    
    /* 将group view弹出 */
    self.grpController = [[tinyGroupListController alloc]init];
    self.grpController.backCard = self.backCard;
    /* group controller的视图的起点就是button，但是大小要改变 */
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/1.5, [UIScreen mainScreen].bounds.size.height/1.5);
    
    [self.grpController showTinyGroupView:self.scrollView withframe:frame];
}

/* 退出显示的分组信息 */
-(void) exit_groupView
{
    [self.grpController.view removeFromSuperview];
    self.grpController = nil;
    
    UIView * view = [self.scrollView viewWithTag:20];
    [view removeFromSuperview];
}


/* 点击 “备注卡 */
- (IBAction)noteCard:(id)sender {
    [self noteViewAppear];
    
}

/* 点击 “双框模式 */
- (IBAction)doubleViewModule:(id)sender {
    /* 表示当前是处于双框模式 */
    static BOOL doubleView = FALSE;
    
    if (!doubleView)
    {
        doubleView = TRUE;
        [self downViewAppear];
    }
    else
    {
        doubleView = FALSE;
        [self downViewDisappear];
    }
}




- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger tag = 0;
    
    if (self.scrollView.contentOffset.x < [UIScreen mainScreen].bounds.size.width)
    {
        tag = 10;
    }
    else if (self.scrollView.contentOffset.x < 2 * [UIScreen mainScreen].bounds.size.width)
    {
        tag = 11;
    }
    else if (self.scrollView.contentOffset.x < 3 * [UIScreen mainScreen].bounds.size.width)
    {
        tag = 12;
    }
    
    /* 获取当前要显示的view */
    cardJustInfoEdit * view = [self.scrollView viewWithTag:tag];
    [view setItsContent];
}


-(cardJustInfoEdit *) gatCurrentTab
{
    NSInteger tag = 0;
    if (self.scrollView.contentOffset.x < [UIScreen mainScreen].bounds.size.width)
    {
        tag = 10;
    }
    else if (self.scrollView.contentOffset.x < 2 * [UIScreen mainScreen].bounds.size.width)
    {
        tag = 11;
    }
    else if (self.scrollView.contentOffset.x < 3 * [UIScreen mainScreen].bounds.size.width)
    {
        tag = 12;
    }
    else
    {
        NSLog(@"ERROR : %s , unexpected contentOffset %f",__FUNCTION__,self.scrollView.contentOffset.x);
        return nil;
    }
    
    /* 一，获得现在正在显示的view */
    cardJustInfoEdit * currentTab = (cardJustInfoEdit *)[self.scrollView viewWithTag:tag];
    return currentTab;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
