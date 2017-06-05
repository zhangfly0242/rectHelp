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
#import <UIKit/UIKit.h>

@interface cardEditController ()

@end

@implementation cardEditController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self initScrollView];

    /* 双框模式 */
    UIImage * img1 = [UIImage imageNamed:@"double show.jpg"];
    img1 = [UIImage imageWithCGImage:img1.CGImage scale:2.0 orientation:UIImageOrientationUp];
    /* 这里对 UIImage 要设置 RenderingMode , 否则会显示一个色块 */
    img1 = [img1 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem * doubleViewBar = [[UIBarButtonItem alloc] initWithImage:img1 style:UIBarButtonItemStylePlain target:self action:@selector(doubleViewClick)];
    
    /* 备注 */
    UIImage * img2 = [UIImage imageNamed:@"write note.jpg"];
    img2 = [UIImage imageWithCGImage:img2.CGImage scale:2.0 orientation:UIImageOrientationUp];
    /* 这里对 UIImage 要设置 RenderingMode , 否则会显示一个色块 */
    img2 = [img2 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem * markViewBar = [[UIBarButtonItem alloc] initWithImage:img2 style:UIBarButtonItemStylePlain target:self action:@selector(noteViewAppear)];
    
    /* 收藏 */
    UIImage * img3 = [UIImage imageNamed:@"collect card.jpg"];
    img3 = [UIImage imageWithCGImage:img3.CGImage scale:2.0 orientation:UIImageOrientationUp];
    /* 这里对 UIImage 要设置 RenderingMode , 否则会显示一个色块 */
    img3 = [img3 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem * groupViewBar = [[UIBarButtonItem alloc] initWithImage:img3 style:UIBarButtonItemStylePlain target:self action:@selector(groupView_show)];

    
    
    /* 中间添加一个大空白的区域，隔开下 */
    UIBarButtonItem * blanItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                  target:self
                                  action:@selector(emptySizeBigger)];
    
    /* 定制uinavitaion bar */
    self.navigationItem.rightBarButtonItems = @[doubleViewBar, blanItem, markViewBar, groupViewBar];
    
    /* 定制tool bar item*/
    /* 控制字体变大 */
    UIBarButtonItem * barItem = [[UIBarButtonItem alloc] initWithTitle:@"大" style:UIBarButtonItemStylePlain target:self action:@selector(fontBigger)];
    
    /* 中间隔开下 */
    UIBarButtonItem * barItem2 = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                  target:self
                                  action:@selector(emptySizeBigger)];
    barItem2.width = 30;
    
    /* 控制字体变小 */
    UIBarButtonItem * barItem3 = [[UIBarButtonItem alloc] initWithTitle:@"小" style:UIBarButtonItemStylePlain target:self action:@selector(fontSmaller)];
    
    /* 中间添加一个大空白的区域，隔开下 */
    UIBarButtonItem * barItem4 = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                   target:self
                                   action:@selector(emptySizeBigger)];
    
    /* 减小扣空的空的大小 */
    UIBarButtonItem * barItem5 = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                  target:self
                                  action:@selector(emptySizeSmaller)];
    
    /* 中间隔开下 */
    UIBarButtonItem * barItem6 = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                  target:self
                                  action:@selector(emptySizeBigger)];
    barItem6.width = 30;
    
    /* 增大扣空的空的大小 */
    UIBarButtonItem * barItem7 = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                  target:self
                                  action:@selector(emptySizeBigger)];
    
    
    NSArray *items=[NSArray arrayWithObjects:barItem,barItem2,barItem3,barItem4,
                    barItem5, barItem6, barItem7, nil];
    /* 设置viewcontroller的tool bar */
    [self setToolbarItems:items];  //向UIToolBar添加UIBarButtonItem
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupView_exit) name:@"exit_group_list" object: nil];
    
/* 键盘弹出有较多问题，先不做 */
    /* 监听键盘弹出 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    /* 监听键盘隐藏 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // Do any additional setup after loading the view.
}

-(void) initScrollView
{
    /* 设置scrollView的大小 */
    CGSize size = CGSizeMake(self.scrollView.bounds.size.width * 3, self.scrollView.bounds.size.height);
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
    
