//
//  home_page_tableViewController.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/6.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "home_page_tableViewController.h"
#import "cardGroup.h"
#import "card.h"
#import "home_page_cell.h"
#import "root_navViewController.h"
#import "cardInfoController.h"
#import "card_manage.h"
#import "cardAddController.h"
#import "icloudManager.h"
#import "cardEditController.h"
#import "test1ViewController.h"

@interface home_page_tableViewController ()

@end

@implementation home_page_tableViewController

-(void) init_data
{
    /* 初始化时从 card管理结构(card_manage)获取初始数据，后者从CORE DATA中获取数据*/
    for (card * cd in self.data)
    {
        [self.cell_arr addObject:cd];
        /* 对添加进来的进行监视 ，监视其它内容可以监视到card本身内容的变化，
         通过监视group可以监视到card所在分组的切换*/

        [self observeCard: cd];
    }
    
    [[card_manage card_mng] addObserver: self
          forKeyPath:@"addCard"
             options:NSKeyValueObservingOptionNew
             context:nil];
   
    [[card_manage card_mng] addObserver: self
                             forKeyPath:@"deleteCard"
                                options:NSKeyValueObservingOptionNew
                                context:nil];
    
    /* 可选 : 取消分隔线 */
    UITableView * table = (UITableView *)self.view;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    /* 可选 : 设置tableView背景图片 */
//    UIImageView *backImageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
//    [backImageView setImage:[UIImage imageNamed:@"backPicture"]];
//   self.tableView.backgroundView = backImageView;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    
    return;
}

-(void) observeCard: (card *)cd
{
    /* 监听 每一个card ，发生变化，则更新界面 */
    [cd addObserver:self
         forKeyPath:@"createTime"
            options:NSKeyValueObservingOptionNew
            context:nil];
    
    [cd addObserver:self
         forKeyPath:@"headText"
            options:NSKeyValueObservingOptionNew
            context:nil];
    
    [cd addObserver:self
         forKeyPath:@"detailText"
            options:NSKeyValueObservingOptionNew
            context:nil];
    
    [cd addObserver:self
         forKeyPath:@"mark"
            options:NSKeyValueObservingOptionNew
            context:nil];
    
    [cd addObserver:self
         forKeyPath:@"groupName"
            options:NSKeyValueObservingOptionNew
            context:nil];
}

-(void)unObserveCard:(card *)cd
{
    /* zhang-attention : 对象被删除，需要移除观察者 */
    [cd removeObserver:self forKeyPath:@"createTime"];
    [cd removeObserver:self forKeyPath:@"headText"];
    [cd removeObserver:self forKeyPath:@"detailText"];
    [cd removeObserver:self forKeyPath:@"mark"];
    [cd removeObserver:self forKeyPath:@"groupName"];
}

-(void)init_reg_cell
{
    UITableView * table_view = (UITableView *)self.view;
    [table_view registerNib:[UINib nibWithNibName:@"home_page_cell" bundle:nil] forCellReuseIdentifier:@"home_page_cell_identity"];
}

-(void) kvoHandleCardAddDelete: (NSString *)keyPath change:(NSDictionary *)change
{
     card * cd = [change valueForKey:@"new"];
    
     /* 如果当前显示的是某个特定分组的grp，并且当前增加或删除卡片的组名不是这个分组的，那么不用关心 */
     if (![self.grp_name isEqualToString:ALL_GROUP]
         && [cd.groupName isEqualToString:self.grp_name])
     {
         return ;
     }
    
    /* 发生了添加事件 */
    if ([keyPath isEqualToString:@"addCard"])
    {
        /* 观察这个新卡片 */
        [self observeCard:cd];
        
        /* 添加到自己的维护的数据表的第一个 */
        [self.cell_arr insertObject:cd atIndex:0];
        
        NSArray * indexArr = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0] , nil];
        UITableView * view = (UITableView *)self.view;
        [view insertRowsAtIndexPaths:indexArr withRowAnimation: UITableViewRowAnimationFade];
    }/* 发生了删除事件 */
    else
    {
        /* zhang-attention : 对象被删除，需要移除观察者 */
        [self unObserveCard: cd];
        
        NSUInteger index = 0;
        index = [self.cell_arr indexOfObject:cd];

        /* 首先，从本地数据库中删除 ，注意删除的时候，必须要先把数据减少，然后再调用deleteRowsAtIndexPaths
         进行 UI操作*/
        [self.cell_arr removeObject:cd];

        /* 第二，从tableView中移除 */
        UITableView * table = (UITableView *)self.view;
        [table deleteRowsAtIndexPaths: [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:0] , nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    return ;
}

/* 监听总数据的变化 , 先判断是发生了数量增加还是数量减少，然后相应地增加或删除本地数据*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[card class]])
    {
        /* zhang-attention: 为什么对一个卡片切换分组，这里会打印两次 :
         2017-05-20 11:16:39.781925+0800 背个X啊[949:201288]  kvo : 句你承诺放假  keypath groupName  change {
         kind = 1;
         new = "\U6dfbnnjj ";
         }
         2017-05-20 11:16:39.793647+0800 背个X啊[949:201288]  kvo : 句你承诺放假  keypath groupName  change {
         kind = 1;
         new = "\U6dfbnnjj ";
         }
         */
        
        //card * cd1 = object;
    }
    
    /* 卡片本身变化 */
    if ([object isKindOfClass: [card class]])
    {
        card * cd = (card *)object;
        NSUInteger index = [self.cell_arr indexOfObject:cd];
        UITableView * table = (UITableView *)self.view;
        NSArray * arr = @[[NSIndexPath indexPathForRow:index inSection:0]];

        [table reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
    }/* 卡片增加或删除 */
    else if([object isKindOfClass: [card_manage class]])
    {
        [self kvoHandleCardAddDelete: keyPath change:change];
    }
    else{
        NSLog(@"ERROR : %s , unknown type",__FUNCTION__);
    }
    
    return ;
}

