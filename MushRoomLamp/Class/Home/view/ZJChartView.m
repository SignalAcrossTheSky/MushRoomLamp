//
//  ZJChartView.m
//  MushRoomLamp
//
//  Created by SongGang on 8/11/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJChartView.h"
#import "UUChart.h"
#import "ZJCommonFuction.h"
#import "Constant.h"

@interface ZJChartView() <UUChartDataSource>
{
    UUChart *chartView;
    NSInteger maxYValue;
    NSInteger minYValue;
}
/** 开始时间 */
@property (nonatomic,assign) int startTime;
/** 时间的标志 */
@property(nonatomic,copy)NSString *timeTag;
/** 传入的数组:self family */
@property(nonatomic,strong)NSArray *selfValueArray;
/** 传入的数组:other family */
@property(nonatomic,strong)NSArray *otherValueArray;
/** 时间数组 */
@property(nonatomic,strong)NSArray *timeArray;

@end
@implementation ZJChartView

/**
 * 初始化View
 */
- (instancetype)initWithFrame:(CGRect)frame withSelfArray:(NSArray *)selfArray withOtherArray:(NSArray*)otherArray withType:(NSString *)itemtype withAllTime:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        _timeTag = itemtype;
        _selfValueArray = selfArray;
        _otherValueArray = otherArray;
        _timeArray = array;
        self.backgroundColor = [UIColor whiteColor];
        [self createChartView];
        [self createYCoordinate];
        [self createXCoordinate];
    }
    return self;
}

/**
 * 创建chartView
 */
- (void)createChartView
{
    if (chartView) {
        [chartView removeFromSuperview];
        chartView = nil;
    }
    
    int startPointX;
    if ([_timeTag isEqualToString:@"今日"]) {
        
        if (_startTime < 6) {
            startPointX = _startTime + 24 - 6;
        }else
        {
            startPointX = _startTime - 6;
        }
    }else
    {
        startPointX = _startTime - 1;
    }
    
//    chartView = [[UUChart alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.frame.size.height)
//                                   dataSource:self
//                                        style:UUChartStyleLine
//                                withStartTime:startPointX];
//    [chartView showInView:self];
}

/**
 * 画折线
 */
- (void)drawRect:(CGRect)rect
{

    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int count = 0;
    int otherCount = 0;
    for(int i = 0;i < _selfValueArray.count;i++)
    {
        NSInteger object = [[_selfValueArray objectAtIndex:i] integerValue];
        if (object == -999) {
            
        }else{
            count ++;
        }
    }

    for(int i = 0;i < _otherValueArray.count;i++)
    {
        NSInteger object = [[_otherValueArray objectAtIndex:i] integerValue];
        if (object == -999) {
            
        }else{
            otherCount ++;
        }
    }
    
    CGPoint selfPointArray[count];
    CGPoint otherPointArray[otherCount];
    int pointNum = 0;
    for(int i = 0;i < _selfValueArray.count;i++)
    {
        
        NSInteger object = [[_selfValueArray objectAtIndex:i] integerValue];
        if (object == -999) {
            
        }else{
            CGFloat y = (double)(maxYValue - object) /(double)(maxYValue - minYValue) * (self.height - 40) + 5;
            selfPointArray[pointNum ++] = CGPointMake((self.width - 20)/(_selfValueArray.count - 1) * i +10, y);
            
            CGRect frame = CGRectMake((self.width - 20)/(_selfValueArray.count - 1) * i +10 -2, y-2, 4, 4);
            CGContextAddEllipseInRect(context, frame);
            [DDRGBAColor(77, 186, 122, 0.8) set];
            CGContextFillPath(context);

        }
    }
    
    CGContextSetLineWidth(context,1);
    [DDRGBAColor(77, 186, 122, 0.8) set];
    CGContextAddLines(context,selfPointArray, count);
    CGContextDrawPath(context, kCGPathStroke);
    
    int otherPointNum = 0;
    for(int i = 0;i < _otherValueArray.count;i++)
    {
        
        NSInteger object = [[_otherValueArray objectAtIndex:i] integerValue];
        if (object == -999) {
            
        }else{
            CGFloat y = (double)(maxYValue - object) /(double)(maxYValue - minYValue) * (self.height - 40) + 5;
            otherPointArray[otherPointNum ++] = CGPointMake((self.width - 20)/(_otherValueArray.count - 1) * i +10, y);
            CGRect frame = CGRectMake((self.width - 20)/(_otherValueArray.count - 1) * i +10 -2, y-2, 4, 4);
            CGContextAddEllipseInRect(context, frame);
            [DDRGBAColor(245,94,78,0.5) set];
            CGContextFillPath(context);
        }
    }

    [DDRGBAColor(245,94,78,0.5) set];
    CGContextAddLines(context,otherPointArray, otherCount);
    CGContextDrawPath(context, kCGPathStroke);

    
    
}

