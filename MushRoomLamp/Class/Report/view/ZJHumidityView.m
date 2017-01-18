//
//  ZJHumidityView.m
//  MushRoomLamp
//
//  Created by SongGang on 11/8/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJHumidityView.h"
#import "Constant.h"

@interface ZJHumidityView()
@property (nonatomic,assign) CGFloat inHum;
@property (nonatomic,assign) CGFloat outHum;
@end

@implementation ZJHumidityView
- (instancetype)initWithFrame:(CGRect)frame withInHum:(NSInteger )inHum andOutHum: (NSInteger )outHum
{
    self = [super initWithFrame:frame];
    if (self) {
        self.inHum = inHum;
        self.outHum = outHum;
        [self createView];
    }
    return self;
}

- (void)createView
{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat highHum = _inHum >= _outHum ? _inHum : _outHum;
    CGFloat lowHum = _inHum >= _outHum ?_outHum : _inHum;
    UIImage *hum_high_image = [UIImage imageNamed:@"hum_high"];
    UIImage *hum_low_image = [UIImage imageNamed:@"hum_low"];
    
    //裁剪低湿度图片
    CGRect low_rect;
    if (MAINSCREEN.size.width == 320 || MAINSCREEN.size.width == 375) {
        low_rect =  CGRectMake(0, 200 - lowHum *2,100,200);
        if (lowHum == -999) {
            low_rect = CGRectMake(0, 200 - 0 *2,100,200);
        }

    }else if (MAINSCREEN.size.width == 414)
    {
        low_rect =  CGRectMake(0, 300 - lowHum *3,200,300);
        if (lowHum == -999) {
            low_rect = CGRectMake(0, 300 - 0 *2,100,200);
        }
    }
    CGImageRef low_imageRef;
    if (lowHum == -999) {
        low_imageRef = nil;
    }else{
        low_imageRef = CGImageCreateWithImageInRect([hum_low_image CGImage], low_rect);
    }
    UIImage *sub_low_image = [UIImage imageWithCGImage:low_imageRef];
    
    //裁剪高湿度图片
    CGRect high_rect;
    if (MAINSCREEN.size.width == 320 || MAINSCREEN.size.width == 375) {
        high_rect = CGRectMake(0,200 - highHum *2, 100,200);
        if (highHum == -999) {
            high_rect = CGRectMake(0, 200 - (0)*2,100,200);
        }

    }else if (MAINSCREEN.size.width == 414)
    {
        high_rect = CGRectMake(0,300 - highHum *3, 200,300);
        if (highHum == -999) {
            high_rect = CGRectMake(0, 300 - (-50 + 50)*2,100,200);
        }
    }
    CGImageRef high_imageRef;
    if (highHum == -999) {
        high_imageRef = nil;
    }else{
        high_imageRef = CGImageCreateWithImageInRect([hum_high_image CGImage], high_rect);
    }
    UIImage *sub_high_image = [UIImage imageWithCGImage:high_imageRef];

    
    //湿度背景图
    UIImageView *humBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hum_bg"]];
    humBg.width = 58;
    humBg.height = 109;
    humBg.x = (self.width - humBg.width)/2;
    humBg.y = 0;
    [self addSubview:humBg];
    
    //高湿度图片
    UIImageView *highHumBg = [[UIImageView alloc] initWithImage:sub_high_image];
    highHumBg.width = 50;
    highHumBg.height = highHum;
    if (highHum == -999) {
        highHumBg.height = 0;
    }
    highHumBg.x = (self.width - highHumBg.width)/2;
    highHumBg.y = 105 - highHumBg.height;
    [self addSubview:highHumBg];
    
    //低湿度图片
    UIImageView *lowHumBg = [[UIImageView alloc] initWithImage:sub_low_image];
    lowHumBg.width = 50;
    lowHumBg.height = lowHum;
    if (lowHum == -999) {
        lowHumBg.height = 0;
    }
    lowHumBg.x = (self.width - highHumBg.width)/2;
    lowHumBg.y = 105 - lowHumBg.height;
    [self addSubview:lowHumBg];
    
    //创建左侧室内湿度标签
    UIButton * inHumBtn = [[UIButton alloc] init];
    inHumBtn.width = 41;
    inHumBtn.height = 19;
    if (_inHum >= _outHum) {
        inHumBtn.y = highHumBg.y - 10;
    }else{
        inHumBtn.y = lowHumBg.y - 10;
    }
    
    if (inHumBtn.y < 80) {
        inHumBtn.x = self.width/2 - inHumBtn.width - inHumBtn.y/4 - 15;
    }else
    {
        inHumBtn.x = self.width/2 - inHumBtn.width - inHumBtn.y/4 - 10;
    }
    
    if (_inHum == -999) {
        [inHumBtn setTitle:@"无" forState:UIControlStateNormal];
    }else{
        [inHumBtn setTitle:[NSString stringWithFormat:@"%0.0f℃",_inHum] forState:UIControlStateNormal];
    }
   
    [inHumBtn setTitleColor:DDRGBColor(88, 88, 88) forState:UIControlStateNormal];
    [inHumBtn setBackgroundImage:[UIImage imageNamed:@"tem_text_left"] forState:UIControlStateNormal];
    inHumBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:inHumBtn];
    
    //创建右侧室外湿度标签
    UIButton * outHumBtn = [[UIButton alloc] init];
    outHumBtn.width = 41;
    outHumBtn.height = 19;
    if (_inHum <= _outHum) {
        outHumBtn.y = highHumBg.y - 10;
    }else{
        outHumBtn.y = lowHumBg.y - 10;
    }
    
    if (outHumBtn.y < 80) {
        outHumBtn.x = self.width/2 + outHumBtn.y/4 + 15;
    }else
    {
        outHumBtn.x = self.width/2 + outHumBtn.y/4 + 10;
    }
    
    if (_outHum == -999) {
        [outHumBtn setTitle:@"无" forState:UIControlStateNormal];
    }else{
        [outHumBtn setTitle:[NSString stringWithFormat:@"%0.0f℃",_outHum] forState:UIControlStateNormal];
    }
    [outHumBtn setTitleColor:DDRGBColor(88, 88, 88) forState:UIControlStateNormal];
    outHumBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [outHumBtn setBackgroundImage:[UIImage imageNamed:@"tem_text_right"] forState:UIControlStateNormal];
    [self addSubview:outHumBtn];
}
@end
