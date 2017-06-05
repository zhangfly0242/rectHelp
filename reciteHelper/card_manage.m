//
//  card_manage.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/6.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#define US_CORE_DATA (TRUE)
#define US_ICLOUD (NO)
#define CLOUDKIT (FALSE)

#import "DataController.h"
#import "cardMO.h"
#import "card_manage.h"
#import "card.h"
#import "syn_main_thread.h"
#import "icloudManager.h"
#import "cardGroup.h"
#import "cardMO.h"
#import "groupMO.h"
#import "test1ViewController.h"
#import "cloudKitHelper.h"

@implementation card_manage

NSInteger CardSort(card * cd1, card * cd2, void *context)
{
    if (NSOrderedDescending == [cd1.createTime compare: cd2.createTime])
    {
        NSLog(@" NSOrderedAscending  %@  %@",
              cd1.createTime, cd2.createTime);
        return NSOrderedAscending;
    }
    else if (NSOrderedAscending == [cd1.createTime compare: cd2.createTime])
    {
        NSLog(@" NSOrderedDescending  %@  %@",
              cd1.createTime, cd2.createTime);
        return NSOrderedDescending;
    }
    else
        return NSOrderedSame;
}

NSInteger GroupSort(cardGroup * grp1, cardGroup * grp2, void *context)
{
    if ([grp1.grpName isEqualToString:@"未归档"])
    {
        NSLog(@" NSOrderedAscending %@ ",grp1.grpName);
        return NSOrderedAscending;
    }
    
    if ([grp2.grpName isEqualToString:@"未归档"])
    {
        NSLog(@" NSOrderedAscending %@ ",grp1.grpName);
        return NSOrderedDescending;
    }
    
    if ([grp1.grpName isEqualToString:@"添加新组"])
    {
        NSLog(@" NSOrderedDescending %@ ",grp1.grpName);
        return NSOrderedDescending;
    }
    
    /* zhang-attention : 注意这里可能“添加新组”出现在grp2, 这样写才能保证和所有的都比较到 */
    if ([grp2.grpName isEqualToString:@"添加新组"])
    {
        NSLog(@" NSOrderedDescending %@ ",grp1.grpName);
        return NSOrderedAscending;
    }
    
    if (NSOrderedDescending == [grp1.grpName compare: grp2.grpName])
    {
        return NSOrderedAscending;
    }
    else if (NSOrderedAscending == [grp1.grpName compare: grp2.grpName])
    {
        return NSOrderedDescending;
    }
    else
        return NSOrderedSame;
}

/* 从本地数据库读取数据 , 保存到本地 , 并从icloud请求数据*/
-(void) init_data_core_data
{
    /* 从本地数据库读取数据 , 保存到本地 */
    NSMutableArray * persistentData = [[DataController dataController] FetchAllData];
    
#if CLOUDKIT
    
    NSLog(@" add cloudkit observe");
    /* 关注cloudKIT的获取数据的状态 */
    [[cloudKitHelper KIT] addObserver:self forKeyPath:@"getDataDone" options:NSKeyValueObservingOptionNew context:nil];
    
    /* app一启动时 触发cloudKit初始化时获取数据 */
    [[cloudKitHelper KIT] getAllData];
#endif
    
    if (!persistentData || 0 == persistentData.count)
    {
        /* 创建一个“未归档”分组 */
        [self createNewGrp: @"未归档"];
        
        /* 创建一个card */
        card * oneCd= [[card alloc] init];
        oneCd.createTime = @"2017年3月24日 08时00分00秒";
        oneCd.headText = @"关于风";
        oneCd.detailText = @" 使用说明 : \n   1, 在上方进行“收藏” ，“备注”， 以及开启“双框”模式； \n   2, 在中间区域是内容区域，左滑右滑，你可以看到“原文”，“模式一”，“模式二”，其中模式一和模式二，都是预先扣空的文本； \n   3, 在最下边一排，你可以看到“大”和“小”，用于放大和缩小字体；在右下角的左箭头，用来将扣空减小，而右箭头用来将扣空放大。\n   当你对记忆的内容的熟练后，可以不断将扣空放大，一次次加大联想的难度，相信会对你很有帮助。\n\n   finally, enjoy it~";
        oneCd.mark = @"自然*诗*随想";
        
        [self createNewCard:oneCd toGrp:@"未归档"];
        
        /* 创建一个全新的分组,  */
        [self createNewGrp: @"添加新组"];
    }
    else
    {
        for (cardGroup * temGrp in persistentData)
        {
            if ([temGrp.grpName isEqualToString:@"添加新组"])
            {
                temGrp.operation = NO;
            }
            else
            {
                temGrp.operation = YES;
            }

            for (card * temCd in temGrp.cardArr)
            {
                /* 观察这个卡片 */
                [self oberveCard:temCd];
                /* 将这个卡片加入到分组中 */
              //  [newGrp.cardArr addObject:newCard];
            }
            
            [temGrp.cardArr sortUsingFunction:CardSort context:nil];
            /* 观察这个分组 */
            [self oberveGroup:temGrp];
        }
        
        [persistentData sortUsingFunction:GroupSort context:nil];
        
        for (cardGroup * grp in persistentData)
        {
            NSLog(@" after sort, grp %@",grp.grpName);
        }
        self.array = persistentData;
    }

    /* 排序 , 按创建时间排好序*/
   // [self.array sortUsingFunction:intSort context:NULL];

// core data不需要监听变化，由
//#if US_CORE_DATA
//    /* CORE DATA 监听core data数据量的变化 */
//    [self addObserver:[DataController dataController]
//            forKeyPath:@"cardCount"
//               options:NSKeyValueObservingOptionNew
//               context:nil];
//#endif
    
#if US_ICLOUD
    [[icloudManager icloud_mng] readFromIcloud];
#endif
        
    return ;
}

