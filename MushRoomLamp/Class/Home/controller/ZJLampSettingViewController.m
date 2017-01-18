//
//  ZJLampSettingViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 7/1/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJLampSettingViewController.h"
#import "Constant.h"
#import "ZJInterface.h"
#import "MBProgressHUD+NJ.h"
#import "ZJQRCodeViewController.h"
#import "ZJChangeNameViewController.h"
#import "ZJAlarmClockViewController.h"

@interface ZJLampSettingViewController ()<UITextFieldDelegate,ZJInterfaceDelegate,ZJChangeNameDelegate>
{
    /** 开始睡眠时间 */
    NSDate *startDate;
    /** 结束睡眠时间 */
    NSDate *endDate;
    /** 修改名称的点击次数 */
    NSInteger clickNum;
}
/** 炫彩模式的switch按钮 */
@property (nonatomic,strong) UISwitch *colorSwitch;
/** 语音模式的switch按钮 */
@property (nonatomic,strong) UISwitch *voiceSwitch;
/** 投影模式的switch按钮 */
@property (nonatomic,strong) UISwitch *movieSwitch;
/** 睡眠模式的switch按钮 */
@property (nonatomic,strong) UISwitch *sleepSwitch;
/** StartTimeView */
@property (nonatomic,strong) UIView *startTimeView;
/** EndTimeView */
@property (nonatomic,strong) UIView *endTimeView;
/** SleepTimeView */
@property (nonatomic,strong) UIView *sleepTimeView;
/** 睡眠模式开始时间按钮 */
@property (nonatomic,strong) UIButton *startTimeBtn;
/** 睡眠模式结束时间按钮 */
@property (nonatomic,strong) UIButton *endTimeBtn;
/** BlackButton */
@property (nonatomic,strong) UIButton *blackButton;
/** startDatePicker  */
@property (nonatomic,strong) UIDatePicker *startDatePicker;
/** endDatePicker */
@property (nonatomic,strong) UIDatePicker *endDatepicker;
/** 名称Text */
@property (nonatomic,strong) UITextField *nameText;
/** 灯的设置信息接口 */
@property (nonatomic,strong) ZJInterface *interfaceLampSetting;
/** 设置灯的接口 */
@property (nonatomic,strong) ZJInterface *interfaceSetLamp;
//** 语音模式的接口 *／
@property (nonatomic,strong) ZJInterface *interfaceVoice;
/**  投影模式的接口 */
@property (nonatomic,strong) ZJInterface *interfaceMovie;
/** 二维码View */
@property (nonatomic,strong) UIView *qrCodeView;
/** 开始时间和结束时间View上的灰色遮罩 */
@property (nonatomic,strong) UIView *grayView;
@end

@implementation ZJLampSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
/**
 * 设置灯的网络请求
 */
- (void) requestSetLamp
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"deviceId"] = @([self.device_id integerValue]);
    
    param[@"terminalId"] = @(1);
    
    if ([self.colorSwitch isOn]) {
        param[@"isColorful"] = @"Y";
    }else
    {
        param[@"isColorful"] = @"N";
    }
    
    if ([self.sleepSwitch isOn]) {
        param[@"state"] = @(3);
    }else{
        param[@"state"] = @(0);
    }
    
    NSString *start = [NSString stringWithFormat:@"%@:00",self.startTimeBtn.titleLabel.text];
    param[@"beginTime"] = start;
    
    NSString *end = [NSString stringWithFormat:@"%@:00",self.endTimeBtn.titleLabel.text];
    param[@"endTime"] = end;
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceSetLamp = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceSetLamp interfaceWithType:INTERFACE_TYPE_SETLAMP param:param];
}

/**
 * 获取灯的设置信息网络请求
 */
- (void) requestGetLampSettingInfo
{
    [MBProgressHUD showMessage:@""];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"deviceId"] = @([self.device_id integerValue]);
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceLampSetting = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceLampSetting interfaceWithType:INTERFACE_TYPE_LAMPSETTING param:param];
}

/**
 *  语音模式网络请求
 */
- (void) requestVoice
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"deviceId"] = @([self.device_id integerValue]);
    
    if ([self.voiceSwitch isOn]) {
        param[@"isSpeech"] = @"Y";
    }else{
        param[@"isSpeech"] = @"N";
    }
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceMovie = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceMovie interfaceWithType:INTERFACE_TYPE_SETLAMP param:param];
}

