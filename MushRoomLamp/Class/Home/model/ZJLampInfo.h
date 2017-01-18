//
//  ZJLampInfo.h
//  MushRoomLamp
//
//  Created by SongGang on 7/11/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJLampInfo : NSObject

/** id */
@property (nonatomic,copy) NSString *autoID;
/** 型号 */
@property (nonatomic,copy) NSString *model;
/** 名称 */
@property (nonatomic,copy) NSString *name;
/** 用户ID */
@property (nonatomic,copy) NSString *user_id;
/** 设备ID */
@property (nonatomic,copy) NSString *device_id;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
