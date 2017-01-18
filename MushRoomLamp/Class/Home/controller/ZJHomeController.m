//
//  ZJHomeController.m
//  MushRoomLamp
//
//  Created by SongGang on 6/23/16.
//  Copyright © 2016 SongGang. All rights reserved.
//  15957348818

#import "ZJHomeController.h"
#import "Constant.h"
#import "ZJEqsInfoViewController.h"
#import "ZJInterface.h"
#import "ZJCommonFuction.h"
#import "MBProgressHUD+NJ.h"
#import <SocketRocket.h>
#import "UMSocialData.h"
#import "UMSocialSnsService.h"
#import "UMSocialSnsPlatformManager.h"
#import "SDCycleScrollView.h"
#import <OpenGLES/ES1/glext.h>
#import "ZJChartView.h"
#import "ZJLoginViewController.h"
#import "ZJOutdoorWeatherView.h"
#import "ZJOutdoorWeatherDetailView.h"
#import "UIImage+Size.h"
#import "ZJSettingViewController.h"

@interface ZJHomeController ()<SRWebSocketDelegate,ZJInterfaceDelegate,ZJEqsInfoViewControllerDelegate,UMSocialUIDelegate,UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,SDCycleScrollViewDelegate,ZJBloodPressViewDelegate,ZJOutdoorWeatherViewDelegate,ZJOutdoorWeatherDetailViewDelegate>
{
    SRWebSocket *localWebSocket;
    NSInteger deviceId;
    NSArray *valueArray;
    NSInteger requestNum;
    /** 来的地方 */
    NSInteger from;
    
    /** 开始时间 */
    int startTime;
    /** 时间数组 */
    NSArray *timeArray;
    /** 温度数组 */
    NSArray *temDayArray;
    NSArray *temOtherDayArray;
    /** 气压数组 */
    NSArray *pressDayArray;
    NSArray *pressOtherDayArray;
    /** 湿度数组 */
    NSArray *humDayArray;
    NSArray *humOtherDayArray;
    /** AQI数组 */
    NSArray *aqiDayArray;
    NSArray *aqiOtherDayArray;
    /** 广告点击后跳转的URL的数组 */
    NSMutableArray *adUrlArray;
}
/** 状态按钮 */
@property (nonatomic,strong) UIButton *stateBtn;
/** pickView */
@property (nonatomic,strong) UIPickerView *pickView;
/** 光晕的image */
@property (nonatomic,strong) UIImageView *lampLightImage;
/** 内容视图View */
@property (nonatomic,strong) UIView *contentView;
/** 灯的名称 */
@property (nonatomic,strong) UILabel *lampName;
/** 灯的图片 */
@property (nonatomic,strong) UIImageView *lampImage;
/**  提示Label */
@property (nonatomic,strong) UILabel *tipLabel;
/** 健康提示，广告，非正常措施所在的View */
@property (nonatomic,strong) UIView *firstView;
/** 图表展示view */
@property (nonatomic,strong) UIView *chartView;
/** 左划小箭头 */
@property (nonatomic,strong) UIButton *arrowBtn;
/** 右划小箭头 */
@property (nonatomic,strong) UIButton *rightArrowBtn;
/** 温度，气压，湿度，AQI的被选择按钮 */
@property (nonatomic,strong) UIButton *selectedItemBtn;
/** 今日，本周，本月，今年的被选择按钮 */
@property (nonatomic,strong) UIButton *selectedTimeBtn;
/** 获取设备列表网络接口 */
@property (nonatomic,strong) ZJInterface *interfaceGetDeviceList;
/** 图表数据网络接口 */
@property (nonatomic,strong) ZJInterface *interfaceChartDate;
/** 光晕动画线程 */
@property (nonatomic,strong) NSThread *myThread;
/** 室外天气值 */
@property (nonatomic,strong) UILabel *outdoorLab;
/** 室外天气图标 */
@property (nonatomic,strong) UIImageView *outdoorImage;
/** 广告的scrollView */
@property (nonatomic,strong) SDCycleScrollView *dcScrollView;
/** 图表View */
@property (nonatomic,strong)ZJChartView *nChartView;
/** 单位标签 */
@property (nonatomic,strong) UILabel *unitLab;
/** 毛玻璃视图 */
@property (nonatomic,strong) UIVisualEffectView *effectView;
/** 右上角天气预报视图 */
@property (nonatomic,strong) ZJOutdoorWeatherView *weatherView;
@end

@implementation ZJHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setNavigationBar];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendWebSocketRequest:) name:@"WEBSOCKET" object:nil ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanSendWebSocketRequest:) name:@"SCANADDEQU" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopWebSocket) name:@"STOPWEBSOCKET" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startWebSocket) name:@"STARTWEBSOCKET" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitNotification) name:@"QUIT" object:nil ];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setWebSocket];
    [self.tabBarController.tabBar setHidden:NO];
    [self setChoosedPickerViewStyle:self.pickView];
    if (self.chartView.x == 0) {
        if ([self.selectedTimeBtn.titleLabel.text isEqualToString:@"今日"]) {
            [self chartDateRequestWithType:1];
        }else if ([self.selectedTimeBtn.titleLabel.text isEqualToString:@"本周"]) {
            [self chartDateRequestWithType:2];
        }else if ([self.selectedTimeBtn.titleLabel.text isEqualToString:@"本月"]) {
            [self chartDateRequestWithType:3];
        }else if ([self.selectedTimeBtn.titleLabel.text isEqualToString:@"今年"]) {
            [self chartDateRequestWithType:4];
        }
    }
}

- (void)viewDidLayoutSubviews
{
    [self.pickView selectRow:1 inComponent:0 animated:YES];
    [self setChoosedPickerViewStyle:self.pickView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
    from = 1;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = [userDefault objectForKey:@"userid"];
    
    param[@"signal"] = @"stop";
    param[@"deviceId"] = @(deviceId);
    param[@"terminalId"] = @(1);
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    NSString *str = [self dictionaryToJson:param];
    [localWebSocket send:str];
    
    if (![self.myThread isCancelled]) {
        [self.myThread cancel];
    }
    
    if (self.bpView != nil) {
        [self.bpView removeFromSuperview];
        self.bpView = nil;
    }
}

#pragma mark HTTP网络请求
/**
 * 获取设备列表网络请求
 */
- (void)getDeviceListRequest
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceGetDeviceList = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceGetDeviceList interfaceWithType:INTERFACE_TYPE_DEVICELIST param:param];
}

/**
 * 图表数据网络请求
 */
- (void)chartDateRequestWithType:(NSInteger )typeId
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = [userDefault objectForKey:@"userid"];
    
    param[@"deviceId"] = @(deviceId);
    
    param[@"typeId"] = @(typeId);
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceChartDate = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceChartDate interfaceWithType:INTERFACE_TYPE_CHARTDATE param:param];
    
    [MBProgressHUD showMessage:@""];
}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    if (interface == self.interfaceGetDeviceList) {
        if([result[@"code"] isEqual:@(0)])
        {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault removeObjectForKey:@"moreAdvise"];
            [userDefault synchronize];
            
//            [self setOutdoorWeatherValue:result[@"data"][@"weather"]];
             //如果为空，另作处理
            NSArray *array = result[@"data"][@"devices"];
            if (array.count == 0) {
                valueArray = [[NSArray alloc] initWithObjects:@"--",@"--",@"--",@"--",nil];
                [self.pickView reloadComponent:0];
                [self.pickView selectRow:1 inComponent:0 animated:YES];
                [self setChoosedPickerViewStyle:self.pickView];
                self.lampName.text = @"蘑菇管家";
                [self.lampImage setImage:[UIImage imageNamed:@"greenLamp"]];
                [self.lampLightImage setImage:[UIImage imageNamed:@"greenGlow"]];
                [self.stateBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
                self.stateBtn.layer.borderColor = DDRGBColor(0, 244, 207).CGColor;
                [self.stateBtn setTitle:@"暂无数据" forState:UIControlStateNormal];
                self.tipLabel.text = @"暂无数据";
                
                return;
            }
            
            NSDictionary *dic = (NSDictionary *)[array firstObject];
            deviceId = [dic[@"deviceId"] integerValue];
            self.lampName.text = dic[@"deviceName"];
         
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            
            param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
            
            param[@"deviceId"] = @(deviceId);
            
            param[@"terminalId"] = @(1);
            
            param[@"sign"] = [ZJCommonFuction addLockFunction:param];
            
            NSString *str = [self dictionaryToJson:param];
            [localWebSocket send:str];
        }else
        {
            [MBProgressHUD showError:@"操作异常"];
        }
    }else if (interface == self.interfaceChartDate)
    {
        [MBProgressHUD hideHUD];
//        [self sonFunctionWithParam:result];
        if([result[@"code"] isEqual:@(0)])
        {
            [self sonFunctionWithParam:result];
        }else
        {
            [MBProgressHUD showError:@"操作异常"];
        }
    }
}

