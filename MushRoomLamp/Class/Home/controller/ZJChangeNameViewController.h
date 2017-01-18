//
//  ZJChangeNameViewController.h
//  MushRoomLamp
//
//  Created by SongGang on 7/27/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZJChangeNameDelegate <NSObject>

- (void)resetName:(NSString *)newName;
@end

@interface ZJChangeNameViewController : UIViewController

@property(nonatomic,weak) id<ZJChangeNameDelegate> delegate;
/** 原来的命名 */
@property(nonatomic,copy) NSString *preName;
/** 设备ID */
@property(nonatomic,copy) NSString *deviceID;
@end
