//
//  ZJLampInfo.m
//  MushRoomLamp
//
//  Created by SongGang on 7/11/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJLampInfo.h"

@implementation ZJLampInfo

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
//        self.autoID = dict[@"id"];
//        self.model = dict[@"model"];
        self.name = dict[@"deviceName"];
        self.user_id = dict[@"userId"];
        self.device_id =dict[@"deviceId"];
    }
    return self;
}

+ (instancetype)myAccountWithDict: (NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

@end