-(void)search_button_click
{
    return ;
}

/* 用户点击了 add 按钮 */
-(void)add_button_click
{
    cardAddController * addViewController = [[cardAddController alloc] init];

    /*如果在push跳转时需要隐藏tabBar，返回的时候显示 : */
    //addViewController.hidesBottomBarWhenPushed = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"betterHiddenTabBar" object:nil];
    
    // Push the view controller.
    [self.navigationController pushViewController:addViewController animated:YES];
}

-(void)click_delete : (NSIndexPath *)indexPath
{
    /* 找到删除的cell */
    card * cd = self.cell_arr[indexPath.row];
    [[card_manage card_mng] deleteCard:cd];
}





















- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cell_arr = [[NSMutableArray alloc]init];
    
    /* 注册cell */
    [self init_reg_cell];
    
    /* 定制 UINavigation​Item (注意不是创建UINavigation​Item，是readonly的，你第一次访问会自己创建), 通过指定其属性定制它，比如属性 :
     leftBarButtonItem  (UIBarButtonItem类型)
     
     leftBarButtonItem是 UIBarButtonItem 类，你可以创建这个一个该类实例，并最后将这个实例赋值给 UINavigation->leftBarButtonItem完成定制。
     
     【即你可以创建内部属性leftBarButtonItem，但不能创建UINavigation，是通过访问UINavigation或UINavigation的属性，系统完成它的 */
    
    /* 当前显示的所有分组的卡片，没有回退的动作 */
    if ([self.grp_name isEqualToString:ALL_GROUP])
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"ni" style: UIBarButtonItemStylePlain target: self.navigationController action: @selector(profile_click)];
        
        /* zhang-attention : 创建button  */
        UIImage * addImg = [UIImage imageNamed:@"add_button.png"];
        /* 这里对 UIImage 要设置 RenderingMode , 否则会显示一个色块 */
        addImg = [addImg imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem * addBar = [[UIBarButtonItem alloc] initWithImage:addImg style:UIBarButtonItemStylePlain target:self action:@selector(add_button_click)];

        self.navigationItem.rightBarButtonItems = @[addBar];
    }/* 当前显示的所有分组的卡片，有回退到上一级“分组”界面的动作 */
    else
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"分组" style: UIBarButtonItemStylePlain target: self action: @selector(exit_click)];
    }
    
    /* 获取本地数据 */
    [self init_data];
   
    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cell_arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    home_page_cell * cell = [tableView dequeueReusableCellWithIdentifier:@"home_page_cell_identity" forIndexPath:indexPath];
    
    if (indexPath.row + 1 <= self.cell_arr.count)
    {
        card * backCard = self.cell_arr[indexPath.row];
        cell.createTime.text = backCard.createTime;
        cell.detailText.text = backCard.detailText;
        cell.groupName.text = backCard.groupName;
    }
    else
    {
        cell.createTime.text = @"....";
        cell.detailText.text = @".....";
        cell.groupName.text = @"....";
        
        NSLog(@"ERROR : %s , indexPath.row %ld is big than cell count %ld",__FUNCTION__,
              indexPath.row + 1, self.cell_arr.count);
    }

    /* 默认点击是高亮的，取消点击被高亮效果*/
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    /* 可选 : 设置cell内部detailText外观 : 圆角 */
    cell.detailText.layer.cornerRadius = 8;
    cell.detailText.layer.masksToBounds = YES;
    
    /* uiLabel换行设置3步曲 */
    cell.detailText.numberOfLines = 0;//表示label可以多行显示
    /*b, 指定换行操作，是按字符换行，而不是按字母换行*/
    cell.detailText.lineBreakMode = NSLineBreakByWordWrapping;
 //   cell.detailText.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width;
    
    /* 通过添加约束设定uilabel为固定宽度时的固定套路:
        不能直接改宽度，需要在xib中拉到需要的宽度，然后添加宽度约束并将宽度约束固定为现在，这样才能固定宽度，否则添加完约束，又会根据你的label中的内容多少，决定lable的宽度，这和你的目的不一致。
     
        可以在xib中将placeHolder选为intrinsic size (需要在label添加任意约束，才能看到该选项)，取消这种设置。*/
    
    /* 可选 : 设置cell透明 */
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
    
    // Configure the cell...
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240;
}

