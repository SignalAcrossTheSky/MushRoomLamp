//
//  ZJOutdoorWeatherDetailView.m
//  MushRoomLamp
//
//  Created by SongGang on 11/14/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJOutdoorWeatherDetailView.h"
#import "ZJFiveDayTemView.h"
#import "Constant.h"
#import "ZJInterface.h"
#import "UIImage+Size.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+NJ.h"

@interface ZJOutdoorWeatherDetailView()<ZJInterfaceDelegate>
{
    NSInteger deviceId;
}
/** 地址 */
@property (nonatomic,strong) UIButton *localBtn;
/** 湿度 */
@property (nonatomic,strong) UIButton *humBtn;
/** AQI */
@property (nonatomic,strong) UIButton *aqiBtn;
/** 温度 */
@property (nonatomic,strong) UILabel *temLab;
/** 天气状态 */
@property (nonatomic,strong) UILabel *stateLab;
/** 风力 */
@property (nonatomic,strong) UILabel *windLab;
@property (nonatomic,strong) UILabel *weatherText;
@property (nonatomic,strong) NSArray *weatherArray;
@property (nonatomic,copy) NSDictionary *dic;
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) ZJInterface *outdoorWeatherInterface;

@end

@implementation ZJOutdoorWeatherDetailView

- (instancetype)initWithFrame:(CGRect)frame
                      withDic:(NSDictionary *)dic
                 withDeviceID:(NSInteger )deviceID
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dic = dic;
        deviceId = deviceID;

        [self createView];
        [self createTitleView];
        
        [self requestOutdoorWeather ];
    }
    return self;
}

/**
 * 户外天气网络请求
 */
- (void)requestOutdoorWeather
{
    [MBProgressHUD showMessage:@""];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"deviceId"] = @(deviceId);
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.outdoorWeatherInterface = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.outdoorWeatherInterface interfaceWithType:INTERFACE_TYPE_OUTDOORWEATHER param:param];
}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if(interface == self.outdoorWeatherInterface)
    {
        if (![result[@"code"] isEqual:@(0)]) {
            return;
        }
        
        if (result[@"data"] == [NSNull null]) {
            return;
        }

        [self createTodayWeather];
        
        [self.localBtn setTitle:result[@"data"][@"cityName"] forState:UIControlStateNormal];
        [self.humBtn setTitle:[NSString stringWithFormat:@"%@%%",result[@"data"][@"humidity"] ] forState:UIControlStateNormal];
        [self.aqiBtn setTitle:[NSString stringWithFormat:@"%@ %@",result[@"data"][@"aqi"],result[@"data"][@"quality"]] forState:UIControlStateNormal];
        self.temLab.text = [NSString stringWithFormat:@"%@°",result[@"data"][@"temperature"]];
        self.stateLab.text =[NSString stringWithFormat:@"%@",result[@"data"][@"text"]];
        self.windLab.text = [NSString stringWithFormat:@"%@ %@",result[@"data"][@"windDirection"],result[@"data"][@"windScale"]];

        _weatherArray = result[@"data"][@"weatherList"];

        NSMutableArray *highTem = [[NSMutableArray alloc] init];
        NSMutableArray *lowTem = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5 ;i ++) {
            NSDictionary *dic = [_weatherArray objectAtIndex:i];
            [self createDayWeatherWithTag:i withArray:dic];
            CGFloat high = [dic[@"high"] floatValue];
            CGFloat low= [dic[@"low"] floatValue];
            [highTem addObject:@(high)];
            [lowTem addObject:@(low)];
        }
//        创建温度曲线
        ZJFiveDayTemView *tv = [[ZJFiveDayTemView alloc] initWithFrame: CGRectMake(0, _weatherText.bottom + 20, self.bgView.width, 95)
                                                           withHighTem:highTem
                                                            withLowTem:lowTem];
        [self.bgView addSubview:tv];
    }
}

/**
 * 创建View（detail）
 */
- (void)createView
{
    UIView *bgView = [[UIView alloc] init];
    bgView.x = 0;
    bgView.y = 0;
    bgView.width = self.width;
    bgView.height = self.height;
    bgView.layer.cornerRadius = 8;
    bgView.backgroundColor = DDRGBAColor(33, 51, 60, 0.4);
    [self addSubview:bgView];
    self.bgView = bgView;
}

/**
 * 创建抬头
 */