/* 点击一下，就隐藏上边栏，目前不做 */
#if 0
    /* 在三个view上添加手势，如果用户点击了一下，那么隐藏或显示nagigation bar */
    cardJustInfoEdit * view1 = [self.scrollView viewWithTag:10];
    UITapGestureRecognizer* singleRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(navigationBarAppear)];
    singleRecognizer1.numberOfTapsRequired = 1;
    [view1 addGestureRecognizer:singleRecognizer1];
    
    cardJustInfoEdit * view2 = [self.scrollView viewWithTag:11];
    UITapGestureRecognizer* singleRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(navigationBarAppear)];
    singleRecognizer2.numberOfTapsRequired = 1;
    [view2 addGestureRecognizer:singleRecognizer2];
    
    cardJustInfoEdit * view3 = [self.scrollView viewWithTag:12];
    UITapGestureRecognizer* singleRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(navigationBarAppear)];
    singleRecognizer3.numberOfTapsRequired = 1;
    [view3 addGestureRecognizer:singleRecognizer3];
#endif
    
    /* 上面添加了三个view之后，还没有设置它们的内容, 由于耗时较长，采取了后续两个延迟设置的方式，这里先设置第一个 ，等到scrollView滑动到对应位置，再设置*/
    
    cardJustInfoEdit * view = [self.scrollView viewWithTag:10];
    [view setItsContent];
    
    /* 预先添加一个备注卡view , 后续用户点击备注时，上滑出来*/
    /* 创建备注 view*/
    self.noteView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.scrollView.bounds.size.height ,
                                                                     self.scrollView.bounds.size.width,
                                                                     self.scrollView.bounds.size.height/2)];
    
    /* 设置键盘 */
    [self setTextViewKeyBoard: self.noteView];
    
    [self.scrollView addSubview:self.noteView];
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
    self.backCard.mark = textView.text;
    [self noteViewDisappear];
}

/* show/hide navigaton bar */
- (void) navigationBarAppear
{
    static BOOL showNaviBar = TRUE;

    if (showNaviBar)
    {
        UIView * subView1 = [[UIView alloc]initWithFrame:self.navigationController.navigationBar.frame];
        subView1.backgroundColor = [UIColor grayColor];
        subView1.tag =30;
        
        /* 在navigationBar上覆盖一个灰色的view，来实现将卡片变暗，集中注意力到卡片上 */
        [self.navigationController.navigationBar addSubview:subView1];
        
        showNaviBar = FALSE;
    }
    else
    {
        UIView * subView1 = [self.navigationController.navigationBar viewWithTag:30];
        [subView1 removeFromSuperview];
        
        showNaviBar = TRUE;
    }
}


/* 从下方弹出备注框 */
- (void) noteViewAppear
{
    NSInteger tag = 0;
    
    /* 当前已经显示了备注框 ，此时再点击，取消备注框 */
    if (self.have_show_note)
    {
        [self noteViewDisappear];
        return;
    }
    
    self.have_show_note = YES;
    
    if (self.scrollView.contentOffset.x < self.scrollView.bounds.size.width)
    {
        tag = 10;
    }
    else if (self.scrollView.contentOffset.x < 2 * self.scrollView.bounds.size.width)
    {
        tag = 11;
    }
    else if (self.scrollView.contentOffset.x < 3 * self.scrollView.bounds.size.width)
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
    
    /* 四，设置状态，当前正在备注卡界面，不允许滑动 ，备注状态退出了才可以*/
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

        noteViewFrame.origin.y -= self.scrollView.bounds.size.height/2;
        self.noteView.frame = noteViewFrame;


        /* 加边框阴影 */
        /* masksToBounds属性关掉，因为阴影设置的方式就是加offset给超出视图部分设置颜色来实现的，一旦不让子视图超出，阴影也就看不出了 */
        /* zhang-attention: 这个masksToBounds不是默认为no吗 */
        self.noteView.layer.masksToBounds = NO;
        self.noteView.layer.shadowOpacity = 0.5;// 阴影透明度
        self.noteView.layer.shadowColor = [UIColor blackColor].CGColor;// 阴影的颜色
        self.noteView.layer.shadowRadius = 10;// 阴影扩散的范围控制
        self.noteView.layer.shadowOffset  = CGSizeMake(0, -10);// 阴影矩形的位置
        
        /* 设置noteView的内容 */
        self.noteView.text = self.backCard.mark;
    }];
}