-(NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* 会根据titile的长度来指定左滑每个按钮的宽度*/
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除"
        handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                UITableView * table = (UITableView *)self.view;
            
                /* 取消cell的编辑状态 */
                home_page_cell * page_cell = (home_page_cell *)[self tableView:table cellForRowAtIndexPath: indexPath];
                [page_cell setEditing:FALSE animated:YES];
            
                [self click_delete : indexPath];
            
        }];
    
    UITableViewRowAction *rowActionSec = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"标签"
        handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            }];
    
    /* zhang-attention : 这里如果要设置背景图片的话，可以先根据image得到uicolor,然后将该uicolor设置为背景颜色 。
     
        但是这样设置背景图片好像会占用过多内存，还可能会内存泄漏 ? 用这种方法之前，先好好看下网上的说法，再决定怎么做*/
    rowActionSec.backgroundColor = [UIColor lightGrayColor];
    
    NSArray *arr = @[rowAction,rowActionSec];
    return arr;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    
    cardEditController * cardEdit = [[cardEditController alloc]init];
    card * card = self.cell_arr[indexPath.row];
    cardEdit.backCard = card;
    [self.navigationController pushViewController:cardEdit animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/* 注意要通过这个初始化 */
-(instancetype)initWithData : (NSMutableArray *)data grpName: (NSString *)name
{
    self = [super init];
    
    self.data = [[NSMutableArray alloc]init];
    /* zhang-attention : 这里这样做不好，它不需要保持一个分组，它只需要一开始获得所有卡片，组的另一个作用是后续添加或删除卡片时，进行过滤不必要的kvo而已 */
    for (cardGroup * grp in data)
    {
        for (card * cd in grp.cardArr)
        {
            [self.data addObject:cd];
        }
    }
    
    /* zhang-attention : 这个name后续命名组的时候，不允许再取这个名字 */
    /* zhang-attention : 后续支持更改组名后，必须在这里监听组名的变化，并作相关处理，现在这里后续的处理都和这个组名有关系。 */
    /* 表示这个list table展示的是哪个组的信息。如果name是"all group"，那么展示
     的是所有组的信息。意味着会关心所有组内卡片的添加删除。和组名的变化*/
    self.grp_name = name;

    return self;
}

/* 用户点击“分组”，退回到分组界面 */
-(void)exit_click
{
    [self.navigationController popViewControllerAnimated:self];
}

-(void )viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* 如果是显示某个特定分组，那么进入后隐藏tabBar */
    if (![self.grp_name isEqualToString:ALL_GROUP])
    {
        /* 弹出该页面时隐藏tabBar */
        [[NSNotificationCenter defaultCenter]postNotificationName:@"betterHiddenTabBar" object:nil];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /* 如果是显示某个特定分组，那么退出后显示tabBar */
    if (![self.grp_name isEqualToString:ALL_GROUP])
    {
        /* 弹出该页面时显示tabBar */
        [[NSNotificationCenter defaultCenter]postNotificationName:@"betterShowTabBar" object:nil];
    }
}

-(void) dealloc
{
    /* 删除时，取消kvo*/
    for (card * cd in self.data)
    {
        [self unObserveCard:cd];
    }
    
    [[card_manage card_mng] removeObserver:self forKeyPath:@"addCard"];
    [[card_manage card_mng] removeObserver:self forKeyPath:@"deleteCard"];
    
}

@end