-(void) oberveCard: (card *)oneCd
{
    /* 自己 监听数据的变化 */
    [oneCd addObserver:self
            forKeyPath:@"createTime"
               options:NSKeyValueObservingOptionNew
               context:nil];
    
    [oneCd addObserver:self
            forKeyPath:@"headText"
               options:NSKeyValueObservingOptionNew
               context:nil];
    
    [oneCd addObserver:self
            forKeyPath:@"detailText"
               options:NSKeyValueObservingOptionNew
               context:nil];
    
    [oneCd addObserver:self
            forKeyPath:@"mark"
               options:NSKeyValueObservingOptionNew
               context:nil];
    
    return ;
}

-(void) unOberveCard: (card *)card
{
    /* 取消对card的监听 */
    [card removeObserver:self forKeyPath:@"createTime"];
    [card removeObserver:self forKeyPath:@"headText"];
    [card removeObserver:self forKeyPath:@"detailText"];
    [card removeObserver:self forKeyPath:@"mark"];
    return ;
}

-(void) oberveGroup: (cardGroup *)oneGrp
{
    /* 监听分组的变化 */
    [oneGrp addObserver:self
            forKeyPath:@"grpName"
               options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
               context:nil];
    
    return ;
}

/* 处理组名的变化，(组的创建删除，组内卡片的创建删除移动，都是通过自己提供的接口来做的，不需要监听) */
-(void) kvoHandleGrp: (cardGroup *)group keyPath:(NSString *)keyPath change:(NSDictionary *)change
{
    if ([keyPath isEqualToString:@"grpName"])
    {
        if ([[change valueForKey:@"old"] isEqualToString:@"添加新组"])
        {
            /* 新的组名还是 “添加新组” ，直接返回，不作任何动作*/
            if ([[change valueForKey:@"new"] isEqualToString:@"添加新组"])
            {
                return;
            }
            
            group.operation = YES;
            [[DataController dataController] EditOneGroup:group oldGroupName:[change valueForKey:@"old"]];
            
            /* 创建一个全新的分组,  */
            [self createNewGrp: @"添加新组"];
        }
    }
    else{
        NSLog(@" ERROR : %s , un support keyPath %@ ",__FUNCTION__, keyPath);
    }
}

/* 判断当前分组，是否同名的分组(根据组名判断是同样的分组） */
-(BOOL) containGrpWithSameGrpName: (NSString *) grpName
{
    for (cardGroup * grp in self.array)
    {
        if ([grp.grpName isEqualToString:grpName])
        {
            return YES;
        }
    }
    
    return NO;
}