/**
 *  投影模式网络请求
 */
- (void) requestMovie
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"deviceId"] = @([self.device_id integerValue]);
    
    if ([self.movieSwitch isOn]) {
        param[@"isProject"] = @"Y";
    }else{
        param[@"isProject"] = @"N";
    }

    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceVoice = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceVoice interfaceWithType:INTERFACE_TYPE_SETLAMP param:param];

}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    if (interface == self.interfaceLampSetting)
    {
        [MBProgressHUD hideHUD];
        if ([result[@"code"] isEqual:@(0)]) {
            if ((NSNull *)result[@"data"] == [NSNull null]) {
                
            }else{
                [self setLampSettingInfoWithDic:result[@"data"]];
            }
        }else
        {
            [MBProgressHUD showError:@"操作异常"];
        }
    }else {
//        NSLog(@"%@",result[@"msg"]);
    }
}

/**
 * 读取服务器，获取设备设置信息
 */
- (void)setLampSettingInfoWithDic:(NSDictionary *)result
{
    if ([result[@"state"] isEqual:@(3)] ) {
        [self.sleepSwitch setOn:YES];
         self.grayView.x = 0;
    }else if ([result[@"state"] isEqual:@(0)])
    {
        [self.sleepSwitch setOn:NO];
        self.grayView.x = MAINSCREEN.size.width;
    }
    
    if ([result[@"isColorful"] isEqualToString:@"N"]) {
        [self.colorSwitch setOn:NO];
    }else if ([result[@"isColorful"] isEqualToString:@"Y"])
    {
        [self.colorSwitch setOn:YES];
    }
    
    if ([result[@"isSpeech"] isEqualToString:@"N"]) {
        [self.voiceSwitch setOn:NO];
    }else if([result[@"isSpeech"] isEqualToString:@"Y"])
    {
        [self.voiceSwitch setOn:YES];
    }else if([result[@"isSpeech"] isEqualToString:@"S"])
    {
        [self.voiceSwitch setOn:NO];
        [self.voiceSwitch setEnabled:NO];
    }
    
    if ([result[@"isProject"] isEqualToString:@"N"]) {
        [self.movieSwitch setOn:NO];
    }else if([result[@"isProject"] isEqualToString:@"Y"])
    {
        [self.movieSwitch setOn:YES];
    }else if([result[@"isProject"] isEqualToString:@"S"])
    {
        [self.movieSwitch setOn:NO];
        [self.movieSwitch setEnabled:NO];
    }
    
    [self.startTimeBtn setTitle:[result[@"beginTime"] substringToIndex:5] forState:UIControlStateNormal];
    [self.endTimeBtn setTitle:[result[@"endTime"] substringToIndex:5]  forState:UIControlStateNormal];
}

/**
 * 初始化View
 */
- (void)initView
{
    self.view.backgroundColor = DDRGBColor(233, 233, 233);
    
    [self setClickNumZero];
    [self createTitleView];
    
    [self createSleepTimeView];
    
    [self createNameView];
    
    [self createShareDevice];
    
    [self createColorfulView];
    
    [self createVoiceView];
    
    [self createAlarmClockView];
    
    [self createSleepView];
    
    [self createBlackBg];
        
    [self createStartTimeView];
    
    [self createEndTimeView];
    
    [self initValue];
    
    [self requestGetLampSettingInfo];
}

/**
 * 设置初始化值
 */
- (void)initValue
{
//    [self.sleepTimeView setHidden:YES];
    self.sleepTimeView.y = self.sleepTimeView.y - self.sleepTimeView.height - 1;
    self.nameText.text = self.deviceName;
}

/**
 * 创建titleView
 */