/**
 *   处理图表结果
 */
- (void) sonFunctionWithParam:(NSDictionary *)result
{
    temDayArray = result[@"data"][@"temperature"];
    pressDayArray = result[@"data"][@"airPressure"];
    humDayArray = result[@"data"][@"humidity"];
    aqiDayArray = result[@"data"][@"airQuality"];
    temOtherDayArray = result[@"data"][@"area"][@"temperature"];
    pressOtherDayArray = result[@"data"][@"area"][@"airPressure"];
    humOtherDayArray = result[@"data"][@"area"][@"humidity"];
    aqiOtherDayArray = result[@"data"][@"area"][@"airQuality"];
    startTime = [result[@"data"][@"begin_time"] intValue];
    timeArray = result[@"data"][@"area"][@"dateTime"];
    NSString *timeType;
    
    if ([result[@"data"][@"type_id"] isEqual:@(1)]) {
        timeType = @"今日";
    }else if ([result[@"data"][@"type_id"] isEqual:@(2)]){
        timeType = @"本周";
    }else if ([result[@"data"][@"type_id"] isEqual:@(3)]){
        timeType = @"本月";
    }else if ([result[@"data"][@"type_id"] isEqual:@(4)]){
        timeType = @"今年";
    }
    
    [self.nChartView removeFromSuperview];
    if ([self.selectedItemBtn.titleLabel.text isEqualToString:@"温度"]) {
        if (![self ifHaveDataWithSelfArray:temDayArray andOtherArray:temOtherDayArray]) {
            return;
        }
        if(temDayArray.count == 0 || temOtherDayArray == 0)
        {
            return;
        }
        else{
            [self createNewChartViewWithself:temDayArray withOther:temOtherDayArray withTimeType:timeType withTimeArray:timeArray];
        }
    }else if([self.selectedItemBtn.titleLabel.text isEqualToString:@"气压"]) {
        [self.nChartView removeFromSuperview];
    }else if([self.selectedItemBtn.titleLabel.text isEqualToString:@"湿度"]) {
        if (![self ifHaveDataWithSelfArray:humDayArray andOtherArray:humOtherDayArray]) {
            return;
        }
        if(humDayArray.count == 0 || humOtherDayArray == 0)
        {
            return;
        }
        else{
            [self createNewChartViewWithself:humDayArray withOther:humOtherDayArray withTimeType:timeType withTimeArray:timeArray];
        }
    }else if([self.selectedItemBtn.titleLabel.text isEqualToString:@"AQI"]) {
        if (![self ifHaveDataWithSelfArray:aqiDayArray andOtherArray:aqiOtherDayArray]) {
            return;
        }
        if(aqiDayArray.count == 0 || aqiOtherDayArray == 0)
        {
            return;
        }
        else{
            [self createNewChartViewWithself:aqiDayArray withOther:aqiOtherDayArray withTimeType:timeType withTimeArray:timeArray];
        }
    }
}

#pragma mark WebSocket网络推送
/**
 * 开始WebSocket
 */
- (void)startWebSocket
{
    from = 0;
    [self setWebSocket];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"STARTWEBSOCKET" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopWebSocket) name:@"STOPWEBSOCKET" object:nil];
}

/**
 * 停止WebSocket
 */
- (void)stopWebSocket
{
//    [localWebSocket close];

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = [userDefault objectForKey:@"userid"];
    
    param[@"signal"] = @"stop";
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    NSString *str = [self dictionaryToJson:param];
    [localWebSocket send:str];
 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"STOPWEBSOCKET" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startWebSocket) name:@"STARTWEBSOCKET" object:nil];
}

/**
 * webSocket设置
 */
- (void) setWebSocket
{
  
    localWebSocket.delegate = nil;
    [localWebSocket close];
//    localWebSocket = nil;
    
//    localWebSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://118.178.21.0:9509"]]];
    
   localWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://118.178.21.0:8881"]];
   
    localWebSocket.delegate = self;
    [localWebSocket open];
}

/**
 * 确认webSocket是否打开，并传值
 */
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    if (from == 0 || from == 1) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
      
        if ([userDefault integerForKey:@"DELETEDDEVICEID"] == deviceId) {
            [self getDeviceListRequest];
            [userDefault removeObjectForKey:@"moreAdvise"];
            [userDefault synchronize];

        }else
        {
            param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
            
            param[@"deviceId"] = @(deviceId);
            
            param[@"terminalId"] = @(1);
            
            param[@"sign"] = [ZJCommonFuction addLockFunction:param];
            
            NSString *str = [self dictionaryToJson:param];
            [localWebSocket send:str];
 
        }
    }
}

/**
 * WebSocket连接失败
 */
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    webSocket = nil;
}

/**
 * WebSocket接收数据
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSDictionary *dic = [self dictionaryWithJsonString:message];
    
    if ([dic[@"type"] isEqualToString:@"ad_banner"]) {
        
        NSArray *adArray = dic[@"data"];
        NSMutableArray *urlArray = [NSMutableArray array];
        adUrlArray = [NSMutableArray array];
        for (int i = 0; i < adArray.count; i++) {
            NSDictionary *object = (NSDictionary *)[adArray objectAtIndex:i];
            [urlArray addObject:[NSString stringWithFormat:@"http://118.178.21.0:8880%@",object[@"imgPath"]] ];
            [adUrlArray addObject:object[@"urlPath"]];
        }
        self.dcScrollView.imageURLStringsGroup = urlArray;
        return;
    }else if([dic[@"type"] isEqualToString:@"blood_check"])
    {
        if ([dic[@"data"][@"action"] isEqualToString:@"begin"])
        {
            if(self.bpView == nil)
            {
                [self popBloodPressView];
            }
            [self.bpView setStartState];
        
            self.tipLabel.text = dic[@"data"][@"text"];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.tipLabel.text];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:2];//调整行间距
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.tipLabel.text length])];
            self.tipLabel.attributedText = attributedString;
            CGRect rect = [self.tipLabel.text boundingRectWithSize:CGSizeMake(self.tipLabel.width, 9999)  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.tipLabel.font,NSParagraphStyleAttributeName:paragraphStyle} context:nil];
            self.tipLabel.height = rect.size.height;
        
            return;
        }else if ([dic[@"data"][@"action"] isEqualToString:@"stop"])
        {
            if(self.bpView == nil)
            {
                [self popBloodPressView];
            }
            [self.bpView setErrorState];
            return;
        }else if ([dic[@"data"][@"action"] isEqualToString:@"move"])
        {
            if(self.bpView == nil)
            {
                [self popBloodPressView];
            }
            [self.bpView setMoveState];
            return;
        }else if ([dic[@"data"][@"action"] isEqualToString:@"leave"])
        {
            if(self.bpView == nil)
            {
                [self popBloodPressView];
            }
            [self.bpView setLeaveState];
            return;
        }else
        {
            if(self.bpView == nil)
            {
                [self popBloodPressView];
            }
            [self.bpView setResultStateWithDic:dic];
            return;
        }
    }
    
    if([dic[@"code"] isEqual:@(10003)] || [dic[@"code"] isEqual:@(12007)])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QUIT" object:nil];
        if (self.bpView != NULL) {
            [self.bpView removeFromSuperview];
            self.bpView = nil;
        }
    }else
    {
        if(self.bpView != nil)
        {
            
        }else{
            
            if ([dic[@"moreAdvise"] count] == 0) {
                
                NSString *outDoorTmp = [NSString stringWithFormat:@"%@",[dic objectForKey:@"outDoorTmp"]];
                NSString *outDoorAqi = [NSString stringWithFormat:@"%@",[dic objectForKey:@"outDoorApi"]];
                NSString *outDoorHum = [NSString stringWithFormat:@"%@",[dic objectForKey:@"outDoorHum"]];
                if ([outDoorTmp isEqualToString:@"-999"]) {
                    outDoorTmp = @"--";
                }
                
                if([outDoorAqi isEqualToString:@"-999"])
                {
                    outDoorAqi = @"--";
                }
                
                if ([outDoorHum isEqualToString:@"-999"])
                {
                    outDoorHum = @"--";
                }
                [self.weatherView setTem:outDoorTmp withAqi:outDoorAqi withHum:outDoorHum withIcon:[UIImage imageNamed:@"sunny"]];

            }else{
                [self setViewValue:dic];
            }
        }
    }
}

/**
 * 关闭WebSocket
 */
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    
    webSocket = nil;
}
#pragma mark 新的图表方法
/**
 * New Chart方法
 */
