//
//  tinyGroupListController.m
//  reciteHelper
//
//  Created by zhangliang on 2017/5/6.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "card_manage.h"
#import "tinyGroupListController.h"
#import "tinyGroupCell.h"

@interface tinyGroupListController ()

@end

@implementation tinyGroupListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView * table_view = (UITableView *)self.view;
    [table_view registerNib:[UINib nibWithNibName:@"tinyGroupCell" bundle:nil] forCellReuseIdentifier:@"tinyGroupCell"];
    /* 取消分割线 */
    table_view.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    table_view.layer.cornerRadius = 8;
    table_view.layer.masksToBounds = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    NSLog(@" grp_arr count %lu ", self.grp_arr.count);
    return self.grp_arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tinyGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tinyGroupCell" forIndexPath:indexPath];
    
    cardGroup * grp = self.grp_arr[indexPath.row];
    cell.group_name.text = grp.grpName;
    cell.group_brief.text = [NSString stringWithFormat:@"%lu条", (unsigned long)grp.cardArr.count];
    
    NSLog(@" %@- %@ ",self.backCard.groupName,cell.group_name.text );
    /* 卡片所属的分组，，右边显示一个绿色的小勾 */
    if ([self.backCard.groupName isEqualToString:cell.group_name.text])
    {
        cell.grpSelectImg.hidden = NO;
    }
    else{
        cell.grpSelectImg.hidden = YES;
    }
    
    // Configure the cell...
    
    return cell;
}

/* 将自己添加到superView上，并且使用指定的frame */
-(void) showTinyGroupView: (UIView *) superView withframe: (CGRect) frame
{
    UIView * view = self.view;
    view.frame = CGRectMake(0, 0, 3, 3);
    [superView addSubview:view];
    
    [UIView animateWithDuration:0.2 animations:^{
        view.frame = frame;
    } completion:^(BOOL finished) {
        /* do nothing */
    }];
    
    return ;
}


-(void) init_data
{
    NSArray * grpArr = [card_manage card_mng].array;
    
    for (cardGroup * grp in grpArr)
    {
        [self.grp_arr addObject:grp];
        /* 监视组内的变化 */
        [self observerGrp:grp];
    }
    
    /* 监视组整体的增多减少 */
    [[card_manage card_mng] addObserver:self forKeyPath:@"array" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

-(void) observerGrp: (cardGroup *) grp
{
    /* 关注组的内部卡片数量变化 */
    [grp addObserver:self forKeyPath:@"cardArr" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    /* 关注组的名称变化 */
    [grp addObserver:self forKeyPath:@"grpName" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

-(void) unObserverGrp: (cardGroup *) grp
{
    /* 取消对组的内部卡片数量的关注 */
    [grp removeObserver:self forKeyPath:@"cardArr"];
    /* 取消对组的组名的关注 */
    [grp removeObserver:self forKeyPath:@"grpName"];
}

-(instancetype) init
{
    self = [super init];
    
    self.grp_arr = [[NSMutableArray alloc]init];
    /* 获取所有的组 */
    [self init_data];
    
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    /* 获得新分组 */
    cardGroup * newGrp = self.grp_arr[indexPath.row];
    
    /* 如果当前分组不能操作(如最后一个)，那么既不能显示，也不能点击，直接将其隐藏 */
    if (!newGrp.operation)
    {
        return;
    }
    
    for (tinyGroupCell * cell in self.tableView.visibleCells)
    {
        if (!cell.grpSelectImg.hidden)
        {
            cell.grpSelectImg.hidden = YES;
        }
    }
    
    /* 卡片所属的分组，，右边显示一个绿色的小勾 */
    tinyGroupCell * newCell = self.tableView.visibleCells[indexPath.row];
    newCell.grpSelectImg.hidden = NO;
    
    /* 调用标准接口，完成切换分组动作 */
    [[card_manage card_mng] moveCardToNewGroup:self.backCard groupName:newGrp.grpName];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"exit_group_list" object:nil]];
}


-(void) kvoGrpIntelChange:(NSString *)keyPath obj:(cardGroup *) grp change: (NSDictionary *)change
{
    NSUInteger row = [self.grp_arr indexOfObject:grp];
    tinyGroupCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    if (!cell)
    {
        NSLog(@"ERROR : %s , can not find cell gor grp %@",__FUNCTION__,
              grp);
        return ;
    }
    
    /* 组内发生了添加card事件 */
    if (NSKeyValueChangeInsertion == [[change valueForKey:@"kind"] intValue])
    {
        cell.group_brief.text = [NSString stringWithFormat:@"%lu条", (unsigned long)grp.cardArr.count];
    }/* 组内发生了删除card事件 */
    else if (NSKeyValueChangeRemoval == [[change valueForKey:@"kind"] intValue])
    {
        cell.group_brief.text = [NSString stringWithFormat:@"%lu条", (unsigned long)grp.cardArr.count];
    }/* 组内其它变化 */
    else
    {
        /* 组名变化 */
        if ([keyPath isEqualToString:@"grpName"])
        {
            cell.group_name.text = grp.grpName;
        }/* 其它变化目前还没有 */
        else
        {
            NSLog(@" ERROR : %s unknown change",__FUNCTION__);
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

/* KVO function， 只要object的keyPath属性发生变化，就会调用此函数*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    /* 组内发生了变化，包括组名变化，组内卡片变少，组内卡片变多（卡片从一个卡片移动到另一个卡片，会先通知一个组卡片变少，再通知一个组卡片变多) */
    if ([object isKindOfClass: [cardGroup class]])
    {
        [self kvoGrpIntelChange: keyPath obj: object change: change];
    }/* 组发生了变化，增加了或删除了一个组，目前还没处理 */
    else if ([object isKindOfClass: [NSArray class]])
    {
        
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) dealloc
{
    for (cardGroup * grp in self.grp_arr)
    {
        /* 取消对组内情况的关注 */
        [self unObserverGrp:grp];
    }
    
    /* 取消对组增多减少的关注 */
    [[card_manage card_mng] removeObserver:self forKeyPath:@"array"];
}

@end