- (void)createTitleView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 0;
    view.width = MAINSCREEN.size.width;
    view.height = 93;
    [self.view addSubview:view];
    
    //黑色背景
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eqs_title_bg"]];
    imageView.x = 0;
    imageView.y = 0;
    imageView.width = view.width;
    imageView.height = view.height;
    [view addSubview:imageView];
    
    //<按钮
    UIButton *closeBtn = [[UIButton alloc] init];
    closeBtn.x = 8;
    closeBtn.y = 23;
    closeBtn.width = 40;
    closeBtn.height = 40;
    [closeBtn setImage:[UIImage imageNamed:@"green_arrow_left"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(cancelClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 37;
    titleLabel.width = MAINSCREEN.size.width;
    titleLabel.height = 17;
    titleLabel.text = @"设备设置";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    
    //生成二维码按钮
//    UIButton *qrCodeBtn = [[UIButton alloc] init];
//    qrCodeBtn.width = 40;
//    qrCodeBtn.height = 40;
//    qrCodeBtn.x = view.width - qrCodeBtn.width - 8;
//    qrCodeBtn.y = 23;
//    [qrCodeBtn setImage:[UIImage imageNamed:@"qrcode"] forState:UIControlStateNormal];
//    [qrCodeBtn addTarget:self action:@selector(qrCodeClickAction:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:qrCodeBtn];
}

/**
 * 创建设备命名View
 */
- (void)createNameView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 80;
    view.width = MAINSCREEN.size.width;
    view.height = 60;
    view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeNameClickAction)];
    [view addGestureRecognizer:tapGesture];
    [self.view addSubview:view];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"name"]];
    icon.width = 21;
    icon.height = 21;
    icon.x = 20;
    icon.y = (view.height - icon.height)/2;
    [view addSubview:icon];
    
    UILabel *label = [[UILabel alloc] init];
    label.x = icon.right + 10;
    label.y = 0;
    label.width = 80;
    label.height = view.height;
    label.text = @"修改名称";
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.width = 180;
    textField.height = 70;
    textField.x = view.width - 20 - textField.width;
    textField.y = 0;
    textField.text = @"客厅的蘑菇灯";
    textField.textAlignment = NSTextAlignmentRight;
    textField.textColor = DDRGBColor(188,188,188);
    textField.delegate = self;
    textField.userInteractionEnabled = NO;
    [view addSubview:textField];
    self.nameText = textField;
}

/**
 * 创建分享设备
 */
- (void)createShareDevice
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 140;
    view.width = MAINSCREEN.size.width;
    view.height = 60;
    view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(qrCodeClickAction:)];
    [view addGestureRecognizer:tapGesture];
    [self.view addSubview:view];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode"]];
    icon.width = 21;
    icon.height = 21;
    icon.x = 20;
    icon.y = (view.height - icon.height)/2;
    [view addSubview:icon];
    
    UILabel *label = [[UILabel alloc] init];
    label.x = icon.right + 10;
    label.y = 0;
    label.width = 80;
    label.height = view.height;
    label.text = @"分享设备";
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
    UIButton *arrow = [[UIButton alloc] init];
    arrow.width = 40;
    arrow.height = 40;
    arrow.x = view.width - arrow.width - 20;
    arrow.y = 15;
    [arrow setImage:[UIImage imageNamed:@"green_arrow_right"] forState:UIControlStateNormal];
    [view addSubview:arrow];
    
    //灰色分割线
    UILabel *grayLabel = [[UILabel alloc] init];
    grayLabel.x = 0;
    grayLabel.y = 0;
    grayLabel.height = 1;
    grayLabel.width = view.width;
    grayLabel.backgroundColor = DDRGBColor(233, 233, 233);
    [view addSubview:grayLabel];
}

/**
 * 创建炫彩模式
 */
- (void)createColorfulView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 200;
    view.width = MAINSCREEN.size.width;
    view.height = 60;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"color"]];
    icon.width = 21;
    icon.height = 21;
    icon.x = 20;
    icon.y = (view.height - icon.height)/2;
    [view addSubview:icon];
    
    UILabel *label = [[UILabel alloc] init];
    label.x = icon.right + 10;
    label.y = 0;
    label.width = 80;
    label.height = view.height;
    label.text = @"炫彩模式";
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
//    UIButton *timeBtn = [[UIButton alloc] init];
//    timeBtn.width = 150;
//    timeBtn.height = 40;
//    timeBtn.x = view.width - timeBtn.width - 71;
//    timeBtn.y = 15;
//    timeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [timeBtn setTitle:@"" forState:UIControlStateNormal];
//    [timeBtn setTitleColor:DDRGBAColor(133, 133, 133, 1) forState:UIControlStateNormal];
//    [view addSubview:timeBtn];
    
    //开关按钮
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.width = 51;
    switchView.height = 31;
    switchView.x = MAINSCREEN.size.width - 20 -switchView.width;
    switchView.y =  20;
    [view addSubview:switchView];
    switchView.onTintColor = DDRGBColor(0, 244, 207);
    [switchView addTarget:self action:@selector(openColorClickAction:) forControlEvents:UIControlEventValueChanged];
    self.colorSwitch = switchView;
    
    //灰色分割线
    UILabel *grayLabel = [[UILabel alloc] init];
    grayLabel.x = 0;
    grayLabel.y = 0;
    grayLabel.height = 1;
    grayLabel.width = view.width;
    grayLabel.backgroundColor = DDRGBColor(233, 233, 233);
    [view addSubview:grayLabel];
}