/**
 * 创建纵坐标
 */
- (void)createYCoordinate
{
    NSInteger selfMaxValue = [ZJCommonFuction getMaxValueFrom:_selfValueArray];
    NSInteger selfMinValue = [ZJCommonFuction getMinValueFrom:_selfValueArray];
    NSInteger otherMaxValue = [ZJCommonFuction getMaxValueFrom:_otherValueArray];
    NSInteger otherMinValue = [ZJCommonFuction getMinValueFrom:_otherValueArray];
    NSInteger maxValue = selfMaxValue > otherMaxValue ? selfMaxValue : otherMaxValue;
    NSInteger minValue = selfMinValue < otherMinValue ? selfMinValue : otherMinValue;
    if(maxValue - minValue == 0)
    {
        maxValue = maxValue + 2;
        minValue = minValue - 3;
    }else if (maxValue - minValue == 1)
    {
        maxValue = maxValue + 2;
        minValue = minValue - 2;
    }else if(maxValue - minValue == 2)
    {
        maxValue = maxValue + 1;
        minValue = minValue - 2;
    }else if (maxValue - minValue == 3)
    {
        maxValue = maxValue + 1;
        minValue = minValue - 1;
    }else if (maxValue - minValue == 4)
    {
        maxValue = maxValue + 0;
        minValue = minValue - 1;
    }else if (maxValue - minValue == 5)
    {
        maxValue = maxValue + 0;
        minValue = minValue - 0;
    }
    
    maxYValue = maxValue;
    minYValue = minValue;
    
    for (int i = 0; i < 6 ; i++) {
        UILabel *lineLab = [[UILabel alloc] init];
        lineLab.x = 0;
        lineLab.y = (double)(self.height - 40)/(double)5 * i + 5;
        lineLab.width = 2;
        lineLab.height = 1;
        lineLab.backgroundColor = DDRGBColor(180, 180, 180);
        [self addSubview:lineLab];
        
        int value = (int)((double)(maxValue - minValue)/(double)5 * (5 - i)  + minValue) ;
        UILabel *textLab = [[UILabel alloc] init];
        textLab.x = 2;
        textLab.y = (self.height - 40)/5 * i ;
        textLab.width = 40;
        textLab.height = 10;
        textLab.text = [NSString stringWithFormat:@"%d",value];
        textLab.font = [UIFont systemFontOfSize:10];
        textLab.textAlignment = NSTextAlignmentLeft;
        textLab.textColor = DDRGBColor(88, 88, 88);
        [self addSubview:textLab];
    }
}

/**
 *  创建横坐标
 */
- (void) createXCoordinate
{
    NSInteger count = _timeArray.count;
    for (int i = 0; i < count; i ++) {
        UILabel *xLabel = [[UILabel alloc] init];
        xLabel.x = (self.width - 20)/(count - 1) * i +10;
        xLabel.y = self.height - 2 - 10;
        xLabel.width = 1;
        xLabel.height = 2;
        xLabel.backgroundColor = DDRGBColor(180, 180, 180);
        [self addSubview:xLabel];
        
        if (count == 24) {
            if (i == 5 || i == 11 || i == 17) {
                UILabel *timeLab = [[UILabel alloc] init];
                timeLab.x = (self.width - 20)/(count - 1) * i ;
                timeLab.y = self.height - 10;
                timeLab.width = 30;
                timeLab.height = 10;
                timeLab.textAlignment = NSTextAlignmentLeft;
                timeLab.text = [NSString stringWithFormat:@"%@",[_timeArray objectAtIndex:i]];
                timeLab.font = [UIFont systemFontOfSize:8];
                timeLab.textColor = DDRGBColor(80, 80, 80);
                [self addSubview:timeLab];
            }
        }else if(count == 7){
            UILabel *timeLab = [[UILabel alloc] init];
            timeLab.x = (self.width - 20)/(count - 1) * i ;
            timeLab.y = self.height - 10;
            timeLab.width = 30;
            timeLab.height = 10;
            timeLab.textAlignment = NSTextAlignmentLeft;
            timeLab.text = [NSString stringWithFormat:@"%@",[_timeArray objectAtIndex:i]];
            timeLab.font = [UIFont systemFontOfSize:8];
            timeLab.textColor = DDRGBColor(80, 80, 80);
            [self addSubview:timeLab];
        }else if (count == 12)
        {
            UILabel *timeLab = [[UILabel alloc] init];
            timeLab.x = (self.width - 20)/(count - 1) * i ;
            timeLab.y = self.height - 10;
            timeLab.width = 30;
            timeLab.height = 10;
            timeLab.textAlignment = NSTextAlignmentLeft;
            timeLab.text = [NSString stringWithFormat:@"%@",[_timeArray objectAtIndex:i]];
            timeLab.font = [UIFont systemFontOfSize:8];
            timeLab.textColor = DDRGBColor(80, 80, 80);
            [self addSubview:timeLab];

        }else{
            if (i == 5 || i == 11 || i == 17 || i == 23) {
                UILabel *timeLab = [[UILabel alloc] init];
                timeLab.x = (self.width - 20)/(count - 1) * i + 4;
                timeLab.y = self.height - 10;
                timeLab.width = 30;
                timeLab.height = 10;
                timeLab.textAlignment = NSTextAlignmentLeft;
                timeLab.text = [NSString stringWithFormat:@"%@",[_timeArray objectAtIndex:i]];
                timeLab.font = [UIFont systemFontOfSize:8];
                timeLab.textColor = DDRGBColor(80, 80, 80);
                [self addSubview:timeLab];
            }

        }
    }
}