- (void)createNewChartViewWithself:(NSArray *)selfArray withOther:(NSArray *)otherArray withTimeType:(NSString *)timeType withTimeArray:(NSArray *)atimeArray
{
    [self.nChartView removeFromSuperview];
    ZJChartView *cv = [[ZJChartView alloc] initWithFrame:CGRectMake(0, 160, MAINSCREEN.size.width, self.chartView.height - 160) withSelfArray:selfArray withOtherArray:otherArray withType:timeType withAllTime:atimeArray];
    self.nChartView = cv;
    [self.chartView addSubview:cv];
}
#pragma mark 创建界面，初始化
/**
 * 设置室外天气的值
 */
- (void)setOutdoorWeatherValue:(NSDictionary *)dic
{
    if((NSNull *)dic == [NSNull null])
    {
        [self.weatherView setHidden:YES];
        return;
    }else
    {
        [self.weatherView setHidden:NO];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"http://118.178.21.0%@",dic[@"icon"]];
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
    
    UIImage * result = [UIImage imageWithData:data];
    
    [self.weatherView setTem:[NSString stringWithFormat:@"%@℃",dic[@"tmp"]]
                     withAqi:[NSString stringWithFormat:@"%@",dic[@"quality"]]
                     withHum:[NSString stringWithFormat:@"%@%%",dic[@"hum"]]
                    withIcon:result];
    
}

/**
 * 设置界面上的值
 */
- (void) setViewValue:(NSDictionary *)dic
{
    NSString *urlStr = [NSString stringWithFormat:@"http://118.178.21.0:8880/heweather/ios/42/%@_g.png",dic[@"icon"]];
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
    UIImage * result = [UIImage scaleToSize:[UIImage imageWithData:data] size:CGSizeMake(14, 14)] ;
    if (data == nil) {
        result = [UIImage imageNamed:@"sunny"];
    }
    NSString *outDoorTmp = [NSString stringWithFormat:@"%@",[dic objectForKey:@"outDoorTmp"]];
    NSString *outDoorAqi = [NSString stringWithFormat:@"%@",[dic objectForKey:@"outDoorApi"]];
    NSString *outDoorHum = [NSString stringWithFormat:@"%@",[dic objectForKey:@"outDoorHum"]];
    if ([outDoorTmp isEqualToString:@"-999"]) {
        outDoorTmp = @"--";
    }
    
    if([outDoorAqi isEqualToString:@"-999"])
    {
        outDoorAqi = @"--";
    }
    
    if ([outDoorHum isEqualToString:@"-999"])
    {
        outDoorHum = @"--";
    }
    [self.weatherView setTem:outDoorTmp withAqi:outDoorAqi withHum:outDoorHum withIcon:result];
    
    NSString *pressStr = [NSString stringWithFormat:@"%@",dic[@"airPressure"]];
    NSString *aqiStr =  [NSString stringWithFormat:@"%@",dic[@"airQuality"]];
    NSString *humStr =  [NSString stringWithFormat:@"%@",dic[@"humidity"]];
    NSString *temStr = [NSString stringWithFormat:@"%@",dic[@"temperature"]];
    NSString *colorId = [NSString stringWithFormat:@"%@",dic[@"colorId"]];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:dic[@"moreAdvise"] forKey:@"moreAdvise"];
    [userDefault synchronize];
    
    NSInteger selectedRow = [self.pickView selectedRowInComponent:0];
    [self setAdviceAndIntro:dic[@"moreAdvise"] withSelectRow:selectedRow];
    
    if ([colorId isEqualToString:@"1"]) {
        //紫色
        [self.lampImage setImage:[UIImage imageNamed:@"purpleLamp"]];
        [self.lampLightImage setImage:[UIImage imageNamed:@"purpleGlow"]];
        [self.stateBtn setTitleColor:DDRGBColor(122, 65, 234) forState:UIControlStateNormal];
        self.stateBtn.layer.borderColor = DDRGBColor(122, 65, 234).CGColor;
    }else if ([colorId isEqualToString:@"2"])
    {    //蓝色
        [self.lampImage setImage:[UIImage imageNamed:@"blueLamp"]];
        [self.lampLightImage setImage:[UIImage imageNamed:@"blueGlow"]];
        [self.stateBtn setTitleColor:DDRGBColor(68, 114, 238) forState:UIControlStateNormal];
        self.stateBtn.layer.borderColor = DDRGBColor(68, 114, 238).CGColor;
    }else if ([colorId isEqualToString:@"3"])
    {   //天蓝
        [self.lampImage setImage:[UIImage imageNamed:@"blueLamp"]];
        [self.lampLightImage setImage:[UIImage imageNamed:@"blueGlow"]];
        [self.stateBtn setTitleColor:DDRGBColor(68, 114, 238) forState:UIControlStateNormal];
        self.stateBtn.layer.borderColor = DDRGBColor(68, 114, 238).CGColor;
    }else if ([colorId isEqualToString:@"4"])
    {   //绿色
        [self.lampImage setImage:[UIImage imageNamed:@"greenLamp"]];
        [self.lampLightImage setImage:[UIImage imageNamed:@"greenGlow"]];
        [self.stateBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
        self.stateBtn.layer.borderColor = DDRGBColor(0, 244, 207).CGColor;
    }else if ([colorId isEqualToString:@"5"])
    {   //黄色
        [self.lampImage setImage:[UIImage imageNamed:@"yellowLamp"]];
        [self.lampLightImage setImage:[UIImage imageNamed:@"yellowGlow"]];
        [self.stateBtn setTitleColor:DDRGBColor(241 ,239, 114) forState:UIControlStateNormal];
        self.stateBtn.layer.borderColor = DDRGBColor(241 ,239, 114).CGColor;
    }else if ([colorId isEqualToString:@"6"])
    {   //橙色
        [self.lampImage setImage:[UIImage imageNamed:@"orangeLamp"]];
        [self.lampLightImage setImage:[UIImage imageNamed:@"orangeGlow"]];
        [self.stateBtn setTitleColor:DDRGBColor(214, 124, 97) forState:UIControlStateNormal];
        self.stateBtn.layer.borderColor = DDRGBColor(214, 124, 97).CGColor;
    }else if ([colorId isEqualToString:@"7"])
    {   //红色
        [self.lampImage setImage:[UIImage imageNamed:@"redLamp"]];
        [self.lampLightImage setImage:[UIImage imageNamed:@"redGlow"]];
        [self.stateBtn setTitleColor:DDRGBColor(255,122,151) forState:UIControlStateNormal];
        self.stateBtn.layer.borderColor = DDRGBColor(255,122,151).CGColor;
    }
    
    valueArray = [[NSArray alloc] initWithObjects:temStr,humStr,pressStr,aqiStr,nil];
    [self.pickView reloadComponent:0];
    [self setChoosedPickerViewStyle:self.pickView];
    
    //广告
//    NSArray *ads = dic[@"ads"];
//    NSMutableArray *adsArray = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < ads.count; i ++) {
//        NSString *urlStr = [NSString stringWithFormat:@"http://118.178.21.0%@",[ads objectAtIndex:i]];
//        
//        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
//        
//        UIImage* result = [UIImage imageWithData:data];
//        
//        [adsArray addObject:result];
//    }
//   
//    [self.dcScrollView setImagePathsGroup:adsArray];
    
}

