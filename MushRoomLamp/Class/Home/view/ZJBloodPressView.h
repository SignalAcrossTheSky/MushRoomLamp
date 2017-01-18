//
//  ZJBloodPressView.h
//  MushRoomLamp
//
//  Created by SongGang on 9/18/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZJBloodPressViewDelegate <NSObject>

- (void) closeBloodPressView;
@end

@interface ZJBloodPressView : UIView
@property (nonatomic,weak) id <ZJBloodPressViewDelegate> delegate;

- (void)setStartState;
- (void)setResultStateWithDic:(NSDictionary *)dic;
- (void)setErrorState;
- (void) setLeaveState;
- (void) setMoveState;
@end
