//
//  ZJClockTableViewCell.h
//  MushRoomLamp
//
//  Created by SongGang on 12/6/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZJClockTableViewCellDelegate <NSObject>
- (void) openAlarmClock:(NSUInteger )row withState:(int ) state;
@end

@interface ZJClockTableViewCell : UITableViewCell
@property(nonatomic,weak) id <ZJClockTableViewCellDelegate> delegate;
@property(nonatomic,copy) NSDictionary *dic;

@property(nonatomic,assign) NSUInteger row;
@end
