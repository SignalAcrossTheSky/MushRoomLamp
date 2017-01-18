//
//  ZJChartView.h
//  MushRoomLamp
//
//  Created by SongGang on 8/11/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJChartView : UIView

- (instancetype)initWithFrame:(CGRect)frame withSelfArray:(NSArray *)selfArray withOtherArray:(NSArray*)otherArray withType:(NSString *)itemtype withAllTime:(NSArray *)array;
@end
