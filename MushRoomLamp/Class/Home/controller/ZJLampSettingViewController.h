//
//  ZJLampSettingViewController.h
//  MushRoomLamp
//
//  Created by SongGang on 7/1/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZJLampSettingViewControllerDelegate<NSObject>

/** 改名字的代理方法 */
- (void) changeName: (NSString *)newName withRow:(NSInteger )row;
@end

@interface ZJLampSettingViewController : UIViewController
/** 设备名称 */
@property (nonatomic,copy) NSString *deviceName;
/** 唯一ID */
@property (nonatomic,copy) NSString *autoID;
/** row */
@property (nonatomic,assign) NSInteger row;
/** 设别ID */
@property (nonatomic,copy) NSString * device_id;
/** 代理 */
@property (nonatomic,weak)id <ZJLampSettingViewControllerDelegate> delegate;
@end
