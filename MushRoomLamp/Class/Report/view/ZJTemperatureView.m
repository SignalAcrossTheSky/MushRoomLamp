//
//  ZJTemperatureView.m
//  MushRoomLamp
//
//  Created by SongGang on 11/8/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJTemperatureView.h"
#import "Constant.h"

@interface ZJTemperatureView()
@property (nonatomic,assign) CGFloat inTem;
@property (nonatomic,assign) CGFloat outTem;
@property (nonatomic,copy) NSString *sideStr;
@end

@implementation ZJTemperatureView
- (instancetype)initWithFrame:(CGRect)frame withInTem:(NSInteger)inTem andOutTem:(NSInteger)outTem withSide:(NSString *)sideStr
{
    self = [super initWithFrame:frame];
    if (self) {
        self.inTem = inTem;
        self.outTem = outTem;
        self.sideStr = sideStr;
        [self createView];
    }
    return self;
}

- (void)createView
{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat highTem = _inTem >= _outTem ? _inTem : _outTem;
    CGFloat lowTem = _inTem <= _outTem ? _inTem : _outTem;
    UIImage *tem_high_image = [UIImage imageNamed:@"tem_high"];
    UIImage *tem_low_image = [UIImage imageNamed:@"tem_low"];
    
    //裁剪低温图片
    CGRect low_rect;
    if (MAINSCREEN.size.width == 320 || MAINSCREEN.size.width == 375) {
        low_rect = CGRectMake(0, 200 - (lowTem + 50)*2,100,200);
        if (lowTem == -999) {
            low_rect = CGRectMake(0, 200 - (-50 + 50)*2,100,200);
        }
    }else if (MAINSCREEN.size.width == 414)
    {
        low_rect = CGRectMake(0, 300 - (lowTem + 50)*3,100,300);
        if (lowTem == -999) {
            low_rect = CGRectMake(0, 300 - (-50 + 50)*3,100,300);
        }
    }
    CGImageRef low_imageRef;
    if (lowTem == -999) {
      low_imageRef = nil;
    }else{
      low_imageRef = CGImageCreateWithImageInRect([tem_low_image CGImage], low_rect);
    }
    UIImage *sub_low_image = [UIImage imageWithCGImage:low_imageRef];
    
    //裁剪高温图片
    CGRect high_rect;
    if (MAINSCREEN.size.width == 320 || MAINSCREEN.size.width == 375) {
        high_rect = CGRectMake(0,200 - (highTem + 50)*2, 100,200);
        if (highTem == -999) {
            high_rect = CGRectMake(0, 200 - (-50 + 50)*2,100,200);
        }
    }else if (MAINSCREEN.size.width == 414)
    {
        high_rect = CGRectMake(0,300 - (highTem + 50)*3, 100,300);
        if (highTem == -999) {
            high_rect = CGRectMake(0, 300 - (-50 + 50)*2,100,200);
        }
    }
    CGImageRef high_imageRef;
    if (highTem == -999) {
        high_imageRef = nil;
    }else{
        high_imageRef = CGImageCreateWithImageInRect([tem_high_image CGImage], high_rect);
    }
    UIImage *sub_high_image = [UIImage imageWithCGImage:high_imageRef];

    //温度背景图
    UIImageView *temBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tem_bg"]];
    temBg.width = 36;
    temBg.height = 107;
    temBg.x = (self.width - temBg.width)/2;
    temBg.y = 0;
    [self addSubview:temBg];
    
    //高温图片
    UIImageView *highTemBg = [[UIImageView alloc] initWithImage:sub_high_image];
    highTemBg.width = 27;
    highTemBg.height = highTem + 50;
    if(highTem == -999)
    {
        highTemBg.height = -50 + 50;
    }
    highTemBg.x = (self.width - highTemBg.width)/2;
    highTemBg.y = 103 - highTemBg.height;
    [self addSubview:highTemBg];
    
    
    //低温度图片
    UIImageView *lowTemBg = [[UIImageView alloc] initWithImage:sub_low_image];
    lowTemBg.width = 27;
    lowTemBg.height = lowTem + 50;
    if (lowTem == -999) {
        lowTemBg.height = 0;
    }
    lowTemBg.x = (self.width - lowTemBg.width)/2;
    lowTemBg.y = 103 - lowTemBg.height;
    [self addSubview:lowTemBg];
    
    //创建左侧室内温度标签
    UIButton * inTemBtn = [[UIButton alloc] init];
    inTemBtn.width = 41;
    inTemBtn.height = 19;
    inTemBtn.x = highTemBg.left - inTemBtn.width - 2;

    if (_inTem >= _outTem) {
        inTemBtn.y = highTemBg.y - 10;
    }else{
        inTemBtn.y = lowTemBg.y - 10;
    }

    if(_inTem == -999)
    {
       [inTemBtn setTitle:@"无" forState:UIControlStateNormal];
    }else
    {
        [inTemBtn setTitle:[NSString stringWithFormat:@"%0.0f℃",_inTem] forState:UIControlStateNormal];
    }
    [inTemBtn setTitleColor:DDRGBColor(88, 88, 88) forState:UIControlStateNormal];
    [inTemBtn setBackgroundImage:[UIImage imageNamed:@"tem_text_left"] forState:UIControlStateNormal];
    inTemBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    
    //创建右侧室外温度标签
    UIButton * outTemBtn = [[UIButton alloc] init];
    outTemBtn.width = 41;
    outTemBtn.height = 19;
    outTemBtn.x = highTemBg.right;
    if (_inTem <= _outTem) {
        outTemBtn.y = highTemBg.y - 10;
    }else{
        outTemBtn.y = lowTemBg.y - 10;
    }
    if (_outTem == -999) {
        [outTemBtn setTitle:@"无" forState:UIControlStateNormal];
    }else{
        [outTemBtn setTitle:[NSString stringWithFormat:@"%0.0f℃",_outTem] forState:UIControlStateNormal];
    }
    [outTemBtn setTitleColor:DDRGBColor(88, 88, 88) forState:UIControlStateNormal];
    outTemBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [outTemBtn setBackgroundImage:[UIImage imageNamed:@"tem_text_right"] forState:UIControlStateNormal];
   
    if ([_sideStr isEqualToString:@"left"]) {
        [self addSubview:inTemBtn];
    }else{
        [self addSubview:outTemBtn];
    }
}

@end