/**
 * 设置建议信息
 */
- (void)setAdviceAndIntro:(NSDictionary *)dic withSelectRow:(NSInteger) selectedRow
{
    NSString *advice = @"暂无数据";
    NSString *intro;
    if (selectedRow %4 == 0) {
        advice = dic[@"tmp"][@"advise"];
        intro = dic[@"tmp"][@"intro"];
    }else if(selectedRow %4 == 1)
    {
        advice = dic[@"hum"][@"advise"];
        intro = dic[@"hum"][@"intro"];
    }else if(selectedRow %4 == 2)
    {
        advice = dic[@"tmp"][@"advise"];
        intro = dic[@"tmp"][@"intro"];
    }else if(selectedRow %4 == 3)
    {
        advice = dic[@"air"][@"advise"];
        intro = dic[@"air"][@"intro"];
    }
    
    self.tipLabel.text = advice;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.tipLabel.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:2];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.tipLabel.text length])];
    self.tipLabel.attributedText = attributedString;
    CGRect rect = [self.tipLabel.text boundingRectWithSize:CGSizeMake(self.tipLabel.width, 9999)  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.tipLabel.font,NSParagraphStyleAttributeName:paragraphStyle} context:nil];
    self.tipLabel.height = rect.size.height;
    
    [self.stateBtn setTitle:intro forState:UIControlStateNormal];
    CGSize statesize = [self getSpaceLabelHeight:self.stateBtn.titleLabel.text withFont:self.stateBtn.titleLabel.font withWidth:9999];
    self.stateBtn.width = statesize.width + 50;
    self.stateBtn.x = (MAINSCREEN.size.width - self.stateBtn.width)/2;
}

/**
 * 设置 navigationBar
 */
- (void)setNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

/**
 * 初始化View
 */
- (void)initView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.x = 0;
    scrollView.y = 0;
    scrollView.width = MAINSCREEN.size.width;
    scrollView.height = MAINSCREEN.size.height;
    scrollView.contentSize = CGSizeMake(MAINSCREEN.size.width,598);
    scrollView.bounces = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    valueArray = [[NSArray alloc] initWithObjects:@"--",@"--",@"--",@"--",nil];

    from = -1;
    [self createTitleView];
    
    [self createMainView];
    
    [self createTipView];
    
    [self createChartView];
    
//    [self createAbnormalView];
    
    [self createAdvertView];
    [self createThread];
    
    [self getDeviceListRequest];
    [self.myThread start];
}

/**
 * 创建TitleView
 */
- (void) createTitleView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 0;
    view.width = MAINSCREEN.size.width;
    view.height = 64;
    [self.view addSubview:view];
    
    //黑色背景
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bg"]];
    imageView.x = 0;
    imageView.y = 0;
    imageView.width = view.width;
    imageView.height = view.height;
    [view addSubview:imageView];
    
    //TitleView
    UIButton *leftButton = [[UIButton alloc] init];
    leftButton.width = 40;
    leftButton.height = 40;
    leftButton.x = 20;
    leftButton.y = 25;
    [leftButton setImage:[UIImage imageNamed:@"gray_line"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:leftButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 40;
    titleLabel.width = view.width;
    titleLabel.height = 15;
    titleLabel.text = @"蘑菇管家";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    self.lampName = titleLabel;
    
    UIButton *rightButton = [[UIButton alloc] init];
    rightButton.width = 40;
    rightButton.height = 40;
    rightButton.x = MAINSCREEN.size.width - 20 - rightButton.width;
    rightButton.y = leftButton.y;
    [rightButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(compareClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:rightButton];
}
/**
 * 创建主View
 */
- (void)createMainView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = -20 ;
    view.width = MAINSCREEN.size.width;
    view.height = 514 - 64;
    if (MAINSCREEN.size.height == 667) {
        view.height = 514 - 64;
    }else if(MAINSCREEN.size.height == 736)
    {
        view.height = 549 - 64;
    }
    [self.scrollView addSubview:view];
    self.contentView = view;
    
    //黑色背景图
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_main"]];
    imageView.x = 0;
    imageView.y = 0;
    imageView.width = view.width;
    imageView.height = view.height;
    [view addSubview:imageView];
    
    //灯的图片
    UIImageView *lightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenLamp"]];
    lightImage.width = 250;
    lightImage.height = 263;
    lightImage.x = (MAINSCREEN.size.width - lightImage.width)/2;
    lightImage.y = 116 - 40;
    [view addSubview:lightImage];
    self.lampImage = lightImage;
    
    UIImageView *lampLight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenGlow"]];
    lampLight.width = 100;
    lampLight.height = 100;
    lampLight.x = (MAINSCREEN.size.width - lampLight.width)/2;
    lampLight.y = (lightImage.height - lampLight.height)/2 + lightImage.y -20;
    [view addSubview:lampLight];
    self.lampLightImage = lampLight;
    
    //创建温度，湿度，空气质量，气压的pickview
    UIPickerView *pickView = [[UIPickerView alloc] init];
    pickView.height = 160;
    pickView.width = 200;
    pickView.x = (MAINSCREEN.size.width - pickView.width)/2;
    pickView.y = lightImage.y + 30;
    pickView.delegate = self;
    pickView.dataSource = self;
    [view addSubview:pickView];
    self.pickView = pickView;
 
    //创建状态按钮
    UIButton *stateBtn = [[UIButton alloc] init];
    [stateBtn setTitle:@"暂无数据" forState:UIControlStateNormal];
    [stateBtn setTitleColor:DDRGBAColor(0, 244, 207, 0.7) forState:UIControlStateNormal];
    CGSize size = [self getSpaceLabelHeight:stateBtn.titleLabel.text withFont:stateBtn.titleLabel.font withWidth:9999];
    stateBtn.width = size.width + 50;
    stateBtn.height = size.height;
    stateBtn.x = (MAINSCREEN.size.width - stateBtn.width)/2;
    stateBtn.y = lightImage.bottom + 15;
    stateBtn.layer.borderColor = DDRGBAColor(0, 244, 207, 1).CGColor;
    stateBtn.layer.borderWidth = 0.5;
    stateBtn.layer.cornerRadius = stateBtn.height * 0.2;
    [view addSubview:stateBtn];
    self.stateBtn = stateBtn;
    
    //创建天气
    ZJOutdoorWeatherView *wv = [[ZJOutdoorWeatherView alloc] initWithFrame:CGRectMake(view.width - 75, 74, 60, 24) withTem:20 withAQI:30 withHum:50];
    wv.delegate = self;
    [view addSubview:wv];
    self.weatherView = wv;
//    UIImageView *weatherImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"outdoor_icon"]];
//    weatherImage.width = 20;
//    weatherImage.height = 20;
//    weatherImage.x = view.width - 100;
//    weatherImage.y = 80;
//    [view addSubview:weatherImage];
//    self.outdoorImage = weatherImage;
//    
//    UILabel *weatherLabel = [[UILabel alloc] init];
//    weatherLabel.x = weatherImage.right + 5;
//    weatherLabel.y = 80;
//    weatherLabel.width = 40;
//    weatherLabel.height = 22;
//    weatherLabel.text = @"35℃";
//    weatherLabel.font = [UIFont systemFontOfSize:16];
//    weatherLabel.textColor = DDRGBAColor(0, 244, 207, 0.8);
//    [view addSubview:weatherLabel];
//    self.outdoorLab = weatherLabel;
}

/**
 * 创建健康提示View
 */
- (void) createTipView
{
    UIView *view = [[UIView alloc] init];
    view.height = 143 + 64;
    view.width = MAINSCREEN.size.width;
    view.x = 0;
    view.y = 460 - 64;
    if (MAINSCREEN.size.height == 667) {
        view.y = 460 - 64;
    }else if(MAINSCREEN.size.height == 736)
    {
        view.y = 529 - 64;
    }
    [self.scrollView addSubview:view];
    self.firstView = view;
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_tip"]];
    bgImage.x = 0;
    bgImage.y = 0;
    bgImage.width = view.width;
    bgImage.height = view.height;
    [view addSubview:bgImage];
    
    UIView *tipView = [[UIView alloc] init];
    tipView.x = 0;
    tipView.y = 0;
    tipView.width = MAINSCREEN.size.width;
    tipView.height = 79 + 64;
//    tipView.backgroundColor = DDRGBColor(37, 38, 40);
    [view addSubview:tipView];
    
    //健康小提示的标签
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 28;
    titleLabel.y = 15;
    titleLabel.height = 14;
    titleLabel.width = 100;
    titleLabel.text = @"管家提示";
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    [tipView addSubview:titleLabel];
    
    //健康小提示内容
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.x = titleLabel.x + 2;
    tipLabel.y = titleLabel.bottom + 5;
    tipLabel.width = tipView.width - 60;
    tipLabel.height = 50 + 64;
    tipLabel.text = @"暂无建议";
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.numberOfLines = 0;
    tipLabel.height = 14;
    [tipView addSubview:tipLabel];
    self.tipLabel = tipLabel;
    
    //创建右划小箭头
    UIButton *arrowButton = [[UIButton alloc] init];
    arrowButton.width = 40;
    arrowButton.height = 60;
    arrowButton.x = tipView.width - arrowButton.width ;
    arrowButton.y = 0;
    [arrowButton setImage:[UIImage imageNamed:@"doubleArrowLeft2"] forState:UIControlStateNormal];
    [tipView addSubview:arrowButton];
    self.arrowBtn = arrowButton;
    
    UIButton *arrowButtonCover = [[UIButton alloc] init];
    arrowButtonCover.width = 40;
    arrowButtonCover.height = 60;
    arrowButtonCover.x = tipView.width - arrowButtonCover.width - 10 ;
    arrowButtonCover.y = 0;
    arrowButtonCover.backgroundColor = [UIColor clearColor];
    [arrowButtonCover addTarget:self action:@selector(leftGestureAction) forControlEvents:UIControlEventTouchUpInside];
    [tipView addSubview:arrowButtonCover];
   
    //创建手势
    UISwipeGestureRecognizer *leftGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftGestureAction)];
    leftGR.direction = UISwipeGestureRecognizerDirectionLeft;
    [view addGestureRecognizer:leftGR];
}

