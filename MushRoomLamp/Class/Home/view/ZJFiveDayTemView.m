//
//  ZJFiveDayTemView.m
//  MushRoomLamp
//
//  Created by SongGang on 11/15/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJFiveDayTemView.h"
#import "Constant.h"

@interface ZJFiveDayTemView()

@property (nonatomic,copy) NSArray *highTem;
@property (nonatomic,copy) NSArray *lowTem;
@end
@implementation ZJFiveDayTemView

- (instancetype) initWithFrame:(CGRect)frame
                   withHighTem:(NSArray *)highTem
                    withLowTem:(NSArray *)lowTem
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.highTem = highTem;
        self.lowTem = lowTem;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGPoint highPoints[5];
    CGPoint lowPoints[5];
    CGPoint preTwoHighPoints[2];
    CGPoint aftFourHighPoints[4];
    CGPoint preTwoLowPoints[2];
    CGPoint aftFourLowPoints[4];
    
    for (int i = 0; i < 5; i ++) {
        
        UIColor *yesterdayColor = DDRGBAColor(207, 222, 230, 0.4);
        UIColor *todayColor = DDRGBAColor(0, 245, 204, 1);
        UIColor *futureColor = DDRGBAColor(207, 222, 230, 1);
        UIColor *usedColor;
        
        if (i == 0) {
            usedColor = yesterdayColor;
        }else if (i == 1)
        {
            usedColor = todayColor;
        }else
        {
            usedColor = futureColor;
        }

        CGFloat highX = self.width/10 * (i*2 + 1);
        CGFloat highY = [self caculateY:self.highTem withTag:i];
        CGFloat lowY = [self caculateY:self.lowTem withTag:i];
        highPoints[i] = CGPointMake(highX, highY+2);
        lowPoints[i] = CGPointMake(highX, lowY+52);
        
        if (i < 2 && i >= 0) {
            preTwoHighPoints[i] = CGPointMake(highX+2, highY+2);
            preTwoLowPoints[i] = CGPointMake(highX, lowY+52);
        }
        
        if (i >= 1 && i <= 4) {
            aftFourHighPoints[i-1] = CGPointMake(highX+2, highY+2);
            aftFourLowPoints[i-1] = CGPointMake(highX+2, lowY+52);
        }
       
        //创建最高温度标签
        UILabel *highTemLab = [[UILabel alloc] init];
        highTemLab.x = self.width/5 * i + 3;
        highTemLab.y = highY - 16;
        highTemLab.width = self.width/5;
        highTemLab.height = 12;
        highTemLab.textAlignment = NSTextAlignmentCenter;
        highTemLab.font = [UIFont systemFontOfSize:12];
        highTemLab.textColor = usedColor;
        highTemLab.text = [NSString stringWithFormat:@"%@°",[self.highTem objectAtIndex:i]];
        [self addSubview:highTemLab];
        
        //创建最低温度标签
        UILabel *lowTemLab = [[UILabel alloc] init];
        lowTemLab.x = self.width/5 * i + 3;
        lowTemLab.y = lowY + 56;
        lowTemLab.width = self.width/5;
        lowTemLab.height = 12;
        lowTemLab.textAlignment = NSTextAlignmentCenter;
        lowTemLab.font = [UIFont systemFontOfSize:12];
        lowTemLab.textColor = usedColor;
        lowTemLab.text = [NSString stringWithFormat:@"%@°",[self.lowTem objectAtIndex:i]];
        [self addSubview:lowTemLab];
    }
 
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context,1);
    [DDRGBAColor(92, 230, 207, 0.2) set];
    CGContextAddLines(context, preTwoHighPoints, 2);
    CGContextDrawPath(context, kCGPathStroke);
    
    [DDRGBAColor(92, 230, 207, 1) set];
    CGContextAddLines(context, aftFourHighPoints, 4);
    CGContextDrawPath(context, kCGPathStroke);
    
    [DDRGBAColor(92, 182, 228, 0.2) set];
    CGContextAddLines(context, preTwoLowPoints, 2);
    CGContextDrawPath(context, kCGPathStroke);
    
    [DDRGBAColor(92, 182, 228, 1) set];
    CGContextAddLines(context, aftFourLowPoints, 4);
    CGContextDrawPath(context, kCGPathStroke);
    
    for(int i = 0; i < 5; i ++)
    {
        CGFloat highX = self.width/10 * (i*2 + 1);
        CGFloat highY = [self caculateY:self.highTem withTag:i];
        [self drawEllipseWithX:highX andY:highY withTag:i];
        CGFloat lowY = [self caculateY:self.lowTem withTag:i];
        [self drawEllipseWithX:highX andY:lowY + 50 withTag:i];
    }
}

- (void) drawEllipseWithX:(CGFloat )xValue andY:(CGFloat )yValue withTag:(int) i
{
    CGRect frame = CGRectMake(xValue, yValue, 4, 4);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, frame);
    if (i == 0) {
        [DDRGBAColor(255, 255, 255, 0.2) set];
    }else{
        [[UIColor whiteColor] set];
    }
    CGContextFillPath(context);
}

- (CGFloat) caculateY:(NSArray *)array  withTag:(int )i
{
    CGFloat y;
    CGFloat maxValue = [ZJCommonFuction getMaxValueFrom:array];
    CGFloat minValue = [ZJCommonFuction getMinValueFrom:array];
    CGFloat nowValue = [[array objectAtIndex:i] floatValue];
    if (maxValue == minValue) {
        y = 20;
    }else{
        y = 40/(maxValue - minValue) * (maxValue - nowValue);
    }
    return y;
}
@end
