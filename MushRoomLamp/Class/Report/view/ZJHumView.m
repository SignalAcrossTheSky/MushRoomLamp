//
//  ZJHumView.m
//  MushRoomLamp
//
//  Created by SongGang on 1/9/17.
//  Copyright © 2017 SongGang. All rights reserved.
//

#import "ZJHumView.h"
#import "Constant.h"

@interface ZJHumView()

@property (nonatomic,assign) NSInteger humValue;
@property (nonatomic,assign) NSString *sideStr;
@end
@implementation ZJHumView
- (instancetype)initWithFrame:(CGRect)frame withHum:(NSInteger )humValue withSide:(NSString *)sideStr
{
    self = [super initWithFrame:frame];
    if (self) {
        self.humValue = humValue;
        self.sideStr = sideStr;
        [self createView];
    }
    return self;
}

/**
 * 创建视图
 */
- (void) createView
{
    UIImageView *humBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hum_bg"]];
    humBg.width = 29;
    humBg.height = 54;
    humBg.y = 0;
    [self addSubview:humBg];
    
    //裁剪湿度图片
    CGRect rect;
    if (MAINSCREEN.size.width == 320 || MAINSCREEN.size.width == 375) {
        rect =  CGRectMake(0, 200 - _humValue *2,100,200);
        if (_humValue == -999) {
            rect = CGRectMake(0, 200 - 0 *2,100,200);
        }
        
    }else if (MAINSCREEN.size.width == 414)
    {
        rect =  CGRectMake(0, 300 - _humValue *3,200,300);
        if (_humValue == -999) {
            rect = CGRectMake(0, 300 - 0 *2,100,200);
        }
    }
    CGImageRef imageRef;
    if (_humValue == -999) {
        imageRef = nil;
    }else{
        imageRef = CGImageCreateWithImageInRect([[UIImage imageNamed:@"hum_report"] CGImage], rect);
    }
    UIImage *humimage = [UIImage imageWithCGImage:imageRef];
    
    UIImageView *realHumBg = [[UIImageView alloc] initWithImage:humimage];
    realHumBg.width = 25.3;
    realHumBg.height = _humValue/2;
    if(_humValue == -999)
    {
        realHumBg.height = 0;
    }
    
    realHumBg.y = 51.8 - realHumBg.height;
    [self addSubview:realHumBg];
    
    
    if ([self.sideStr isEqualToString:@"left"]) {
        UIButton * leftTemBtn = [[UIButton alloc] init];
        leftTemBtn.width = 41;
        leftTemBtn.height = 19;
        leftTemBtn.x = 0;
        leftTemBtn.y = (self.height - leftTemBtn.height)/2;
        
        if (_humValue == -999) {
            [leftTemBtn setTitle:@"无" forState:UIControlStateNormal];
        }else{
            [leftTemBtn setTitle:[NSString stringWithFormat:@"%ld%%",(long)_humValue] forState:UIControlStateNormal];
        }
        
        [leftTemBtn setTitleColor:DDRGBColor(26, 178, 255) forState:UIControlStateNormal];
        [leftTemBtn setBackgroundImage:[UIImage imageNamed:@"tem_text_left"] forState:UIControlStateNormal];
        leftTemBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:leftTemBtn];
        
        humBg.x = leftTemBtn.right + 10;
        realHumBg.x = leftTemBtn.right + 10 + 2;
        
    }else if ([self.sideStr isEqualToString:@"right"])
    {
        UIButton * rightTemBtn = [[UIButton alloc] init];
        rightTemBtn.width = 41;
        rightTemBtn.height = 19;
        rightTemBtn.x = self.width - rightTemBtn.width;
        rightTemBtn.y = (self.height - rightTemBtn.height)/2;
        
        if (_humValue == -999) {
            [rightTemBtn setTitle:@"无" forState:UIControlStateNormal];
        }else{
            [rightTemBtn setTitle:[NSString stringWithFormat:@"%ld%%",(long)_humValue] forState:UIControlStateNormal];
        }
        
        [rightTemBtn setTitleColor:DDRGBColor(26, 178, 255) forState:UIControlStateNormal];
        [rightTemBtn setBackgroundImage:[UIImage imageNamed:@"tem_text_right"] forState:UIControlStateNormal];
        rightTemBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:rightTemBtn];
        
        humBg.x = rightTemBtn.left - 10 - humBg.width ;
        realHumBg.x = rightTemBtn.left - 10 - humBg.width + 2;
    }

}
@end