/**
 *  创建语音模式
 */
- (void)createVoiceView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 260;
    view.width = MAINSCREEN.size.width;
    view.height = 60;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice"]];
    icon.width = 21;
    icon.height = 21;
    icon.x = 20;
    icon.y = (view.height - icon.height)/2;
    [view addSubview:icon];
    
    UILabel *label = [[UILabel alloc] init];
    label.x = icon.right + 10;
    label.y = 0;
    label.width = 80;
    label.height = view.height;
    label.text = @"语音模式";
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
    //开关按钮
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.width = 51;
    switchView.height = 31;
    switchView.x = MAINSCREEN.size.width - 20 -switchView.width;
    switchView.y =  20;
    [view addSubview:switchView];
    switchView.onTintColor = DDRGBColor(0, 244, 207);
    [switchView addTarget:self action:@selector(openMVClickAction:) forControlEvents:UIControlEventValueChanged];
    self.voiceSwitch = switchView;
    
    //灰色分割线
    UILabel *grayLabel = [[UILabel alloc] init];
    grayLabel.x = 0;
    grayLabel.y = 0;
    grayLabel.height = 1;
    grayLabel.width = view.width;
    grayLabel.backgroundColor = DDRGBColor(233, 233, 233);
    [view addSubview:grayLabel];
}

/**
 * 创建蘑菇闹钟
 */
- (void)createAlarmClockView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 320;
    view.width = MAINSCREEN.size.width;
    view.height = 60;
    view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alarmClockClickAction)];
    [view addGestureRecognizer:tapGesture];
    [self.view addSubview:view];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock"]];
    icon.width = 21;
    icon.height = 21;
    icon.x = 20;
    icon.y = (view.height - icon.height)/2;
    [view addSubview:icon];
    
    UILabel *label = [[UILabel alloc] init];
    label.x = icon.right + 10;
    label.y = 0;
    label.width = 80;
    label.height = view.height;
    label.text = @"蘑菇闹钟";
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
    UIButton *arrow = [[UIButton alloc] init];
    arrow.width = 40;
    arrow.height = 40;
    arrow.x = view.width - arrow.width - 20;
    arrow.y = 15;
    [arrow setImage:[UIImage imageNamed:@"green_arrow_right"] forState:UIControlStateNormal];
    [view addSubview:arrow];
    
    //灰色分割线
    UILabel *grayLabel = [[UILabel alloc] init];
    grayLabel.x = 0;
    grayLabel.y = 0;
    grayLabel.height = 1;
    grayLabel.width = view.width;
    grayLabel.backgroundColor = DDRGBColor(233, 233, 233);
    [view addSubview:grayLabel];

}

/**
 * 创建灯光休眠
 */
- (void)createSleepView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 380;
    view.width = MAINSCREEN.size.width;
    view.height = 60;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sleep"]];
    icon.width = 21;
    icon.height = 21;
    icon.x = 20;
    icon.y = (view.height - icon.height)/2;
    [view addSubview:icon];
    
    UILabel *label = [[UILabel alloc] init];
    label.x = icon.right + 10;
    label.y = 0;
    label.width = 80;
    label.height = view.height;
    label.text = @"灯光休眠";
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
//    UIButton *timeBtn = [[UIButton alloc] init];
//    timeBtn.width = 150;
//    timeBtn.height = 40;
//    timeBtn.x = view.width - timeBtn.width - 71;
//    timeBtn.y = 15;
//    timeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [timeBtn setTitle:@"" forState:UIControlStateNormal];
//    [timeBtn setTitleColor:DDRGBAColor(133, 133, 133, 1) forState:UIControlStateNormal];
//    [view addSubview:timeBtn];
    
    //开关按钮
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.width = 51;
    switchView.height = 31;
    switchView.x = MAINSCREEN.size.width - 20 -switchView.width;
    switchView.y =  20;
    [view addSubview:switchView];
    switchView.onTintColor = DDRGBColor(0, 244, 207);
    [switchView addTarget:self action:@selector(openSleepClickAction:) forControlEvents:UIControlEventValueChanged];
    self.sleepSwitch = switchView;
    
    //灰色分割线
    UILabel *grayLabel = [[UILabel alloc] init];
    grayLabel.x = 0;
    grayLabel.y = 0;
    grayLabel.height = 1;
    grayLabel.width = view.width;
    grayLabel.backgroundColor = DDRGBColor(233, 233, 233);
    [view addSubview:grayLabel];
}

