//
//  ZJEqsInfoViewController.h
//  MushRoomLamp
//
//  Created by SongGang on 6/24/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJLampInfo.h"

@protocol ZJEqsInfoViewControllerDelegate <NSObject>

/** 选择lamp的事件 */
- (void) chooseLamp:(ZJLampInfo *)lamp;
/** 返回首页事件 */
- (void) returnHome;
@end

@interface ZJEqsInfoViewController : UIViewController
@property(nonatomic,weak) id <ZJEqsInfoViewControllerDelegate> delegate;
@end