/* 向下方隐匿弹出的view */
-(void) noteViewDisappear
{
    if (!self.have_show_note)
    {
        return ;
    }
    self.have_show_note = NO;
    
    /* 当前“备注卡”页面在键盘之上，那么回复 */
    if (self.note_view_above_keyboard)
    {
        /* 将“备注卡”更进一步上滑 */
        CGRect noteViewFrame = self.noteView.frame;
        noteViewFrame.origin.y += 150;
        self.noteView.frame = noteViewFrame;
        
        /* 标记当前“备注卡”不在键盘之上 */
        self.note_view_above_keyboard = NO;
    }
    
    /* 如果此时有键盘，那么取消键盘 */
    [self.noteView resignFirstResponder];
    
    /* 如果此时键盘弹出了，那么noteView上移到键盘之上，需要下移，归位 */
    if (self.note_view_above_keyboard)
    {
        CGRect noteViewFrame = self.noteView.frame;
        noteViewFrame.origin.y -= 150;
        self.noteView.frame = noteViewFrame;
        
        /* 标记当前“备注卡”不在键盘之上 */
        self.note_view_above_keyboard = NO;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        
        NSInteger tag = 0;
        
        if (self.scrollView.contentOffset.x < self.scrollView.bounds.size.width)
        {
            tag = 10;
        }
        else if (self.scrollView.contentOffset.x < 2 * self.scrollView.bounds.size.width)
        {
            tag = 11;
        }
        else if (self.scrollView.contentOffset.x < 3 * self.scrollView.bounds.size.width)
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
        noteViewFrame.origin.y += self.scrollView.bounds.size.height/2;
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
    
    if (self.scrollView.contentOffset.x < self.scrollView.bounds.size.width)
    {
        tag = 10;
        next_tag = 11;
        origin_x = 0;
    }
    else if (self.scrollView.contentOffset.x < 2 * self.scrollView.bounds.size.width)
    {
        tag = 11;
        next_tag = 12;
        origin_x = self.scrollView.bounds.size.width;
    }
    else if (self.scrollView.contentOffset.x < 3 * self.scrollView.bounds.size.width)
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
    
    /* 双框模式，得到下一个view，如果下一个view还没有内容，就设置内容 */
    if (0 == [downView.content.text length])
    {
        [downView setItsContent];
    }
    
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
   
#if 0
        UIImage * img2 = [UIImage imageNamed:@"single show.jpg"];
        img2 = [img2 imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        [self.doubleShowButton setImage:img2 forState:UIControlStateNormal];
#endif
    
        /* 将downView上滑出来 */
         cardJustInfoEdit * comingDownTab = (cardJustInfoEdit *)[self.scrollView viewWithTag:next_tag];
         CGRect frame3 = comingDownTab.frame;
        /* origing.y 仅在中间还不够，还要向下一点，是要给上方留出一部分空间，显示阴影 */
         frame3.origin.y = self.scrollView.bounds.size.height/2 + 2;
         comingDownTab.frame = frame3;
         //comingDownTab.backgroundColor = [UIColor redColor];

    }];
}

/* 结束双框模式，将downView的subView放回原位，并隐匿downView */
-(void) downViewDisappear
{
    NSInteger tag = 0;
    NSInteger next_tag = 0;
    NSInteger new_origin_x = 0;
    
    if (self.scrollView.contentOffset.x < self.scrollView.bounds.size.width)
    {
        tag = 10;
        next_tag = 11;
        new_origin_x = self.scrollView.bounds.size.width;
    }
    else if (self.scrollView.contentOffset.x < 2 * self.scrollView.bounds.size.width)
    {
        tag = 11;
        next_tag = 12;
        new_origin_x = 2 * self.scrollView.bounds.size.width;
    }
    else if (self.scrollView.contentOffset.x < 3 * self.scrollView.bounds.size.width)
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


/* 点击收藏，出现"分组" */
- (IBAction)show_groupView:(id)sender {
    [self groupView_show];
}

-(void) groupView_show{
    cardJustInfoEdit * currentTab  = [self gatCurrentTab];
    
    if (self.have_show_gather)
    {
        [self groupView_exit];
        return ;
    }
    
    self.have_show_gather = YES;
    
    /* 二，临时覆盖一个view, 实现变暗的效果，如果仅设置原tabBar的背景色为黑，无法将原tabBar中白色content部分也变黑 */
    UIView * tempCover = [[UIView alloc]initWithFrame:currentTab.bounds];
    tempCover.backgroundColor = [UIColor blackColor];
    /* 设置透明度，使得两者颜色叠加，实现变暗 */
    tempCover.alpha = 0.5;
    tempCover.tag = 20;
    [currentTab addSubview: tempCover];
    
    // 三，在tempCover 上添加单击手势识别，单击就取消弹出的分组框状态
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(groupView_exit)];
    singleRecognizer.numberOfTapsRequired = 1;
    [tempCover addGestureRecognizer:singleRecognizer];
    
    /* 四，设置状态，当前不允许编辑文本，不允许滑动 ，备注状态退出了才可以*/
    self.scrollView.scrollEnabled = NO;
    currentTab.content.editable = NO;
    
    /* 将group view弹出 */
    self.grpController = [[tinyGroupListController alloc]init];
    self.grpController.backCard = self.backCard;
    /* group controller的视图的起点就是button，但是大小要改变, frame的高度要随分组数量动态设置 */
    CGRect frame = CGRectMake(0, 0, self.scrollView.bounds.size.width/2.5, 44 * self.grpController.grp_arr.count);
    
    [self.grpController showTinyGroupView:self.scrollView withframe:frame];
}

