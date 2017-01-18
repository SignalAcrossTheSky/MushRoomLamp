//
//  ZJHomeController.h
//  MushRoomLamp
//
//  Created by SongGang on 6/23/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJBloodPressView.h"
#import "ZJLampInfo.h"

@interface ZJHomeController : UIViewController
/** 血压View*/
@property (nonatomic,strong) ZJBloodPressView *bpView;
/** 滚动视图 */
@property (nonatomic,strong) UIScrollView *scrollView;
/** 创建血压View */
- (void)popBloodPressView;
/**  */
- (void)chooseLamp:(ZJLampInfo *)lamp;

@end
