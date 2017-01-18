//
//  ZJOutdoorWeatherView.h
//  MushRoomLamp
//
//  Created by SongGang on 11/11/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZJOutdoorWeatherViewDelegate <NSObject>

- (void)showOutdoorWeather;
@end

@interface ZJOutdoorWeatherView : UIView

@property (nonatomic,weak) id <ZJOutdoorWeatherViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect )frame
                      withTem:(CGFloat )temValue
                      withAQI:(CGFloat )aqiValue
                      withHum:(CGFloat )humValue;

- (void) setTem:(NSString* )tem
        withAqi:(NSString* )aqi
        withHum:(NSString* )hum
       withIcon:(UIImage* )temIcon;
@end
