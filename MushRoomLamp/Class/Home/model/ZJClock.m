//
//  ZJClock.m
//  MushRoomLamp
//
//  Created by SongGang on 12/8/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJClock.h"

@implementation ZJClock
- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.clockId = [[NSString stringWithFormat:@"%@",dict[@"clockId"]] integerValue];
        self.hour = [[NSString stringWithFormat:@"%@",dict[@"hour"]] integerValue];
        self.minute = [[NSString stringWithFormat:@"%@",dict[@"minute"]] integerValue];
        self.remarks = dict[@"remarks"];
        self.switchStatus = [[NSString stringWithFormat:@"%@",dict[@"switchStatus"]] integerValue];
        self.weekArray = dict[@"week"];
    }
    return self;
}
@end
