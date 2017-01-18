//
//  ZJTemView.m
//  MushRoomLamp
//
//  Created by SongGang on 1/9/17.
//  Copyright © 2017 SongGang. All rights reserved.
//

#import "ZJTemView.h"
#import "Constant.h"

@interface ZJTemView()
@property (nonatomic,assign) NSInteger temValue;
@property (nonatomic,copy) NSString *sideStr;
@end


@implementation ZJTemView

- (instancetype)initWithFrame:(CGRect)frame withInTem:(NSInteger)temValue withSide:(NSString *)sideStr
{
    self = [super initWithFrame:frame];
    if (self) {
        self.temValue = temValue;
        self.sideStr = sideStr;
        [self createView];
    }
    return self;
}

- (void) createView
{
    UIImageView *temBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tem_bg"]];
    temBg.width = 18;
    temBg.height = 53;
    temBg.y = 0;
    [self addSubview:temBg];
    
    CGRect rect;
    if (MAINSCREEN.size.width == 320 || MAINSCREEN.size.width == 375) {
        rect = CGRectMake(0, 200 - (self.temValue + 50)*2,100,200);
        if (_temValue == -999) {
            rect = CGRectMake(0, 200 ,100,200);
        }
    }else if (MAINSCREEN.size.width == 414)
    {
        rect = CGRectMake(0, 300 - (_temValue + 50)*3,100,300);
        if (_temValue == -999) {
            rect = CGRectMake(0, 300 - (-50 + 50)*3,100,300);
        }
    }
    CGImageRef imageRef;
    if (_temValue == -999) {
        imageRef = nil;
    }else{
        imageRef = CGImageCreateWithImageInRect([[UIImage imageNamed:@"tem_report"] CGImage], rect);
    }
    UIImage *temimage = [UIImage imageWithCGImage:imageRef];

    UIImageView *realTemBg = [[UIImageView alloc] initWithImage:temimage];
    realTemBg.width = 13;
    realTemBg.height = _temValue/2 + 25;
    if(_temValue == -999)
    {
        realTemBg.height = 0;
    }
   
    realTemBg.y = 51.3 - realTemBg.height;
    [self addSubview:realTemBg];


    if ([self.sideStr isEqualToString:@"left"]) {
        UIButton * leftTemBtn = [[UIButton alloc] init];
        leftTemBtn.width = 41;
        leftTemBtn.height = 19;
        leftTemBtn.x = 0;
        leftTemBtn.y = (self.height - leftTemBtn.height)/2;
        
        if (self.temValue == -999) {
             [leftTemBtn setTitle:@"无" forState:UIControlStateNormal];
        }else{
             [leftTemBtn setTitle:[NSString stringWithFormat:@"%ld℃",(long)_temValue] forState:UIControlStateNormal];
        }
       
        [leftTemBtn setTitleColor:DDRGBColor(26, 178, 255) forState:UIControlStateNormal];
        [leftTemBtn setBackgroundImage:[UIImage imageNamed:@"tem_text_left"] forState:UIControlStateNormal];
        leftTemBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:leftTemBtn];
        
        temBg.x = leftTemBtn.right + 10;
        realTemBg.x = leftTemBtn.right + 10 + 2.5;
        
    }else if ([self.sideStr isEqualToString:@"right"])
    {
        UIButton * rightTemBtn = [[UIButton alloc] init];
        rightTemBtn.width = 41;
        rightTemBtn.height = 19;
        rightTemBtn.x = self.width - rightTemBtn.width;
        rightTemBtn.y = (self.height - rightTemBtn.height)/2;
        
        if (self.temValue == -999) {
            [rightTemBtn setTitle:@"无" forState:UIControlStateNormal];
        }else{
            [rightTemBtn setTitle:[NSString stringWithFormat:@"%ld℃",(long)_temValue] forState:UIControlStateNormal];
        }
        
        [rightTemBtn setTitleColor:DDRGBColor(26, 178, 255) forState:UIControlStateNormal];
        [rightTemBtn setBackgroundImage:[UIImage imageNamed:@"tem_text_right"] forState:UIControlStateNormal];
        rightTemBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:rightTemBtn];
        
        temBg.x = rightTemBtn.left - 10 - temBg.width ;
        realTemBg.x = rightTemBtn.left - 10 - temBg.width + 2.5;
    }
}
@end