/**
 * 创建广告View
 */
- (void) createAdvertView
{
    UIImage *ad1 = [UIImage imageNamed:@"ad3"];
    UIImage *ad2 = [UIImage imageNamed:@"ad2"];
    NSArray *imageNames = [[NSArray alloc] initWithObjects:ad1,ad2,nil];
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 79+64, self.firstView.width, 64) shouldInfiniteLoop:YES imageNamesGroup:imageNames];
    cycleScrollView.delegate = self;
    cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    [self.firstView addSubview:cycleScrollView];
    cycleScrollView.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.dcScrollView = cycleScrollView;
}

/**
 * 创建不正常状态View
 */
- (void) createAbnormalView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 79;
    view.width = MAINSCREEN.size.width;
    view.height = 64;
    [self.firstView addSubview:view];
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"abnormal_bg"]];
    bgImage.x = 0;
    bgImage.y = 0;
    bgImage.width = view.width;
    bgImage.height = view.height;
    [view addSubview:bgImage];
    
    //灰白色线
    for (int i = 0; i < 2; i ++) {
        UILabel *hLine = [[UILabel alloc] init];
        hLine.x = 0;
        hLine.y = 64 * i;
        hLine.width = view.width;
        hLine.height = 1;
        hLine.backgroundColor = DDRGBAColor(255,255,255,0.8);
        [view addSubview:hLine];
        
        UILabel *vLine = [[UILabel alloc] init];
        vLine.x = view.width/3 * (i + 1);
        vLine.y = 0;
        vLine.width = 1;
        vLine.height = 64;
        vLine.backgroundColor = DDRGBAColor(255,255,255,0.8);
        [view addSubview:vLine];
    }
    
    for (int i = 0; i < 3; i ++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.x = view.width/3 * i;
        btn.y = 0;
        btn.width = view.width/3;
        btn.height = 32;
        btn.contentEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);
        
        UIButton *titleBtn = [[UIButton alloc] init];
        titleBtn.x = view.width/3 * i;
        titleBtn.y = 32;
        titleBtn.width = view.width/3;
        titleBtn.height = 32;
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [titleBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateSelected];
        
        if (i == 0) {
            [btn setImage:[UIImage imageNamed:@"abnormal_AQI"] forState:UIControlStateNormal];
            [titleBtn setTitle:@"开启净化器" forState:UIControlStateNormal];
        }else if (i == 1)
        {
            [btn setImage:[UIImage imageNamed:@"abnormal_TEM"] forState:UIControlStateNormal];
            [titleBtn setTitle:@"请开启空调" forState:UIControlStateNormal];
        }else if (i == 2)
        {
            [btn setImage:[UIImage imageNamed:@"abnormal_HUM"] forState:UIControlStateNormal];
            [titleBtn setTitle:@"开启加湿器" forState:UIControlStateNormal];
        }
        [view addSubview:titleBtn];
        [view addSubview:btn];
    }

}

/**
 * 创建chartView
 */