/* 退出显示的分组信息 */
-(void) groupView_exit
{
    self.have_show_gather = NO;
    [self.grpController.view removeFromSuperview];
    self.grpController = nil;
    
    cardJustInfoEdit * currentTab  = [self gatCurrentTab];
    currentTab.content.editable = YES;
    
    self.scrollView.scrollEnabled = YES;
    
    UIView * view = [self.scrollView viewWithTag:20];
    [view removeFromSuperview];
}

- (IBAction)noteCard:(id)sender {
    [self noteViewAppear];
}

/* 空格变大 */
-(void)emptySizeBigger
{
    if (self.backCard.empty_size >= 20)
    {
        return ;
    }
    
    self.backCard.empty_size++;
}

/* 空格变小 */
-(void)emptySizeSmaller
{
    if (self.backCard.empty_size <= 1)
    {
        return ;
    }
    self.backCard.empty_size--;
}

/* 字体变大 */
-(void)fontBigger
{
    self.backCard.word_size++;
}

/* 字体变小 */
-(void)fontSmaller
{
    self.backCard.word_size--;
}

/* navigation bar 上的item */
-(void)doubleViewClick
{
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
    
    if (self.scrollView.contentOffset.x < self.scrollView.bounds.size.width)
    {
        tag = 10;
    }
    else if (self.scrollView.contentOffset.x < 2 * self.scrollView.bounds.size.width)
    {
        tag = 11;
    }
    else if (self.scrollView.contentOffset.x < 3 * self.scrollView.bounds.size.width)
    {
        tag = 12;
    }
    
    /* 获取当前要显示的view */
    cardJustInfoEdit * view = [self.scrollView viewWithTag:tag];
    if (0 == view.content.text.length)
    {
        [view setItsContent];
    }
}

-(cardJustInfoEdit *) gatCurrentTab
{
    NSInteger tag = 0;
    if (self.scrollView.contentOffset.x < self.scrollView.bounds.size.width)
    {
        tag = 10;
    }
    else if (self.scrollView.contentOffset.x < 2 * self.scrollView.bounds.size.width)
    {
        tag = 11;
    }
    else if (self.scrollView.contentOffset.x < 3 * self.scrollView.bounds.size.width)
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
    NSLog(@" viewWillAppear .. ");
    
    /* 显示navigation controller管理的toolbar:
     它会显示最上面的view controller的bar item */
    self.navigationController.toolbarHidden = NO;
    [super viewWillAppear:animated];
    
#if 0
    if (!self.shouldShowTabBar)
    {
        /* 弹出该页面时隐藏tabBar */
        [[NSNotificationCenter defaultCenter]postNotificationName:@"betterHiddenTabBar" object:nil];
    }
#endif
}

-(void) viewWillDisappear:(BOOL)animated
{
    NSLog(@" viewWillDisappear set toolBar yes ");
    
    /* 每次退出，都将这个标记还原，下次再从home_page_list进来再新设置，即这个标记的生存期只有 从home_page_list进来到退出这短暂时间。如果该标记一直存在，会使得最近查看的页面，也隐藏tabBar */
    if (self.hidesBottomBarWhenPushed)
    {
        self.hidesBottomBarWhenPushed  = NO;
    }
    
    self.navigationController.toolbarHidden = YES;
    [super viewWillDisappear:animated];
    
#if 0
    if (!self.shouldShowTabBar)
    {
        /* 弹出该页面时显示tabBar */
        [[NSNotificationCenter defaultCenter]postNotificationName:@"betterShowTabBar" object:nil];
    }
#endif
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    /* 当前已经弹出了“备注卡”页面，当前“备注卡”不在键盘之上 (因为键盘弹出，可能会通知多次，所以这里如果已经上移到键盘之上，这里不能再上移了 */
    if (self.have_show_note && !self.note_view_above_keyboard)
    {
        /* 将“备注卡”更进一步上滑 */
        CGRect noteViewFrame = self.noteView.frame;
        noteViewFrame.origin.y -= 150;
        self.noteView.frame = noteViewFrame;
        
        /* 标记当前“备注卡”是否移动到键盘之上 */
        self.note_view_above_keyboard = YES;
    }
    
    NSLog(@" keyboardWillShow aNotification %@", aNotification);
}

/* 隐藏“电池栏” */
- (BOOL)prefersStatusBarHidden
{
    return YES; // 返回NO表示要显示，返回YES将hiden
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self noteViewDisappear];
    
    NSLog(@" keyboardWillHide ");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