- (NSArray *)getXTitles:(int)num
{
    NSMutableArray *xTitles = [NSMutableArray array];
    if ([_timeTag isEqualToString:@"今日"]) {
        for (int i=0+6; i<num+6; i++) {
            NSString * str;
            if (i == 6 || i == 12 || i == 18 || i == 24) {
                str = [NSString stringWithFormat:@"%i:00",i];
            }else
            {
                str = @"";
            }
            [xTitles addObject:str];
        }
    }else if ([_timeTag isEqualToString:@"本周"])
    {
        for (int i=0; i<num; i++) {
            NSString * str = [NSString stringWithFormat:@"周%i",i + 1];
            [xTitles addObject:str];
        }
    }else if ([_timeTag isEqualToString:@"本月"])
    {
        for (int i=0; i<num; i++) {
            NSString *str;
            if((i+1)%5 == 0 && i + 1 != 30)
            {
                str = [NSString stringWithFormat:@"%i号",i + 1];
            }else
            {
                str = @"";
            }
            [xTitles addObject:str];
        }
    }else if ([_timeTag isEqualToString:@"今年"])
    {
        for (int i=0; i<num; i++) {
            NSString * str = [NSString stringWithFormat:@"%i月",i + 1];
            [xTitles addObject:str];
        }
    }
   
    return xTitles;
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)chartConfigAxisXLabel:(UUChart *)chart
{
    if ([_timeTag isEqualToString:@"今日"]) {
        return [self getXTitles:24];
    }else if ([_timeTag isEqualToString:@"本周"])
    {
        return [self getXTitles:7];
    }else if ([_timeTag isEqualToString:@"本月"])
    {
        return [self getXTitles:30];
    }else if ([_timeTag isEqualToString:@"今年"])
    {
        return [self getXTitles:12];
    }
    
    return [self getXTitles:30];
}
//数值多重数组
- (NSArray *)chartConfigAxisYValue:(UUChart *)chart
{
    
    return @[_selfValueArray,_otherValueArray];
}

#pragma mark - @optional
//颜色数组
- (NSArray *)chartConfigColors:(UUChart *)chart
{
    return @[[UUColor green],[UUColor red],[UUColor brown]];
}
//显示数值范围
- (CGRange)chartRange:(UUChart *)chart
{
    NSInteger selfMax = [ZJCommonFuction getMaxValueFrom:_selfValueArray];
    NSInteger selfMin = [ZJCommonFuction getMinValueFrom:_selfValueArray];
    NSInteger otherMax = [ZJCommonFuction getMaxValueFrom:_otherValueArray];
    NSInteger otherMin = [ZJCommonFuction getMinValueFrom:_otherValueArray];
    NSInteger maxValue = selfMax > otherMax ? selfMax : otherMax;
    NSInteger minValue = selfMin < otherMin ? selfMin : otherMin;
    return CGRangeMake(maxValue + 3,minValue - 3);
}

#pragma mark 折线图专享功能

//标记数值区域
- (CGRange)chartHighlightRangeInLine:(UUChart *)chart
{
    return CGRangeZero;
}

//判断显示横线条
- (BOOL)chart:(UUChart *)chart showHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)chart:(UUChart *)chart showMaxMinAtIndex:(NSInteger)index
{
    return YES;
}
@end
