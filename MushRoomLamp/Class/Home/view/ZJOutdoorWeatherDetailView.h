//
//  ZJOutdoorWeatherDetailView.h
//  MushRoomLamp
//
//  Created by SongGang on 11/14/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZJOutdoorWeatherDetailViewDelegate <NSObject>

- (void)closeWeatherView;
@end

@interface ZJOutdoorWeatherDetailView : UIView
@property (nonatomic,weak) id <ZJOutdoorWeatherDetailViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame
                      withDic:(NSDictionary *)dic
                 withDeviceID:(NSInteger )deviceID;
@end
