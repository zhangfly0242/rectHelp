//
//  card.m
//  reciteHelper
//
//  Created by zhangliang on 2017/4/6.
//  Copyright © 2017年 zhangliang. All rights reserved.
//

#import "card.h"

@implementation card

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.createTime forKey:@"createTime"];
    [aCoder encodeObject:self.headText forKey:@"headText"];
    [aCoder encodeObject:self.detailText forKey:@"detailText"];
    [aCoder encodeObject:self.groupName forKey:@"groupName"];
    [aCoder encodeObject:self.mark forKey:@"mark"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self.createTime = [aDecoder decodeObjectForKey:@"createTime"];
    self.headText = [aDecoder decodeObjectForKey:@"headText"];
    self.detailText = [aDecoder decodeObjectForKey:@"detailText"];
    self.groupName = [aDecoder decodeObjectForKey:@"groupName"];
    self.mark = [aDecoder decodeObjectForKey:@"mark"];
    
    return self;
}

@end