- (void)createChartView
{
    UIView *view = [[UIView alloc] init];
    view.width = MAINSCREEN.size.width;
    view.height = 370;
    view.x = MAINSCREEN.size.width;
    view.y = 440 - 64;    //494
    if (MAINSCREEN.size.height == 667) {
        view.y = 440 - 64;
    }else if(MAINSCREEN.size.height == 736)
    {
        view.y = 475 - 64;
    }
    [self.scrollView addSubview:view];
    self.chartView = view;
    view.backgroundColor = [UIColor clearColor];
    
    //创建手势
    UISwipeGestureRecognizer *rightGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightGestureAction)];
    rightGR.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:rightGR];
    
    //创建向上箭头
    UIView *additionView = [[UIView alloc] init];
    additionView.x = 0;
    additionView.y = 15;
    additionView.width = MAINSCREEN.size.width;
    additionView.height = 100;
    additionView.backgroundColor = [UIColor whiteColor];
    [view addSubview:additionView];
    
    UIButton *upArrow = [[UIButton alloc] init];
    upArrow.width = 25;
    upArrow.height = 15;
    upArrow.x = (MAINSCREEN.size.width - upArrow.width)/2;
    upArrow.y = 0 ;
    [upArrow setImage:[UIImage imageNamed:@"arrowUp"] forState:UIControlStateNormal];
    [upArrow addTarget:self action:@selector(upBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:upArrow];
    
    //创建右箭头
    UIButton *rightArrow = [[UIButton alloc] init];
    rightArrow.x = 0;
    rightArrow.y = 20;
    rightArrow.width = 40;
    rightArrow.height = 60;
    [rightArrow setImage:[UIImage imageNamed:@"doubleArrowRight"] forState:UIControlStateNormal];
    [view addSubview:rightArrow];
    self.rightArrowBtn = rightArrow;
    
    UIButton *rightArrowCover = [[UIButton alloc] init];
    rightArrowCover.x = 0;
    rightArrowCover.y = 20;
    rightArrowCover.width = 40;
    rightArrowCover.height = 40;
    rightArrowCover.backgroundColor = [UIColor clearColor];
    [view addSubview:rightArrowCover];
    [rightArrowCover addTarget:self action:@selector(rightGestureAction) forControlEvents:UIControlEventTouchUpInside];
    
    //其他家庭数据对比
    UILabel *otherFamily = [[UILabel alloc] init];
    otherFamily.width = 200;
    otherFamily.height = 20;
    otherFamily.x = view.width - 10 - otherFamily.width;
    otherFamily.y = 40;
    otherFamily.text = @"其他家庭数据对比";
    otherFamily.font = [UIFont systemFontOfSize:16];
    otherFamily.textAlignment = NSTextAlignmentRight;
    otherFamily.textColor = DDRGBColor(0, 244, 207);
    [view addSubview:otherFamily];
    
    //创建按钮的背景框和线
    UIView *bgView = [[UIView alloc] init];
    bgView.x = 10;
    bgView.y = otherFamily.bottom + 10;
    bgView.width = view.width - 20;
    bgView.height = 60;
    bgView.layer.cornerRadius = bgView.height * 0.2;
    bgView.layer.borderWidth = 0.5;
    bgView.layer.borderColor = DDRGBColor(188, 188, 188).CGColor;
    [view addSubview:bgView];
    
    UILabel *hLine = [[UILabel alloc] init];
    hLine.x = 10;
    hLine.y = 30;
    hLine.width = bgView.width - 20;
    hLine.height = 0.5;
    hLine.backgroundColor = DDRGBColor(188, 188, 188);
    [bgView addSubview:hLine];
    
    for (int i = 0; i < 3; i++) {
        UILabel *vLine = [[UILabel alloc] init];
        vLine.x = bgView.width/4 * (i + 1);
        vLine.y = 5;
        vLine.width = 0.5;
        vLine.height = bgView.height - 10;
        vLine.backgroundColor = DDRGBColor(150, 150, 150);
        [bgView addSubview:vLine];
    }
    
    //创建温度，气压，湿度，空气质量按钮  和  时间按钮
    NSArray *itemName = [[NSArray alloc] initWithObjects:@"温度",@"湿度",@
                         "AQI",@"气压", nil];
    NSArray *timeName = [[NSArray alloc] initWithObjects:@"今日",@"本周",@"本月",@"今年", nil];
    for(int i = 0; i < itemName.count;i++)
    {
        UIButton *btn = [[UIButton alloc] init];
        btn.x = bgView.width/4 * i;
        btn.y = 0;
        btn.height = 30;
        btn.width = bgView.width/4;
        [btn setTitle:[itemName objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:DDRGBColor(55, 55, 55) forState:UIControlStateNormal];
        [btn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(itemBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:btn];
        
        if (i == 0) {
            [btn setSelected:YES];
            self.selectedItemBtn = btn;
        }
    }
    
    for (int i = 0; i < timeName.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.x = bgView.width/4 * i;
        btn.y = 30;
        btn.height = 30;
        btn.width = bgView.width/4;
        [btn setTitle:[timeName objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:DDRGBColor(133, 133, 133) forState:UIControlStateNormal];
        [btn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(timeBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:btn];
        
        if (i == 0) {
            [btn setSelected:YES];
            self.selectedTimeBtn = btn;
        }
    }
    
    //创建颜色标记
    for (int i = 0; i < 3; i++) {
        UIView *color = [[UIView alloc] init];
        color.width = 10;
        color.height = 10;
        color.y = bgView.bottom + 15;
        color.x = MAINSCREEN.size.width - 65 *(3 - i);
        if (i == 0 || i == 2) {
           color.backgroundColor = DDRGBAColor(77, 186, 122, 0.8);
        }else if (i == 1)
        {
            color.backgroundColor = DDRGBAColor(245,94,78,0.5);
        }
        [view addSubview:color];
        if (i == 2) {
            UIView *lastColor = [[UIView alloc] init];
            lastColor.width = 10;
            lastColor.height = 10;
            lastColor.y = bgView.bottom + 15;
            lastColor.x = MAINSCREEN.size.width - 65;
            lastColor.backgroundColor = DDRGBAColor(245,94,78,0.5);
            [view addSubview:lastColor];
        }
        
        UILabel *name = [[UILabel alloc] init];
        name.x = color.right + 5;
        name.y = color.y -2;
        name.width = 40;
        name.height = 12;
        name.textColor = DDRGBColor(133, 133, 133);
        name.font = [UIFont systemFontOfSize:12];
        if (i == 0) {
            name.text = @":自家";
        }else if (i == 1)
        {
            name.text = @":别家";
        }else if (i == 2)
        {
            name.text = @":重合";
        }
        [view addSubview:name];
    }
    
    UILabel *unitlab = [[UILabel alloc] init];
    unitlab.x = 10;
    unitlab.y = bgView.bottom + 13;
    unitlab.width = 60;
    unitlab.height = 12;
    unitlab.text = @"单位:°C";
    unitlab.font = [UIFont systemFontOfSize:12];
    unitlab.textColor = DDRGBColor(133, 133, 133);
    [view addSubview:unitlab];
    self.unitLab = unitlab;
    
    //创建暂无数据视图
    UILabel *noDataLabel = [[UILabel alloc] init];
    noDataLabel.x = 0;
    noDataLabel.y = bgView.bottom + 120;
    noDataLabel.width = MAINSCREEN.size.width;
    noDataLabel.height = 14;
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    noDataLabel.textColor = DDRGBAColor(55, 55, 55,0.8);
    noDataLabel.font = [UIFont systemFontOfSize:14];
    noDataLabel.text = @"暂无图表数据";
    [view addSubview:noDataLabel];
}
#pragma mark SDCycleScrollViewDelegate
/** 
 * 点击图片回调 
 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSString *urlStr = [adUrlArray objectAtIndex:index];
    NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark pickView的delegate和datasource方法
/**
 * 分组的宽度
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 200;
}

/**
 * pickerView的高度
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60;
}

/**
 * 自定义pickView的View
 */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    for (int i = 0; i < pickerView.subviews.count; i++) {
        UIView *object = [pickerView.subviews objectAtIndex:i];

        if (i == 1 || i == 2) {
            
            [object removeFromSuperview];
        }else{
        }
    }
//    UIPickerColumnView 
    UIView *newView = [[UIView alloc] init];
    //值
    UILabel *content = [[UILabel alloc] init];
    content.x = 65;
    content.y = 0;
    content.width = 70;
    content.height = 60;
    content.textAlignment = NSTextAlignmentCenter;
    content.text = @"335";
    content.tag = 1;
    content.font = [UIFont fontWithName:@"DigifaceWide" size:20];
    content.textColor = [UIColor whiteColor];
    [newView addSubview:content];
    
    //单位
    UILabel *unit = [[UILabel alloc] init];
    unit.x = 130;
    unit.y = 0;
    unit.width = 45;
    unit.height = 60;
    unit.text = @"℃";
    unit.tag = 2;
    unit.font = [UIFont systemFontOfSize:20];
    unit.textColor = [UIColor whiteColor];
    unit.textAlignment = NSTextAlignmentCenter;
    [newView addSubview:unit];

    //标签
    UILabel *title = [[UILabel alloc] init];
    title.x = 15;
    title.y = 0;
    title.width = 50;
    title.height = 60;
    title.text = @"温度";
    title.tag = 0;
    title.font = [UIFont systemFontOfSize:20];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    [newView addSubview:title];

    if (row%4 == 0) {
        title.text = @"温度";
        unit.text = @"℃";
        content.text = [valueArray objectAtIndex:0];
        
    }else if (row%4 == 1)
    {
        title.text = @"湿度";
        unit.text = @"%";
        content.text = [valueArray objectAtIndex:1];
    }else if (row%4 == 2)
    {
        title.text = @"气压";
        unit.text = @"kPa";
        content.text = [valueArray objectAtIndex:2];
    }else if (row%4 == 3)
    {
        title.text = @"AQI";
        unit.text = @"ppm";
        content.text = [valueArray objectAtIndex:3];
    }
    return newView;
}

/**
 * 选择pickview的cell的触发
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(row == 0)
    {
        [pickerView selectRow:16 inComponent:0 animated:false];
    }else if(row == 79)
    {
        [pickerView selectRow:3 inComponent:0 animated:false];
    }

    [self setChoosedPickerViewStyle:pickerView];
    
    NSDictionary *moreDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"moreAdvise"];
    if (moreDic != nil) {
        [self setAdviceAndIntro:moreDic withSelectRow:row];
    }
}

/**
 * 设置被选择的样式
 */
- (void) setChoosedPickerViewStyle:(UIPickerView *)pickerView;
{
    UIView *view;
    NSInteger selectedRow;
    selectedRow = [pickerView selectedRowInComponent:0];
    
    view = [pickerView viewForRow:selectedRow forComponent:0];
    
    for (UILabel *object in view.subviews) {
    
        if (object.tag == 0) {
            object.x = 0;
        }else if (object.tag == 1)
        {
            if (object.text.length == 3) {
                object.font = [UIFont fontWithName:@"DigifaceWide" size:50];
            }else
            {
                object.font = [UIFont fontWithName:@"DigifaceWide" size:65];
            }
            object.width = 130;
            object.x = 35;
        }else if (object.tag == 2) {
            if(selectedRow % 4 == 3)
            {
                object.x = 160;
                
            }else{
                object.x = 150;
            }
        }
    }
}

/**
 * pickView的组数
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}

/**
 * 组中的内容个数
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return valueArray.count * 20;
}

/**
 * 判断当前是否有数据
 */
- (BOOL)ifHaveDataWithSelfArray:(NSArray *)selfArray andOtherArray:(NSArray *)otherArray
{
    NSInteger count = 0;
    for (int i = 0; i < selfArray.count; i ++) {
        if ([[selfArray objectAtIndex:i] integerValue] == -999) {
            count ++;
        }
    }
    
    for (int i = 0; i < otherArray.count; i ++) {
        if ([[otherArray objectAtIndex:i] integerValue] == -999) {
            count ++;
        }

    }
    
    if (count == (selfArray.count + otherArray.count)) {
        [self.nChartView removeFromSuperview];
        return false;
    }
    
    return true;
}

#pragma mark 点击事件，附属功能
/**
 * 扫描发送websocket请求
 */
- (void)scanSendWebSocketRequest:(NSNotification *)notification
{
    NSString *deviceID = [notification object];
    NSInteger deviceId = [deviceID integerValue];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = [userDefault objectForKey:@"userid"];
    
    param[@"device_id"] = @(deviceId);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    NSString *str = [self dictionaryToJson:param];
    [localWebSocket send:str];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCANADDEQU" object:nil];
}

/**
 * 发送websocket请求
 */
- (void)sendWebSocketRequest:(NSNotification *)notification
{
    [self getDeviceListRequest];
//    NSString *deviceID = [notification object];
//    NSInteger deviceId = [deviceID integerValue];
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    
//    param[@"user_id"] = [userDefault objectForKey:@"userid"];
//    
//    param[@"device_id"] = @(deviceId);
//    
//    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
//    
//    NSString *str = [self dictionaryToJson:param];
//    [localWebSocket send:str];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WEBSOCKET" object:nil];

}

/**
 * 温度，气压，湿度，AQI按钮点击事件
 */
- (void)itemBtnClickAction:(UIButton *)sender
{
    [self.selectedItemBtn setSelected:NO];
    self.selectedItemBtn = sender;
    [self.selectedItemBtn setSelected:YES];
    [self.nChartView removeFromSuperview];
    [self chooseDataSource:self.selectedItemBtn withTimeBtn:self.selectedTimeBtn];
    
    if ([sender.titleLabel.text isEqualToString:@"温度"]) {
        self.unitLab.text = @"单位:°C";
    }else if ([sender.titleLabel.text isEqualToString:@"湿度"]) {
        self.unitLab.text = @"单位:％";
    }else if ([sender.titleLabel.text isEqualToString:@"AQI"]) {
        self.unitLab.text = @"单位:ppm";
    }else if ([sender.titleLabel.text isEqualToString:@"气压"]) {
        self.unitLab.text = @"单位:kPa";
    }
}

/**
 * 今日，本周，本月，今年按钮点击事件
 */
- (void) timeBtnClickAction:(UIButton *)sender
{
    [self.selectedTimeBtn setSelected:NO];
    self.selectedTimeBtn = sender;
    [self.selectedTimeBtn setSelected:YES];
    [self.nChartView removeFromSuperview];
    [self chooseDataSource:self.selectedItemBtn withTimeBtn:self.selectedTimeBtn];
    if ([sender.titleLabel.text isEqualToString:@"今日"]) {
        [self chartDateRequestWithType:1];
    }else if ([sender.titleLabel.text isEqualToString:@"本周"])
    {
        [self chartDateRequestWithType:2];
    }else if ([sender.titleLabel.text isEqualToString:@"本月"])
    {
        [self chartDateRequestWithType:3];
    }else if ([sender.titleLabel.text isEqualToString:@"今年"])
    {
        [self chartDateRequestWithType:4];
    }
}

/**
 * 选择数据源数据new
 */
- (void)chooseDataSource:(UIButton *)itemButton withTimeBtn:(UIButton *)timeButton
{
    NSString *itemStr = itemButton.titleLabel.text;
    NSString *timeStr = timeButton.titleLabel.text;
    
    [self.nChartView removeFromSuperview];
    
    if ([itemStr isEqualToString:@"温度"]) {
        if (![self ifHaveDataWithSelfArray:temDayArray andOtherArray:temOtherDayArray]) {
            return;
        }
        
        if (temDayArray.count == 0 || temOtherDayArray.count == 0) {
            return;
        }else
        {
            [self createNewChartViewWithself:temDayArray withOther:temOtherDayArray withTimeType:timeStr withTimeArray:timeArray];
 
        }
    }else if ([itemStr isEqualToString:@"气压"])
    {

    }else if ([itemStr isEqualToString:@"湿度"])
    {
        if (![self ifHaveDataWithSelfArray:humDayArray andOtherArray:humOtherDayArray]) {
            return;
        }
        if (humDayArray.count == 0 || humOtherDayArray.count == 0) {
            return;
        }else
        {
            [self createNewChartViewWithself:humDayArray withOther:humOtherDayArray withTimeType:timeStr withTimeArray:timeArray];
  
        }
    }else if ([itemStr isEqualToString:@"AQI"])
    {
        if (![self ifHaveDataWithSelfArray:aqiDayArray andOtherArray:aqiOtherDayArray]) {
            return;
        }
        if (aqiDayArray.count == 0 || aqiOtherDayArray.count == 0) {
            return;
        }else
        {
            [self createNewChartViewWithself:aqiDayArray withOther:aqiOtherDayArray withTimeType:timeStr withTimeArray:timeArray];
        }
    }
}

/**
 * 右划事件
 */
- (void)rightGestureAction
{
    self.scrollView.contentSize = CGSizeMake(MAINSCREEN.size.width,598);
    [UIView animateWithDuration:0.4 animations:^{
        self.firstView.x = 0;
        self.chartView.x = MAINSCREEN.size.width;
    } completion:^(BOOL finished) {
    }];
}

/**
 * 左划事件
 */
- (void)leftGestureAction
{
//    if (requestNum == 0) {
//        requestNum ++;
        [self chartDateRequestWithType:1];
//    }
    
    self.scrollView.contentSize = CGSizeMake(MAINSCREEN.size.width,810 - 64);
    if (MAINSCREEN.size.height == 736) {
       self.scrollView.contentSize = CGSizeMake(MAINSCREEN.size.width,846 - 64);
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.firstView.x = 0 - MAINSCREEN.size.width;
        self.chartView.x = 0;
    } completion:^(BOOL finished) {
    }];
}

/**
 * 左上角按钮的点击事件
 */
- (void)leftBtnClickAction:(UIButton *)sender
{
//    ZJEqsInfoViewController *vc = [[ZJEqsInfoViewController alloc] init];
//    vc.delegate = self;
    ZJSettingViewController *vc = [[ZJSettingViewController alloc] init];
    sender.enabled = NO;
    [self.navigationController pushViewController:vc animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

/**
 * 创建定时刷新线程
 */
- (void)createThread

{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        
        [self loopMethod];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
//            [self.view layoutIfNeeded];
//            
//            [self.scrollView layoutIfNeeded];
            
        });
        
    });
}

