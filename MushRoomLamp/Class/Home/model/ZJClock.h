//
//  ZJClock.h
//  MushRoomLamp
//
//  Created by SongGang on 12/8/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZJClock : NSObject

/** clock ID */
@property (nonatomic,assign) NSUInteger clockId;
/** hour */
@property (nonatomic,assign) NSUInteger hour;
/** minute */
@property (nonatomic,assign) NSUInteger minute;
/** remarks */
@property (nonatomic,copy) NSString *remarks;
/**  switchStatus */
@property (nonatomic,assign) NSUInteger switchStatus;
/** week */
@property (nonatomic,copy) NSArray *weekArray;

- (instancetype)initWithDict:(NSDictionary *)dict;
@end