- (void) createTitleView
{
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.x = 0;
    titleLab.y = 0;
    titleLab.width = self.bgView.width;
    titleLab.height = 44;
    titleLab.text = @"天气预报";
    titleLab.textColor = DDRGBAColor(0, 224,207, 1);
    titleLab.font = [UIFont systemFontOfSize:18];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:titleLab];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    closeBtn.width = 22;
    closeBtn.height = 22;
    closeBtn.x = self.bgView.width - 15 - closeBtn.width;
    closeBtn.y = 11;
    [closeBtn setImage:[UIImage imageNamed:@"close_weather"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeOutdoorWeatherView) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:closeBtn];
    
    //创建两条横线
    for (int i = 0; i < 2; i ++) {
        UILabel *hLine = [[UILabel alloc] init];
        hLine.x = 15;
        hLine.width = self.bgView.width - 30;
        hLine.height = 1;
        hLine.backgroundColor = DDRGBColor(73, 82, 87);
        if (i == 0) {
            hLine.y = 44;
        }else
        {
            hLine.y = 185;
            hLine.x = 0;
            hLine.width = self.bgView.width;
        }
        
        [self.bgView addSubview:hLine];
    }
    
    //创建四条竖线
    for (int i = 0; i < 4; i ++) {
        UILabel *vLine = [[UILabel alloc] init];
        vLine.width = 1;
        vLine.y = 185;
        vLine.height = self.bgView.height - 185;
        vLine.x = self.bgView.width/5 * (i + 1);
        vLine.backgroundColor = DDRGBColor(73, 82, 87);
        [self.bgView addSubview:vLine];
    }
}

/**
 * 创建今日天气
 */
- (void) createTodayWeather
{
    //定位
    UIButton *localBtn = [[UIButton alloc] init];
    localBtn.x = 15;
    localBtn.y = 59;
    localBtn.width = 200;
    localBtn.height = 14;
    [localBtn setImage:[UIImage imageNamed:@"local"] forState:UIControlStateNormal];
    [localBtn setTitle:@"拱墅区" forState:UIControlStateNormal];
    [localBtn setTitleColor:DDRGBColor(207, 222, 230) forState:UIControlStateNormal];
    localBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    localBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    localBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.bgView addSubview:localBtn];
    self.localBtn = localBtn;
    
    //空气质量
    UIButton *aqiBtn = [[UIButton alloc] init];
    aqiBtn.x = 15;
    aqiBtn.width = 100;
    aqiBtn.height = 14;
    aqiBtn.y = 185 - 27 - aqiBtn.height;
    [aqiBtn setImage:[UIImage imageNamed:@"aqi_light"] forState:UIControlStateNormal];
    [aqiBtn setTitle:@"67 良" forState:UIControlStateNormal];
    [aqiBtn setTitleColor:DDRGBColor(207, 222, 230) forState:UIControlStateNormal];
    aqiBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    aqiBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    aqiBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.bgView addSubview:aqiBtn];
    self.aqiBtn = aqiBtn;
    
    //湿度
    UIButton *humBtn = [[UIButton alloc] init];
    humBtn.x = 15;
    humBtn.width = 100;
    humBtn.height = 14;
    humBtn.y = aqiBtn.y - 10 - humBtn.height;
    [humBtn setImage:[UIImage imageNamed:@"hum_light"] forState:UIControlStateNormal];
    [humBtn setTitle:@"50%" forState:UIControlStateNormal];
    [humBtn setTitleColor:DDRGBColor(207, 222, 230) forState:UIControlStateNormal];
    humBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    humBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    humBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.bgView addSubview:humBtn];
    self.humBtn = humBtn;

    //大写的温度
    UILabel *temLabel = [[UILabel alloc] init];
    temLabel.x = 0;
    temLabel.width = self.bgView.width;
    temLabel.height = 70;
    temLabel.y = 185 - 27 - temLabel.height;
    temLabel.text = @"18°";
    temLabel.font = [UIFont systemFontOfSize:70];
    temLabel.textColor = DDRGBColor(207, 222, 230);
    temLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:temLabel];
    self.temLab = temLabel;
    
    //天气状况
    UILabel *weatherState = [[UILabel alloc] init];
    weatherState.height = 24;
    weatherState.width = 140;
    weatherState.x = self.bgView.width - 40 - 40;
    weatherState.y = temLabel.y;
    weatherState.textAlignment = NSTextAlignmentLeft;
    weatherState.text = @"晴";
    weatherState.font = [UIFont systemFontOfSize:24];
    weatherState.textColor = DDRGBColor(207, 222, 230);
    [self.bgView addSubview:weatherState];
    self.stateLab = weatherState;
    
    //风力
    UILabel *wingLabel = [[UILabel alloc] init];
    wingLabel.x = weatherState.x;
    wingLabel.y = aqiBtn.y;
    wingLabel.width = 150;
    wingLabel.height = 14;
    wingLabel.text = @"北风 3级";
    wingLabel.textAlignment = NSTextAlignmentLeft;
    wingLabel.textColor = DDRGBColor(207, 222, 230);
    wingLabel.font = [UIFont systemFontOfSize:14];
    [self.bgView addSubview:wingLabel];
    self.windLab = wingLabel;
}