/* 判断当前卡片，是否有同一秒创建的卡片(根据创建时间判断是同样的卡片) */
-(BOOL) containCardWithSameCreateTime: (NSString *) createTime
{
    for (cardGroup * grp in self.array)
    {
        for (card * cd in grp.cardArr)
        {
            if ([cd.createTime isEqualToString:createTime])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

-(void) kvoHandleCloudKit:(NSString *)keyPath change:(NSDictionary *)change
{
    NSArray * grpArr = [cloudKitHelper KIT].grpArr;
    NSArray * cardArr = [cloudKitHelper KIT].cardArr;
    NSString * beongGrpName = nil;
    BOOL found = FALSE;

    /* 添加新的分组 */
    for (cardGroup * grp in grpArr)
    {
        if (![self containGrpWithSameGrpName:grp.grpName])
        {
            [self createNewGrp:grp.grpName];
        }
    }
    
    NSInteger i = 0;
    while (TRUE) {
        
        /* 处理完毕，跳出 */
        if (i >= self.array.count)
        {
            break;
        }
        
        cardGroup * grp = self.array[i];
        
        /* 删除不存在的分组 */
        found = FALSE;
        for (cardGroup * grpTemp in grpArr)
        {
            if ([grp.grpName isEqualToString:grpTemp.grpName])
            {
                found = TRUE;
                break;
            }
        }
        
        /* 没找到，则删除该分组 */
        if (!found)
        {
            [self deleteGrp: grp];
            // 此时不需要i++, 因为删除后，下个元素的位置就是本元素的位置，不需要i++来访问下一个元素。
        }
        else{
            i++;
        }
    }

    /* 添加新卡片 */
    for (card * cd in cardArr)
    {
        if (![self containCardWithSameCreateTime:cd.createTime])
        {
            /* 找到所属的分组 */
            for (cardGroup * grp in self.array)
            {
                if ([grp.grpName isEqualToString:cd.groupName])
                {
                    beongGrpName = cd.groupName;
                    break;
                }
            }
            
            /* 创建新卡片 */
            card * cdAdd = [[card alloc]init];
            cdAdd.createTime = cd.createTime;
            cdAdd.headText = cd.headText;
            cdAdd.detailText = cd.detailText;
            cdAdd.mark = cd.mark;

            
            NSLog(@" kvoHandleCloudKit grpName %@ ", beongGrpName);
            /* 添加到对应的分组中 */
            [self createNewCard:cd toGrp:beongGrpName];
        }
    }
    
    /* 删除每个分组内多余的卡片 */
    for (cardGroup * grp in self.array)
    {
        NSInteger i = 0;
        while (TRUE) {
            /* 处理完毕，跳出 */
            if (i >= grp.cardArr.count)
            {
                break;
            }
            
            card * cd = grp.cardArr[i];
            
            /* 删除不存在的分组 */
            found = FALSE;
            for (card * cdTemp in cardArr)
            {
                if ([cd.createTime isEqualToString:cdTemp.createTime])
                {
                    found = TRUE;
                    break;
                }
            }
            
            /* 没找到，则删除该分组 */
            if (!found)
            {
                [self deleteCard:cd];
                // 此时不需要i++, 因为删除后，下个元素的位置就是本元素的位置，不需要i++来访问下一个元素。
            }
            else{
                i++;
            }
        }
    }
}

/* KVO function， 只要object的keyPath属性发生变化，就会调用此函数*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[cardGroup class]])
    {
        [self kvoHandleGrp:object keyPath:keyPath change:change];
    }
    else if ([object isKindOfClass:[cloudKitHelper class]])
    {
        NSLog(@" cloudKit kvo notify ");
        [self kvoHandleCloudKit:keyPath change:change];
    }
    
#if US_ICLOUD
    if ([object isKindOfClass: [card class]])
    {
        /* 存储icloud */
        [[icloudManager icloud_mng] saveToIcloud : [card_manage card_mng]];
    }
    else{
        NSLog(@"ERROR : %s , unknown type",__FUNCTION__);
    }
#endif
    
    return ;
}

/* 返回自己的单例 */
+(instancetype) card_mng
{
    static card_manage * it_self = nil;
    if (!it_self)
    {
        it_self = [[card_manage alloc] init];
        it_self.array = [[NSMutableArray alloc]init];
        it_self.grpCountLast = 0;
        it_self.grpCount = 0;
        /* 从 core data获得原始数据 */
        [it_self init_data_core_data];
    }
    
    return it_self;
}

/* 系统启动时，业务模块可能要求返回所有数据 */
-(NSArray *)allGrp
{
    return self.array;
}

/* 增加一个card到一个分组中 */
-(void) createNewCard : (card *) cd toGrp:(NSString *) grpName
{
    cardGroup * belongGrp = nil;
 
    /* 设置card默认字体大小 */
    cd.word_size = 16.0;
    /* 设置card默认隔空间隔 */
    cd.empty_jump = 2;
    /* 设置card默认隔空间隔 */
    cd.empty_size = 2;
    
    for (cardGroup * grp in self.array)
    {
        if ([grp.grpName isEqualToString: grpName])
        {
            belongGrp = grp;
            break ;
        }
    }
    
    if (!belongGrp)
    {
        NSLog(@"ERROR : %s , can not find group with group name[%@]",__FUNCTION__,belongGrp.grpName);
        return ;
    }
    /* 设置新card */
    cd.groupName = grpName;
    /* 设置完后将新card添加到分组中 */
    [[belongGrp mutableArrayValueForKey:@"cardArr"] insertObject:cd atIndex:0];
    /* 最后观察新card , 仅关注内容的变化，card增删，或者切换组，都是通过自己的api来做的，不需要关注*/
    [self oberveCard:cd];
    
    /* 通用做法 : 底层数据创建初始化好后，再修改改值使得kvo通知上层页面更新，和删除时的顺序是反的(先更新上层视图，再更新底层数据）。 */
    self.addCard = cd;

    /* 最后通知core data创建新card */
    [[DataController dataController]InsertOneCard:cd toGroup:belongGrp.grpName];
    
#if CLOUDKIT
    [[cloudKitHelper KIT] saveAllToCloudKit];
#endif
    
#if US_ICLOUD
    /* 存储icloud */
    [[icloudManager icloud_mng] saveToIcloud : [card_manage card_mng]];
#endif
}

/* 删除一个card */
-(void) deleteCard : (card *) card
{
    cardGroup * belongGrp = nil;
    for (cardGroup * grp in self.array)
    {
        if ([grp.grpName isEqualToString:card.groupName])
        {
            belongGrp = grp;
            break ;
        }
    }
    
    if (!belongGrp)
    {
        NSLog(@"ERROR : %s , can not find group with group name[%@]",__FUNCTION__,belongGrp.grpName);
        return ;
    }
    
    /* 如果没有，则不需要删除 */
    if (![belongGrp.cardArr containsObject:card])
    {
        NSLog(@" ERROR : %s , delete card[%@], it is not in card group[%@]",
              __FUNCTION__, card.detailText, belongGrp.grpName);
        return ;
    }
    
    /* 通用做法 :删除时: 先设置该值，通知kvo进行上层的视图更新，然后再处理底层的数据的更新。 */
    self.deleteCard = card;
    
    /* zhang-attention : 对象被删除，需要移除对其的观察 */
    [self unOberveCard: card];
    
    /* 通过这种方法删除 */
    [[belongGrp mutableArrayValueForKey:@"cardArr"] removeObject:card];
    
    /* 从core data中删除 */
    [[DataController dataController] DeleteOneCard:card];
    
#if CLOUDKIT
    [[cloudKitHelper KIT] saveAllToCloudKit];
#endif
    
#if US_ICLOUD
    /* 存储icloud */
    [[icloudManager icloud_mng] saveToIcloud : [card_manage card_mng]];
    // [[syn_main_thread manager]try_send_test];
#endif
    
}

/* 将一个card移动到新的分组中 , 内部会进行在分组间移动的操作，以及改变card中组名的操作*/
-(void) moveCardToNewGroup:(card *)cd groupName:(NSString *)newGrpName
{
    cardGroup * oldGrp = nil;
    cardGroup * newGrp = nil;
    NSString * oldGrpName = nil;
    
    oldGrpName = cd.groupName;
    for (cardGroup * grp in self.array)
    {
        if ([grp.grpName isEqualToString:cd.groupName])
        {
            oldGrp = grp;
            break ;
        }
    }
    
    if (!oldGrp)
    {
        NSLog(@" ERROR : %s can not find old grp with grp name %@",__FUNCTION__,
              cd.groupName);
    }
    
    for (cardGroup * grp in self.array)
    {
        if ([grp.grpName isEqualToString:newGrpName])
        {
            newGrp = grp;
            break ;
        }
    }
    
    if (!newGrp)
    {
        NSLog(@" ERROR : %s can not find new grp with grp name %@",__FUNCTION__, newGrpName);
    }
    
    [[oldGrp mutableArrayValueForKey:@"cardArr"] removeObject:cd];
    
    [[newGrp mutableArrayValueForKey:@"cardArr"] addObject:cd];
    
    cd.groupName = newGrpName;
    [[DataController dataController]moveOneCard:cd fromOldGroup:oldGrpName toGroup:newGrpName];
    [test1ViewController itSelf].textField.text = [[test1ViewController itSelf].textField.text stringByAppendingString:@"1x1x"];
    
#if CLOUDKIT
    [[cloudKitHelper KIT] saveAllToCloudKit];
#endif
}

/* 创建一个新分组 */
-(void) createNewGrp:(NSString *)name
{
    for (cardGroup * grp in self.array)
    {
        if ([grp.grpName isEqualToString: name])
        {
            NSLog(@"ERROR : add group failed, there is already have a group with %@",name);
            return;
        }
    }
    
    /* 创建分组 */
    cardGroup * newGrp = [[cardGroup alloc]init];
    newGrp.grpName = name;
    
    if ([name isEqualToString:@"添加新组"])
    {
        newGrp.operation = NO;
    }
    else{
        newGrp.operation = YES;
    }
    
    /* 保存新group */
    [[self mutableArrayValueForKey:@"array"] addObject:newGrp];
    /* 观察新group */
    [self oberveGroup:newGrp];
    
    /* core data创建 */
    [[DataController dataController]InsertOneGrp:newGrp];
    
    self.addGrp = newGrp;
    
#if CLOUDKIT
    [[cloudKitHelper KIT] saveAllToCloudKit];
#endif
}

/* 删除一个分组 */
-(void) deleteGrp : (cardGroup *) grp
{
    if (![self.array containsObject:grp])
    {
        return ;
    }
    
    /* 第一步，修改标记，记录最近删除节点是哪个，触发界面进行更新 */
    self.deleteGrp = grp;
    
    /* 第二步 ，开始正式删除，将组内所有的卡片移动到“未归档”分组 */
    for (card * cd in grp.cardArr)
    {
        [self moveCardToNewGroup:cd groupName:@"未归档"];
    }
    
    /* 第二步，进行删除卡片的后续处理 */
    /* 通过 cardCountLast和cardCount的比较，observe可以判断是发生了添加还是删除 */
    self.grpCountLast = self.grpCount;
    self.grpCount --;
    
    [[self mutableArrayValueForKey:@"array"] removeObject:grp];
    NSLog(@" delete grp %@ ",grp.grpName);
    
    /* zhang-attention : 对象被删除，需要移除观察者 */
    [[card_manage card_mng].deleteGrp removeObserver:self forKeyPath:@"grpName"];
    
    /* core data删除 */
    [[DataController dataController] DeleteOneGrp:grp];
    
#if CLOUDKIT
    [[cloudKitHelper KIT] saveAllToCloudKit];
#endif
    
#if US_ICLOUD
    /* 存储icloud */
    [[icloudManager icloud_mng] saveToIcloud : [card_manage card_mng]];
#endif
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeInteger:self.grpCount forKey:@"cardCount"];
    [aCoder encodeInteger:self.grpCountLast forKey:@"cardCountLast"];
    [aCoder encodeObject:self.deleteGrp forKey:@"deleteCd"];
    [aCoder encodeObject:self.array forKey:@"array"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self.grpCount = [aDecoder decodeIntegerForKey:@"cardCount"];
    self.grpCountLast = [aDecoder decodeIntegerForKey:@"cardCountLast"];
    self.deleteGrp = [aDecoder decodeObjectForKey:@"deleteCd"];
    self.array = [aDecoder decodeObjectForKey:@"array"];

    return self;
}

//-(void)insertObject:(id)object inArrayAtIndex:(NSUInteger)index //这个是代表property名字，就是上面定义的array，系统会自动生成，要根据自己定义的属性名字改变。
//
//{
//    [self.array insertObject:object atIndex:index];
//}

//-(void)removeObjectFromArrayAtIndex:(NSUInteger)index
//
//{
//    [self.array removeObjectAtIndex:index];
//    
//}


@end
