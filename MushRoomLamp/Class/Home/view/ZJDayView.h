//
//  ZJDayView.h
//  MushRoomLamp
//
//  Created by SongGang on 12/7/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZJDayViewDelegate <NSObject>
- (void)cancelBtnClickAction;
- (void)okBtnClickAction:(NSString *)dayStr;
@end

@interface ZJDayView : UIView

@property (nonatomic,copy) NSString *dayStr;
@property (nonatomic,weak) id <ZJDayViewDelegate> delegate;
@end
