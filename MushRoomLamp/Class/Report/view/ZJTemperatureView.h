//
//  ZJTemperatureView.h
//  MushRoomLamp
//
//  Created by SongGang on 11/8/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJTemperatureView : UIView

- (instancetype)initWithFrame:(CGRect)frame withInTem:(NSInteger)inTem andOutTem:(NSInteger)outTem withSide:(NSString *)sideStr;
@end