/**
 * 定时刷新
 */
- (void)loopMethod

{
    NSTimer *timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(lampLightEvent) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

/**
 *  光晕效果触发事件
 */
- (void) lampLightEvent
{
    [UIView animateWithDuration:1.5 animations:^{
        self.rightArrowBtn.x = self.rightArrowBtn.x + 5;
        self.arrowBtn.x = self.arrowBtn.x - 5 ;
        self.lampLightImage.width = 320 ;
        self.lampLightImage.height = 320;
        self.lampLightImage.x = (MAINSCREEN.size.width - self.lampLightImage.width)/2;
        self.lampLightImage.y = (self.lampImage.height -  self.lampLightImage.height)/2 + self.lampImage.y - 20;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.5 animations:^{
            self.rightArrowBtn.x = self.rightArrowBtn.x - 5;
            self.arrowBtn.x = self.arrowBtn.x + 5;
            self.lampLightImage.width = 100;
            self.lampLightImage.height = 100;
            self.lampLightImage.x = (MAINSCREEN.size.width - self.lampLightImage.width)/2;
            self.lampLightImage.y = (self.lampImage.height -  self.lampLightImage.height)/2 + self.lampImage.y - 20;
        } completion:^(BOOL finished) {
        }];
    }];
}

/**
 * 右上角比较按钮点击事件
 */