/**
 * 创建睡眠开始和截止时间View
 */
- (void)createSleepTimeView
{
    UIView *SETimeView = [[UIView alloc] init];
    SETimeView.x = 0;
    SETimeView.y = 460.5 + 70;
    SETimeView.height = 89;
    SETimeView.width = MAINSCREEN.size.width;
    SETimeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:SETimeView];
    self.sleepTimeView = SETimeView;
    
    //开始时间
    UILabel *startLab = [[UILabel alloc] init];
    startLab.x = 20;
    startLab.y = 0;
    startLab.height = 44;
    startLab.width = 80;
    startLab.text = @"开始时间";
    startLab.font = [UIFont systemFontOfSize:14];
    [SETimeView addSubview:startLab];
    
    //结束时间
    UILabel *endLab = [[UILabel alloc] init];
    endLab.x = 20;
    endLab.y = 45;
    endLab.width = 80;
    endLab.height = 44;
    endLab.text = @"结束时间";
    endLab.font = [UIFont systemFontOfSize:14];
    [SETimeView addSubview:endLab];
    
    //中间灰色分割线
    UILabel *grayLine = [[UILabel alloc] init];
    grayLine.x = 20;
    grayLine.y = 44;
    grayLine.width = MAINSCREEN.size.width - 20;
    grayLine.height = 0.5;
    grayLine.backgroundColor = DDRGBColor(233, 233, 233);
    [SETimeView addSubview:grayLine];
    
    //开始时间按钮
    UIButton *startBtn = [[UIButton alloc] init];
    startBtn.x = startLab.right + 10;
    startBtn.y = 0;
    startBtn.width = MAINSCREEN.size.width - 20 - startBtn.x;
    startBtn.height = 44;
    startBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [startBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    startBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [startBtn addTarget:self action:@selector(startTimeClickAction) forControlEvents:UIControlEventTouchUpInside];
    [startBtn setTitle:@"00:00" forState:UIControlStateNormal];
    [SETimeView addSubview:startBtn];
    self.startTimeBtn = startBtn;
    
    //结束时间按钮
    UIButton *endBtn = [[UIButton alloc] init];
    endBtn.x = startLab.right + 10;
    endBtn.y = 45;
    endBtn.width = MAINSCREEN.size.width - 20 - endBtn.x;
    endBtn.height = 44;
    endBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [endBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    endBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [endBtn addTarget:self action:@selector(endTimeClickAction) forControlEvents:UIControlEventTouchUpInside];
    [endBtn setTitle:@"00:00" forState:UIControlStateNormal];
    [SETimeView addSubview:endBtn];
    self.endTimeBtn = endBtn;
    
    //灰色遮罩
    UIView *blackView = [[UIView alloc] init];
    blackView.x = MAINSCREEN.size.width;
    blackView.y = 0;
    blackView.width = SETimeView.width;
    blackView.height = SETimeView.height;
    blackView.backgroundColor = DDRGBAColor(188, 188, 188,0.5);
    [SETimeView addSubview:blackView];
    self.grayView = blackView;
}

/**
 * 左上角X按钮的点击事件
 */
- (void)cancelClickAction:(UIButton *)sender
{
    sender.enabled = NO;
    [self.navigationController popViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

/**
 * 生成二维码按钮点击事件
 */
- (void)qrCodeClickAction:(UIButton *)sender
{
    sender.enabled = NO;
    ZJQRCodeViewController *vc = [[ZJQRCodeViewController alloc] init];
    vc.deviceID = self.device_id;
    [self.navigationController pushViewController:vc animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

/**
 * 开始时间按钮点击事件
 */
- (void)startTimeClickAction
{
    self.blackButton.y = 0;
    [UIView animateWithDuration:0.4 animations:^{
        self.blackButton.backgroundColor = DDRGBAColor(0, 0, 0, 0.5);
        self.startTimeView.y = MAINSCREEN.size.height - self.startTimeView.height;
    } completion:^(BOOL finished) {
        self.startTimeView.y = MAINSCREEN.size.height - self.startTimeView.height;
    }];
}

/**
 * 结束时间按钮点击事件
 */
- (void)endTimeClickAction
{
    self.blackButton.y = 0;
    [UIView animateWithDuration:0.4 animations:^{
        self.blackButton.backgroundColor = DDRGBAColor(0, 0, 0, 0.5);
        self.endTimeView.y = MAINSCREEN.size.height - self.endTimeView.height;
    } completion:^(BOOL finished) {
        self.endTimeView.y = MAINSCREEN.size.height - self.endTimeView.height;
    }];
}

/**
 * 开始时间View的确定按钮点击事件
 */
- (void) startOKBtnClickAction
{
//    startDate = self.startDatePicker.date;
//    if (endDate != nil) {
//        if ([startDate compare:endDate] > 0) {
//            [MBProgressHUD showError:@"开始时间不能晚于结束时间"];
//            return;
//        }
//    }
    [UIView animateWithDuration:0.4 animations:^{
        self.startTimeView.y = MAINSCREEN.size.height;
        self.blackButton.backgroundColor = DDRGBAColor(0, 0, 0, 0);
    } completion:^(BOOL finished) {
        self.startTimeView.y = MAINSCREEN.size.height;
        self.blackButton.y = MAINSCREEN.size.height;
        NSDate *date =  self.startDatePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *destDateString = [dateFormatter stringFromDate:date];
        [self.startTimeBtn setTitle:destDateString forState:UIControlStateNormal];
    }];
}

/**
 * 结束时间View的确定按钮点击事件
 */
- (void) endOKBtnClickAction
{
//    endDate = self.endDatepicker.date;
//    if (startDate != nil) {
//        if ([startDate compare:endDate] > 0) {
//            [MBProgressHUD showError:@"结束时间不能早于开始时间"];
//            return;
//        }
//    }
    [UIView animateWithDuration:0.4 animations:^{
        self.endTimeView.y = MAINSCREEN.size.height;
        self.blackButton.backgroundColor = DDRGBAColor(0, 0, 0, 0);
    } completion:^(BOOL finished) {
        self.endTimeView.y = MAINSCREEN.size.height;
        self.blackButton.y = MAINSCREEN.size.height;
        NSDate *date =  self.endDatepicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *destDateString = [dateFormatter stringFromDate:date];
        [self.endTimeBtn setTitle:destDateString forState:UIControlStateNormal];
    }];
}

/**
 * 创建开始时间View
 */
- (void) createStartTimeView
{
    UIView *timeView = [[UIView alloc] init];
    timeView.x = 0;
    timeView.y = MAINSCREEN.size.height;
    timeView.width = MAINSCREEN.size.width;
    timeView.height = 250;
    timeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:timeView];
    self.startTimeView = timeView;
    
    UIDatePicker *datePick = [[UIDatePicker alloc] init];
    datePick.x = 0;
    datePick.y = 40;
    datePick.width = timeView.width;
    datePick.height = timeView.height - 40;
    [timeView addSubview:datePick];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中
    datePick.datePickerMode = UIDatePickerModeTime;
    datePick.locale = locale;
    self.startDatePicker = datePick;
    
    //title
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 0;
    view.width = timeView.width;
    view.height = 40;
    view.backgroundColor = [UIColor whiteColor];
    [timeView addSubview:view];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 0;
    titleLabel.width = view.width;
    titleLabel.height = 40;
    titleLabel.text = @"开始时间";
    titleLabel.textColor = DDRGBColor(55, 55, 55);
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    
    UIButton *OKBtn = [[UIButton alloc] init];
    OKBtn.width = 50;
    OKBtn.height = 40;
    OKBtn.x = view.width - 20 - OKBtn.width;
    OKBtn.y = 0;
    [OKBtn setTitle:@"确定" forState:UIControlStateNormal];
    [OKBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
    OKBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [OKBtn addTarget:self action:@selector(startOKBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:OKBtn];
    
    //分割线
    UILabel *line = [[UILabel alloc] init];
    line.x = 0;
    line.y = 40;
    line.width = view.width;
    line.height = 0.5;
    line.backgroundColor = DDRGBColor(233,233,233);
    [view addSubview:line];
}

/**
 * 创建结束时间View
 */
- (void) createEndTimeView
{
    UIView *timeView = [[UIView alloc] init];
    timeView.x = 0;
    timeView.y = MAINSCREEN.size.height;
    timeView.width = MAINSCREEN.size.width;
    timeView.height = 250;
    timeView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:timeView];
    self.endTimeView = timeView;
    
    UIDatePicker *datePick = [[UIDatePicker alloc] init];
    datePick.x = 0;
    datePick.y = 40;
    datePick.width = timeView.width;
    datePick.height = timeView.height - 40;
    [timeView addSubview:datePick];
    datePick.datePickerMode = UIDatePickerModeTime;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中
    datePick.locale = locale;
    self.endDatepicker = datePick;
    
    //title
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 0;
    view.width = timeView.width;
    view.height = 40;
    view.backgroundColor = [UIColor whiteColor];
    [timeView addSubview:view];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 0;
    titleLabel.width = view.width;
    titleLabel.height = 40;
    titleLabel.text = @"结束时间";
    titleLabel.textColor = DDRGBColor(55, 55, 55);
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    
    UIButton *OKBtn = [[UIButton alloc] init];
    OKBtn.width = 50;
    OKBtn.height = 40;
    OKBtn.x = view.width - 20 - OKBtn.width;
    OKBtn.y = 0;
    [OKBtn setTitle:@"确定" forState:UIControlStateNormal];
    [OKBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
    OKBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [OKBtn addTarget:self action:@selector(endOKBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:OKBtn];
    
    //分割线
    UILabel *line = [[UILabel alloc] init];
    line.x = 0;
    line.y = 40;
    line.width = view.width;
    line.height = 0.5;
    line.backgroundColor = DDRGBColor(233,233,233);
    [view addSubview:line];
}

/**
 * 创建黑色背景
 */
- (void)createBlackBg
{
    UIButton *blackBtton = [UIButton buttonWithType:UIButtonTypeCustom];
    blackBtton.x = 0;
    blackBtton.y = MAINSCREEN.size.height;
    blackBtton.width = MAINSCREEN.size.width;
    blackBtton.height = MAINSCREEN.size.height;
    blackBtton.backgroundColor = DDRGBAColor(0, 0, 0, 0);
    [self.view addSubview:blackBtton];
    self.blackButton = blackBtton;
}

/**
 * 更改名字按钮的点击事件
 */
- (void)changeNameClickAction
{
    if (clickNum++ == 0) {
        
        ZJChangeNameViewController *vc = [[ZJChangeNameViewController alloc] init];
        vc.preName = self.nameText.text;
        vc.deviceID = self.device_id;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        [self performSelector:@selector(setClickNumZero) withObject:self afterDelay:1];
    }
}

/**
 * 设置ClickNum为0
 */
- (void)setClickNumZero
{
    clickNum = 0;
}
/**
 * 打开炫彩模式的点击事件
 */
- (void) openColorClickAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        [self.sleepSwitch setOn:NO];
    }else
    {
    }

    [self requestSetLamp];
}

/**
 * 蘑菇闹钟按钮的点击事件
 */
- (void)alarmClockClickAction
{
    ZJAlarmClockViewController *vc = [[ZJAlarmClockViewController alloc] init];
    vc.device_id = self.device_id;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 * 打开语音,投影模式的点击事件
 */
- (void) openMVClickAction:(UISwitch *)sender
{
    if (self.voiceSwitch == sender) {
        [self requestVoice];
    }else if (self.movieSwitch == sender)
    {
        [self requestMovie];
    }
}


/**
 * 打开睡眠模式的点击事件
 */
- (void) openSleepClickAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        self.grayView.x = 0;
        [self.colorSwitch setOn:NO];
    }else {
        self.grayView.x = MAINSCREEN.size.width;
    }
    [self requestSetLamp];
}

/**
 *changeNameView的代理方法
 */
- (void)resetName:(NSString *)newName
{
    [self.nameText setText:newName];
}
@end
