//
//  ZJNewAQIView.m
//  MushRoomLamp
//
//  Created by SongGang on 1/10/17.
//  Copyright © 2017 SongGang. All rights reserved.
//

#import "ZJNewAQIView.h"
#import "Constant.h"
#define  PI 3.1415926535898
@interface ZJNewAQIView()
@property (nonatomic,assign) NSInteger aqiValue;
@end

@implementation ZJNewAQIView

- (instancetype)initWithFrame:(CGRect)frame withAQI:(NSInteger )aqi
{
    self = [super initWithFrame:frame];
    if (self) {
        self.aqiValue = aqi;
        [self createView];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat radius;
    if (MAINSCREEN.size.width == 320 ) {
        radius = 40;
    }else if (MAINSCREEN.size.width == 414)
    {
        radius = 40;
    }else if (MAINSCREEN.size.width == 375)
    {
        radius = 40;
    }
    
    //内环
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 240.0/255.0,245.0/255.0,244.0/255.0,1.0);
    CGContextSetLineWidth(context,8.0);
    CGContextAddArc(context, self.width/2,self.height/2, radius ,PI/2 + PI /6, 2 * PI + PI/3, 0);
    CGContextDrawPath(context, kCGPathStroke);
    

    //内圈带颜色的环
    CGFloat in_startAngle = PI/2 + PI /6;
    
    CGFloat in_endAngle ;
    if (_aqiValue > 600) {
        in_endAngle = 5 * PI * 600 / 1800 + 2 * PI/3;
    }else if(_aqiValue == -999){
        in_endAngle = 2 * PI/3;
    }else
    {
        in_endAngle = 5 * PI * _aqiValue / 1800 + 2 * PI/3;
    }
    
    if (_aqiValue < 51) {
        CGContextSetRGBStrokeColor(context, 51.0/255.0,255.0/255.0,51.0/255.0,1.0);
    }else if (_aqiValue >= 51 && _aqiValue < 101 )
    {
        CGContextSetRGBStrokeColor(context, 55.0/255.0,241.0/255.0,51.0/255.0,1.0);
    }else if (_aqiValue >= 101 && _aqiValue < 151)
    {
        CGContextSetRGBStrokeColor(context, 255.0/255.0,153.0/255.0,51.0/255.0,1.0);
    }else if (_aqiValue >= 151 && _aqiValue < 201)
    {
        CGContextSetRGBStrokeColor(context, 255.0/255.0,85.0/255.0,51.0/255.0,1.0);
    }else if (_aqiValue >= 201 && _aqiValue < 301)
    {
        CGContextSetRGBStrokeColor(context, 153.0/255.0,31.0/255.0,112.0/255.0,1.0);
    }else if (_aqiValue >= 301 && _aqiValue < 501)
    {
        CGContextSetRGBStrokeColor(context, 153.0/255.0,31.0/255.0,112.0/255.0,1.0);
    }else if (_aqiValue >= 501)
    {
        CGContextSetRGBStrokeColor(context, 51.0/255.0,10.0/255.0,10.0/255.0,1.0);
    }
    CGContextSetLineWidth(context,8.0);
    CGContextAddArc(context, self.width/2,self.height/2, radius ,in_startAngle,in_endAngle, 0);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void) createView
{
    self.backgroundColor = DDRGBColor(61, 64, 77);
    //室内标签
    UIButton * aqiBtn = [[UIButton alloc] init];
    aqiBtn.width = 40;
    aqiBtn.height = 23;
    aqiBtn.x = (self.width - aqiBtn.width)/2;
    aqiBtn.y = self.height/2 + 45;
    if (_aqiValue > 600) {
        [aqiBtn setTitle:[NSString stringWithFormat:@"%.0ld",(long)_aqiValue] forState:UIControlStateNormal];
    }else if (_aqiValue == -999)
    {
        [aqiBtn setTitle:@"无" forState:UIControlStateNormal];
    }else
    {
        [aqiBtn setTitle:[NSString stringWithFormat:@"%.0ld",(long)_aqiValue] forState:UIControlStateNormal];
    }
    [aqiBtn setTitleColor:DDRGBColor(101,204,255) forState:UIControlStateNormal];
    aqiBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [aqiBtn setBackgroundImage:[UIImage imageNamed:@"aqi_text"] forState:UIControlStateNormal];
    [self addSubview:aqiBtn];
    
}

@end