- (void)compareClickAction
{
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialData defaultData].extConfig.title = @"";
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"www.baidu.com";
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"578c9262e0f55a3056001dc4"
                                      shareText:@""
                                     shareImage:[self snapshotScreenWithGL:self.view]
                                shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline]
                                       delegate:self];
}

/**
 * 友盟代理方法
 */
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

/**
 * 截屏
 */
- (UIImage*)snapshotScreenWithGL:(UIView *)videoView
{
    CGSize size = videoView.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGRect rec = CGRectMake(videoView.frame.origin.x, videoView.frame.origin.y, videoView.bounds.size.width, videoView.bounds.size.height);
    [self.view drawViewHierarchyInRect:rec afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData * data = UIImagePNGRepresentation(image);
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filename = [[path objectAtIndex:0] stringByAppendingPathComponent:@"foo.png"];
    [data writeToFile:filename atomically:YES];
    
    return image;
}

/**
 * 选择蘑菇灯后的代理方法
 */
- (void)chooseLamp:(ZJLampInfo *)lamp
{
    valueArray = [[NSArray alloc] initWithObjects:@"--",@"--",@"--",@"--",nil];
    [self.pickView reloadComponent:0];
    [self setChoosedPickerViewStyle:self.pickView];
    [self.lampImage setImage:[UIImage imageNamed:@"greenLamp"]];
    [self.lampLightImage setImage:[UIImage imageNamed:@"greenGlow"]];
    [self.stateBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
    self.stateBtn.layer.borderColor = DDRGBColor(0, 244, 207).CGColor;
    [self.stateBtn setTitle:@"暂无数据" forState:UIControlStateNormal];
    [self.tipLabel setText:@"  暂无建议"];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    deviceId = [lamp.device_id integerValue];
    self.lampName.text = lamp.name;
    
    [userDefault removeObjectForKey:@"moreAdvise"];
    [userDefault synchronize];
    
//    param[@"user_id"] = [userDefault objectForKey:@"userid"];
//    
//    param[@"device_id"] = @(deviceId);
//    
//    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
//    
//    NSString *str = [self dictionaryToJson:param];
//    [localWebSocket send:str];
}

/**
 * 从蘑菇灯界面返回首页
 */
- (void)returnHome
{
//    [self getDeviceListRequest];
}

/**
 * 字典转字符串
 */
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/**
 * JSON转字典
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

/**
 * 计算高度
 */
-(CGSize)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 10;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
                          };
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size;
}

/**
 * 退出登录的通知
 */
- (void)quitNotification
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"该账号在另一台设备登录，如非本人操作，请重置密码登录。" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        ZJLoginViewController *login = [[ZJLoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
        [self.navigationController presentViewController:nav animated:YES completion:^{
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault removeObjectForKey:@"token"];
            [userDefault removeObjectForKey:@"userid"];
            [userDefault synchronize];
            
        }];

    }];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
    
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"QUIT" object:nil];
}

/**
 *  向上按钮点击事件
 */
- (void) upBtnClickAction
{
    CGFloat offset = self.scrollView.contentSize.height - self.scrollView.bounds.size.height + 49;
    if (offset > 0)
    {
        [self.scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
    }
}

/**
 * 创建血压view
 */
- (void)popBloodPressView
{
    ZJBloodPressView *bv = [[ZJBloodPressView alloc] initWithFrame:CGRectMake(0, 0,self.scrollView.width,460)];
    bv.delegate = self;
    if (MAINSCREEN.size.height == 667) {
        bv.height = 460;
    }else if (MAINSCREEN.size.height == 736)
    {
        bv.height = 529;
    }
    
    [self.scrollView addSubview:bv];
    self.bpView = bv;
}

/**
 * ZJBloodPressViewDelegate方法
 */
- (void)closeBloodPressView
{
    NSDictionary *moreDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"moreAdvise"];
    if (moreDic != nil) {
        [self setAdviceAndIntro:moreDic withSelectRow:[self.pickView selectedRowInComponent:0]];
    }

    [self.bpView removeFromSuperview];
    self.bpView = nil;
}

/**
 * ZJOutdoorWeatherViewDelegate方法
 */
- (void)showOutdoorWeather
{
    NSDictionary *dic = [NSDictionary dictionary];
    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
    effe.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 140);
    effe.alpha = 0;
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:effe];
    self.effectView = effe;
    
    [UIView animateWithDuration:0.5 animations:^{
        effe.alpha = 0.9;
    } completion:^(BOOL finished) {
        CGFloat height;
        if (MAINSCREEN.size.height == 568) {
            height = 50;
        }else
        {
            height = 100;
        }

        ZJOutdoorWeatherDetailView  *dv = [[ZJOutdoorWeatherDetailView alloc] initWithFrame:CGRectMake(15, height, self.view.width - 30, 500) withDic:dic withDeviceID:deviceId];
        dv.delegate = self;
        [effe addSubview:dv];
    }];
}

/**
 * ZJOutdoorWeatherDetailViewDelegate方法
 */
- (void)closeWeatherView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.effectView.alpha = 0;
        [self.tabBarController.tabBar setHidden:NO];
    } completion:^(BOOL finished) {
        [self.effectView removeFromSuperview];
        self.effectView = nil;
    }];
}
@end