/**
 * 创建一天的天气
 */
- (void) createDayWeatherWithTag:(int) i withArray:(NSDictionary *)dic
{
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
    
    //星期几
    UILabel *weekLab = [[UILabel alloc] init];
    weekLab.x = self.bgView.width / 5 * i;
    weekLab.y = 15 + 185;
    weekLab.width = self.bgView.width / 5;
    weekLab.height = 18;
    weekLab.textAlignment = NSTextAlignmentCenter;
    weekLab.textColor = usedColor;
    weekLab.font = [UIFont systemFontOfSize:18];
    weekLab.text = dic[@"week"];
    [self.bgView addSubview:weekLab];
    
    //日期
    UILabel *dateLab = [[UILabel alloc] init];
    dateLab.x = self.bgView.width / 5 * i;
    dateLab.y = weekLab.bottom + 10;
    dateLab.width = weekLab.width;
    dateLab.height = 12;
    dateLab.textAlignment = NSTextAlignmentCenter;
    dateLab.textColor = usedColor;
    dateLab.text = dic[@"date"];
    dateLab.font = [UIFont systemFontOfSize:12];
    [self.bgView addSubview:dateLab];

    //天气图标
    UIButton *weatherImg = [[UIButton alloc] init];
    
    if (dic[@"icon"] == nil) {
        
    }else{
        NSString *urlStr = [NSString stringWithFormat:@"http://118.178.21.0:8880/heweather/ios/42/%@",dic[@"icon"]];
        NSString *url;
        if (i == 1) {
            url = [urlStr stringByAppendingString:@"_g.png"];
        }else
        {
            url = [urlStr stringByAppendingString:@"_w.png"];
        }
        
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage * result = [UIImage scaleToSize:[UIImage imageWithData:data] size:CGSizeMake(14, 14)] ;
        [weatherImg setImage:result forState:UIControlStateNormal];
        weatherImg.x = self.bgView.width / 5 * i;
        weatherImg.y = dateLab.bottom + 15;
        weatherImg.width = self.bgView.width / 5;
        weatherImg.height = 15;
        [self.bgView addSubview:weatherImg];

    }
    
    //天气文字
    UILabel *weatherText = [[UILabel alloc] init];
    weatherText.x = self.bgView.width / 5 * i;
    weatherText.y = weatherImg.bottom + 10;
    weatherText.width = self.bgView.width / 5;
    weatherText.height = 14;
    weatherText.textAlignment = NSTextAlignmentCenter;
    weatherText.textColor = usedColor;
    weatherText.text = dic[@"textDay"];
    if (weatherText.text.length <= 3) {
        weatherText.font = [UIFont systemFontOfSize:14];
    }else if (weatherText.text.length <= 5)
    {
        weatherText.font = [UIFont systemFontOfSize:12];
    }else
    {
        weatherText.font = [UIFont systemFontOfSize:8];
    }
    [self.bgView addSubview:weatherText];
    self.weatherText = weatherText;
    
    //风向
    UILabel *windHeadForLab = [[UILabel alloc] init];
    windHeadForLab.x = self.bgView.width / 5 * i;
    windHeadForLab.y = weatherText.bottom + 135;
    windHeadForLab.width = self.bgView.width / 5 ;
    windHeadForLab.height = 14;
    windHeadForLab.textAlignment = NSTextAlignmentCenter;
    windHeadForLab.text = dic[@"windDirection"];
    if (windHeadForLab.text.length <= 3) {
        windHeadForLab.font = [UIFont systemFontOfSize:14];
    }else{
        windHeadForLab.font = [UIFont systemFontOfSize:12];
    }
    windHeadForLab.textColor = usedColor;
    [self.bgView addSubview:windHeadForLab];
    
    //风力
    UILabel *windPower = [[UILabel alloc] init];
    windPower.x = self.bgView.width / 5 * i;
    windPower.y = windHeadForLab.bottom + 5;
    windPower.width = self.bgView.width / 5 ;
    windPower.height = 12;
    windPower.textColor = usedColor;
    windPower.text = dic[@"windScale"];
    windPower.font = [UIFont systemFontOfSize:12];
    windPower.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:windPower];
}

/**
 * 关闭按钮点击事件
 */
- (void)closeOutdoorWeatherView
{
    if ([_delegate respondsToSelector:@selector(closeWeatherView)]) {
        [_delegate closeWeatherView];
    }
}

@end
