//
//  ZJOutdoorWeatherView.m
//  MushRoomLamp
//
//  Created by SongGang on 11/11/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJOutdoorWeatherView.h"
#import "Constant.h"
#import "UIImage+Size.h"

@interface ZJOutdoorWeatherView()
{
    int flag;
    NSString* humValue;
    NSString* aqiValue;
    NSString* temValue;
}
@property (nonatomic,strong) UIButton *weatherBtn;
@property (nonatomic,strong) UIImage *humImage;
@property (nonatomic,strong) UIImage *aqiImage;
@property (nonatomic,strong) UIImage *temImage;
@end

@implementation ZJOutdoorWeatherView
- (instancetype)initWithFrame:(CGRect )frame
                      withTem:(CGFloat )temVal
                      withAQI:(CGFloat )aqiVal
                      withHum:(CGFloat )humVal
{
    self = [super initWithFrame:frame];
    if (self) {
        flag = 0;
        [self createOutdoorBackground];
       
        NSTimer * timer=[NSTimer scheduledTimerWithTimeInterval:5
                                               target:self
                                             selector:@selector(showAnimation)
                                             userInfo:nil
                                              repeats:YES];
        _humImage = [UIImage imageNamed:@"outdoor_hum"];
        _aqiImage = [UIImage imageNamed:@"outdoor_aqi"];
        _temImage = [UIImage imageNamed:@"sunny"];
        humValue = @"--";
        aqiValue = @"--";
        temValue = @"--";
    }
    return self;
}

/**
 * 创建底部背景 和  按钮
 */
- (void)createOutdoorBackground
{
    UIView *background = [[UIView alloc] init];
    background.x = 0;
    background.y = 0;
    background.width = self.width;
    background.height = self.height;
    background.backgroundColor = DDRGBAColor(71, 143, 178, 0.1);
    background.layer.cornerRadius = 4;
    [self addSubview:background];
    
    UIButton * outdoorBtn = [[UIButton alloc] init];
    outdoorBtn.x = 0;
    outdoorBtn.y = 0;
    outdoorBtn.width = self.width;
    outdoorBtn.height = self.height;
    outdoorBtn.layer.cornerRadius = 4;
    outdoorBtn.backgroundColor = DDRGBAColor(71, 143, 178, 0.1);
    [outdoorBtn setTitle:@"天气预报" forState:UIControlStateNormal];
    [outdoorBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
    outdoorBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    outdoorBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    self.weatherBtn = outdoorBtn;
    [outdoorBtn addTarget:self action:@selector(outdoorWeatherBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [background addSubview:outdoorBtn];
}

-(void)showAnimation{
    if (flag == 0) {
        [self.weatherBtn setTitle:@"天气预报" forState:UIControlStateNormal];
        [self.weatherBtn setImage:nil forState:UIControlStateNormal];
    }else if (flag == 1)
    {
        [self.weatherBtn setTitle:temValue forState:UIControlStateNormal];
        [self.weatherBtn setImage:self.temImage forState:UIControlStateNormal];

    }else if (flag == 2)
    {
        [self.weatherBtn setTitle:humValue forState:UIControlStateNormal];
        [self.weatherBtn setImage:self.humImage forState:UIControlStateNormal];

    }else if (flag == 3)
    {
        [self.weatherBtn setTitle:aqiValue forState:UIControlStateNormal];
        [self.weatherBtn setImage:self.aqiImage forState:UIControlStateNormal];
        flag = -1;
    }
    flag ++;
    [UIView beginAnimations:@"ShowArrow" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideAnimation)];
    self.weatherBtn.alpha = 0;
    [UIView commitAnimations];
}


- (void)hideAnimation
{
    if (flag == 0) {
        [self.weatherBtn setTitle:@"天气预报" forState:UIControlStateNormal];
        [self.weatherBtn setImage:nil forState:UIControlStateNormal];
    }else if (flag == 1)
    {
        [self.weatherBtn setTitle:temValue forState:UIControlStateNormal];
        [self.weatherBtn setImage:self.temImage forState:UIControlStateNormal];
        
    }else if (flag == 2)
    {
        [self.weatherBtn setTitle:humValue forState:UIControlStateNormal];
        [self.weatherBtn setImage:self.humImage forState:UIControlStateNormal];
        
    }else if (flag == 3)
    {
        [self.weatherBtn setTitle:aqiValue forState:UIControlStateNormal];
        [self.weatherBtn setImage:self.aqiImage forState:UIControlStateNormal];
    }
    
    [UIView beginAnimations:@"HideArrow" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:2.0];
    [UIView setAnimationDelay:0];
    self.weatherBtn.alpha = 1.0;
    [UIView commitAnimations];
}

/**
 *  户外天气按钮点击事件
 */
- (void) outdoorWeatherBtnClickAction
{
    if([_delegate respondsToSelector:@selector(showOutdoorWeather)])
    {
        [_delegate showOutdoorWeather];
    }
}

- (void)setTem:(NSString *)tem withAqi:(NSString *)aqi withHum:(NSString *)hum withIcon:(UIImage *)temIcon
{
    self.temImage = [UIImage scaleToSize:temIcon size:CGSizeMake(14, 14)] ;
    temValue = tem;
    aqiValue = aqi;
    humValue = hum;
}
@end
