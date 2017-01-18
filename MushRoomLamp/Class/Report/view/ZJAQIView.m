//
//  ZJAQIView.m
//  MushRoomLamp
//
//  Created by SongGang on 11/9/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJAQIView.h"
#import "Constant.h"
#define  PI 3.1415926535898

@interface ZJAQIView()
@property (nonatomic,assign) CGFloat inAQI;
@property (nonatomic,assign) CGFloat outAQI;
@end

@implementation ZJAQIView
- (instancetype)initWithFrame:(CGRect)frame withInAQI:(CGFloat )inAQI andOutAQI:(CGFloat )outAQI
{
    self = [super initWithFrame:frame];
    if(self)
    {
//        if (inAQI > 600) {
//            self.inAQI = 600;
//        }else
//        {
            self.inAQI = inAQI;
//        }
        
//        if (outAQI > 600) {
//            self.outAQI = 600;
//        }else
//        {
            self.outAQI = outAQI;
//        }
        
        [self createView];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat inRadius;
    CGFloat outRadius;
    if (MAINSCREEN.size.width == 320 ) {
        inRadius = 49;
        outRadius = 64;
    }else if (MAINSCREEN.size.width == 414)
    {
        inRadius = 49;
        outRadius = 64;
    }else if (MAINSCREEN.size.width == 375)
    {
        inRadius = 49;
        outRadius = 64;
    }
    
    //内环
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 240.0/255.0,245.0/255.0,244.0/255.0,1.0);
    CGContextSetLineWidth(context,10.0);
    CGContextAddArc(context, self.width/2,self.height/2, inRadius ,PI/2 + PI /6, 2 * PI + PI/3, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    //外环
    CGContextSetRGBStrokeColor(context, 240.0/255.0,245.0/255.0,244.0/255.0,1.0);
    CGContextSetLineWidth(context,10.0);
    CGContextAddArc(context, self.width/2,self.height/2, outRadius ,PI/2 + PI /6, 2 * PI + PI/3, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    //内圈带颜色的环
    CGFloat in_startAngle = PI/2 + PI /6;
    
    CGFloat in_endAngle ;
    if (_inAQI > 600) {
        in_endAngle = 5 * PI * 600 / 1800 + 2 * PI/3;
    }else if(_inAQI == -999){
        in_endAngle = 2 * PI/3;
    }else
    {
        in_endAngle = 5 * PI * _inAQI / 1800 + 2 * PI/3;
    }
    
    if (_inAQI < 51) {
        CGContextSetRGBStrokeColor(context, 51.0/255.0,255.0/255.0,51.0/255.0,1.0);
    }else if (_inAQI >= 51 && _inAQI < 101 )
    {
        CGContextSetRGBStrokeColor(context, 55.0/255.0,241.0/255.0,51.0/255.0,1.0);
    }else if (_inAQI >= 101 && _inAQI < 151)
    {
        CGContextSetRGBStrokeColor(context, 255.0/255.0,153.0/255.0,51.0/255.0,1.0);
    }else if (_inAQI >= 151 && _inAQI < 201)
    {
        CGContextSetRGBStrokeColor(context, 255.0/255.0,85.0/255.0,51.0/255.0,1.0);
    }else if (_inAQI >= 201 && _inAQI < 301)
    {
        CGContextSetRGBStrokeColor(context, 153.0/255.0,31.0/255.0,112.0/255.0,1.0);
    }else if (_inAQI >= 301 && _inAQI < 501)
    {
        CGContextSetRGBStrokeColor(context, 153.0/255.0,31.0/255.0,112.0/255.0,1.0);
    }else if (_inAQI >= 501)
    {
        CGContextSetRGBStrokeColor(context, 51.0/255.0,10.0/255.0,10.0/255.0,1.0);
    }
    CGContextSetLineWidth(context,10.0);
    CGContextAddArc(context, self.width/2,self.height/2, inRadius ,in_startAngle,in_endAngle, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    //外圈带颜色的环
    CGFloat out_startAngle = PI/2 + PI /6;
    CGFloat out_endAngle ;
    if (_outAQI > 600) {
        out_endAngle = 5 * PI * 600 / 1800 + 2 * PI/3;
    }else if (_outAQI == -999)
    {
        out_endAngle = 2 * PI/3;
    }else
    {
        out_endAngle = 5 * PI * _outAQI / 1800 + 2 * PI/3;
    }
    if (_outAQI < 51) {
        CGContextSetRGBStrokeColor(context, 51.0/255.0,255.0/255.0,51.0/255.0,1.0);
    }else if (_outAQI >= 51 && _outAQI < 101 )
    {
        CGContextSetRGBStrokeColor(context, 55.0/255.0,241.0/255.0,51.0/255.0,1.0);
    }else if (_outAQI >= 101 && _outAQI < 151)
    {
        CGContextSetRGBStrokeColor(context, 255.0/255.0,153.0/255.0,51.0/255.0,1.0);
    }else if (_outAQI >= 151 && _outAQI < 201)
    {
        CGContextSetRGBStrokeColor(context, 255.0/255.0,85.0/255.0,51.0/255.0,1.0);
    }else if (_outAQI >= 201 && _outAQI < 301)
    {
        CGContextSetRGBStrokeColor(context, 153.0/255.0,31.0/255.0,112.0/255.0,1.0);
    }else if (_outAQI >= 301 && _outAQI < 501)
    {
        CGContextSetRGBStrokeColor(context, 153.0/255.0,31.0/255.0,112.0/255.0,1.0);
    }else if (_outAQI >= 501)
    {
        CGContextSetRGBStrokeColor(context, 51.0/255.0,10.0/255.0,10.0/255.0,1.0);
    }
    CGContextSetLineWidth(context,10.0);
    CGContextAddArc(context, self.width/2,self.height/2, outRadius ,out_startAngle,out_endAngle, 0);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void) createView
{
    //室内标签
    UIButton * inAQIBtn = [[UIButton alloc] init];
    inAQIBtn.width = 59;
    inAQIBtn.height = 22;
    inAQIBtn.x = (self.width - inAQIBtn.width)/2;
    inAQIBtn.y = self.height/2 + 10;
    if (self.inAQI > 600) {
        [inAQIBtn setTitle:[NSString stringWithFormat:@"室内:%.0f",self.inAQI] forState:UIControlStateNormal];
    }else if (_inAQI == -999)
    {
        [inAQIBtn setTitle:@"无" forState:UIControlStateNormal];
    }else
    {
        [inAQIBtn setTitle:[NSString stringWithFormat:@"室内:%.0f",self.inAQI] forState:UIControlStateNormal];
    }
    [inAQIBtn setTitleColor:DDRGBColor(55, 55, 55) forState:UIControlStateNormal];
    inAQIBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [inAQIBtn setBackgroundImage:[UIImage imageNamed:@"aqi_text_in"] forState:UIControlStateNormal];
    [self addSubview:inAQIBtn];
    
    //室外标签
    UIButton * outAQIBtn = [[UIButton alloc] init];
    outAQIBtn.width = 59;
    outAQIBtn.height = 22;
    outAQIBtn.x = inAQIBtn.x;
    outAQIBtn.y = self.height/2 + 55;
    if (self.outAQI > 600) {
        [outAQIBtn setTitle:[NSString stringWithFormat:@"室外:%.0f",self.outAQI] forState:UIControlStateNormal];
    }else if (_outAQI == -999)
    {
        [outAQIBtn setTitle:@"无" forState:UIControlStateNormal];
    }else
    {
        [outAQIBtn setTitle:[NSString stringWithFormat:@"室外:%.0f",self.outAQI] forState:UIControlStateNormal];
    }
    [outAQIBtn setTitleColor:DDRGBColor(55, 55, 55) forState:UIControlStateNormal];
    outAQIBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [outAQIBtn setBackgroundImage:[UIImage imageNamed:@"aqi_text_out"] forState:UIControlStateNormal];
    [self addSubview:outAQIBtn];
}
@end
