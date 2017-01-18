//
//  ZJInterface.h
//  MushRoomLamp
//
//  Created by SongGang on 7/6/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJInterfaceCommon.h"

@protocol ZJInterfaceDelegate ;

@interface ZJInterface : NSObject

@property(nonatomic,weak)id<ZJInterfaceDelegate> delegate;

- (void)interfaceWithType:(INTERFACE_TYPE)type param:(NSDictionary *)param;
- (instancetype)initWithDelegate:(id<ZJInterfaceDelegate>)delegate;
@end

@protocol ZJInterfaceDelegate <NSObject>
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error;
@end

