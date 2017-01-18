//
//  ZJCommitViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 6/27/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJCommitViewController.h"
#import "Constant.h"
#import "ESPTouchResult.h"
#import "ESPTouchTask.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ZJInterface.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+NJ.h"
#import "BDUMD5Crypt.h"

#import <SystemConfiguration/CaptiveNetwork.h>

@interface EspTouchDelegateImpl : NSObject<ESPTouchDelegate>


@end

@implementation EspTouchDelegateImpl

-(void) dismissAlert:(UIAlertView *)alertView
{
    [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
}

-(void) showAlertWithResult: (ESPTouchResult *) result
{
    NSString *title = nil;
    NSString *message = [NSString stringWithFormat:@"%@ is connected to the wifi" , result.bssid];
    NSTimeInterval dismissSeconds = 3.5;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView show];
    [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:dismissSeconds];
}

-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithResult:result];
    });
}

@end


@interface ZJCommitViewController ()<ZJInterfaceDelegate,CAAnimationDelegate>
/** 百分比 */
@property (nonatomic,strong) UILabel *perLabel;
/** 设备连接完成 */
@property (nonatomic,strong) UILabel *stateLabel;
/** 设备尽量靠近 */
@property (nonatomic,strong) UILabel *tipLabel;
// without the condition, if the user tap confirm/cancel quickly enough,
// the bug will arise. the reason is follows:
// 0. task is starting created, but not finished
// 1. the task is cancel for the task hasn't been created, it do nothing
// 2. task is created
// 3. Oops, the task should be cancelled, but it is running
@property (nonatomic, strong) NSCondition *_condition;

@property (atomic, strong) ESPTouchTask *_esptouchTask;

@property (nonatomic, strong) EspTouchDelegateImpl *_esptouchDelegate;
/** 设备ID */
@property (nonatomic,copy) NSString *deviceID;
/** 添加新设备的网络接口 */
@property (nonatomic,strong) ZJInterface *interfaceAddQue;
/** 第一个圆的Layer */
@property (nonatomic,strong) CALayer *first_layer;
/** 第二个圆的Layer */
@property (nonatomic,strong) CALayer *second_layer;
/** 第三个圆的Layer */
@property (nonatomic,strong) CALayer *third_layer;
@end

@implementation ZJCommitViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self sendSecurityCodeButtonClickAction:self.perLabel withFirstTitle:@"0%" withSecondTitle:@""];
    
    [super viewWillAppear:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

/**
 * 添加新设备网络请求
 */
- (void) requestAddNewEquipment
{
    [MBProgressHUD showMessage:@""];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"deviceCode"] = [self.deviceID substringFromIndex:(self.deviceID.length - 6)];
    
    param[@"terminalId"] = @(1);
    
    param[@"parentId"] = @(0);
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceAddQue = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceAddQue interfaceWithType:INTERFACE_TYPE_ADDEQUIPMENT param:param];
}

/**
 * 网络请求的返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (interface == self.interfaceAddQue) {
        if ([result[@"code"] isEqual:@(0)]) {
            [self createTipView:@"设备添加成功"];
             NSInteger deviceID = [result[@"data"][@"deviceId"] integerValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WEBSOCKET" object:@(deviceID)];
        }else
        {
            [self createTipView:@"设备添加失败，请重置后再次添加"];
        }
    }
}

/**
 * 加密方法
 */
- (NSString *) addLockFunction:(NSDictionary *)dic
{
    NSString *sign = @"";
    NSArray *keys = [dic allKeys];
    
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];

    for (NSString *categoryId in sortedArray) {
      
        sign = [sign stringByAppendingString:categoryId];
        sign = [sign stringByAppendingString:[dic objectForKey:categoryId]];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [BDUMD5Crypt HMACMD5WithString:sign WithKey:[userDefault objectForKey:@"token"]];
}

/**
 * 初始化View
 */
- (void)initView
{
    self.view.backgroundColor = DDRGBColor(237, 237, 237);
    [self createTitleView];
    [self createContentView];
    
    [self tapConfirmForResult];
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
    titleLabel.text = @"添加设备";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
}

/**
 * 创建内容View
 */
- (void)createContentView
{
    [self createRippleAnimation1];
    [self createRippleAnimation2];
    [self createRippleAnimation3];
    
    //请确认设备
    UILabel *title1 = [[UILabel alloc] init];
    title1.x = 0;
    title1.y = self.view.height/2 + 90;
    title1.width = MAINSCREEN.size.width;
    title1.height = 17;
    title1.text = @"搜索设备并连接中...";
    title1.font = [UIFont systemFontOfSize:15];
    title1.textColor = DDRGBColor(102, 102, 102);
    title1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title1];
    self.stateLabel = title1;
    
    //按设备指示灯
    UILabel *title2 = [[UILabel alloc] init];
    title2.x = 0;
    title2.y = title1.bottom + 10;
    title2.width = MAINSCREEN.size.width;
    title2.height = 17;
    title2.text = @"路由器／手机／设备尽量靠近";
    title2.textColor = DDRGBColor(153, 153, 153);
    title2.font = [UIFont systemFontOfSize:15];
    title2.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title2];
    self.tipLabel = title2;

    //底部完成按钮
    UIButton *nextButton = [[UIButton alloc] init];
    nextButton.x = 50;
    nextButton.width = MAINSCREEN.size.width - nextButton.x * 2;
    nextButton.height = 40;
    nextButton.y = title2.bottom + 40;
    [nextButton setTitle:@"完成" forState:UIControlStateNormal];
    nextButton.layer.cornerRadius = 8;
    nextButton.backgroundColor = DDRGBColor(54, 74, 77);
    [nextButton setTitleColor:DDRGBColor(255, 255, 255) forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
    nextButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [nextButton addTarget:self action:@selector(nextClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];

    
//    [self createRippleAnimationWithTime:1.0];
    //中间的图片
//    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"round"]];
//    image.width = 100;
//    image.height = 106;
//    image.x = (MAINSCREEN.size.width - image.width)/2;
//    image.y = 250;
//    [self.view addSubview:image];
//    
//    UILabel *progressLabel = [[UILabel alloc] init];
//    progressLabel.width = image.width;
//    progressLabel.height = 49;
//    progressLabel.x = (image.width - progressLabel.width)/2;
//    progressLabel.y = 25;
//    progressLabel.text = @"0%";
//    progressLabel.textColor = DDRGBColor(0, 244, 207);
//    progressLabel.font = [UIFont systemFontOfSize:22];
//    progressLabel.textAlignment = NSTextAlignmentCenter;
//    [image addSubview:progressLabel];
//    self.perLabel = progressLabel;
    
//    //请确认设备
//    UILabel *title1 = [[UILabel alloc] init];
//    title1.x = 0;
//    title1.y = image.bottom + 10;
//    title1.width = MAINSCREEN.size.width;
//    title1.height = 17;
//    title1.text = @"搜索设备并连接中...";
//    title1.font = [UIFont systemFontOfSize:17];
//    title1.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:title1];
//    self.stateLabel = title1;
//    
//    //按设备指示灯
//    UILabel *title2 = [[UILabel alloc] init];
//    title2.x = 0;
//    title2.y = title1.bottom + 5;
//    title2.width = MAINSCREEN.size.width;
//    title2.height = 17;
//    title2.text = @"路由器／手机／设备尽量靠近";
//    title2.textColor = DDRGBColor(180, 180, 180);
//    title2.font = [UIFont systemFontOfSize:17];
//    title2.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:title2];
//    
//    //底部完成按钮
//    UIButton *nextButton = [[UIButton alloc] init];
//    nextButton.x = 20;
//    nextButton.width = MAINSCREEN.size.width - nextButton.x * 2;
//    nextButton.height = 50;
//    nextButton.y = MAINSCREEN.size.height - 60;
//    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_bg"] forState:UIControlStateNormal];
//    [nextButton setTitle:@"完成" forState:UIControlStateNormal];
//    [nextButton setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
//    nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    nextButton.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
//    [nextButton addTarget:self action:@selector(nextClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:nextButton];
}

/**
 * layer层创建波纹扩散动画
 */
- (void)createRippleAnimation1
{
    CALayer *spreadLayer = [CALayer layer];
    spreadLayer.bounds = CGRectMake(0, 0, 120, 120);
    spreadLayer.backgroundColor = DDRGBAColor(0, 160, 240, 0.4).CGColor;
    spreadLayer.cornerRadius = 60;
    spreadLayer.position = CGPointMake(self.view.width/2, self.view.height/2);
    self.first_layer = spreadLayer;
    
    //设定剧本
    CABasicAnimation *scaleAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation1.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation1.toValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation1.fillMode = kCAFillModeForwards;
    scaleAnimation1.repeatCount = MAXFLOAT;
    scaleAnimation1.duration = 1 ;
    scaleAnimation1.beginTime= 0 ;
    scaleAnimation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *scaleAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation2.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation2.toValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation2.fillMode = kCAFillModeForwards;
    scaleAnimation2.repeatCount = MAXFLOAT;
    scaleAnimation2.beginTime = 1 ;
    scaleAnimation2.duration = 1 ;
    
    CABasicAnimation *scaleAnimation3 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation3.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation3.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation3.fillMode = kCAFillModeForwards;
    scaleAnimation3.repeatCount = MAXFLOAT;
    scaleAnimation3.duration = 1  ;
    scaleAnimation3.beginTime= 2  ;
    scaleAnimation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.duration = 3 ;
    animationGroup.animations = @[scaleAnimation1,scaleAnimation2,scaleAnimation3];
    [spreadLayer addAnimation:animationGroup forKey:nil];
    [self.view.layer addSublayer:spreadLayer];
}

/**
 *
 */
- (void)createRippleAnimation2
{
    CALayer *spreadLayer = [CALayer layer];
    spreadLayer.bounds = CGRectMake(0, 0, 120, 120);
    spreadLayer.backgroundColor = DDRGBAColor(0, 160, 240, 0.4).CGColor;
    spreadLayer.cornerRadius = 60;
    spreadLayer.position = CGPointMake(self.view.width/2, self.view.height/2);
    self.second_layer = spreadLayer;
    
    //设定剧本
    CABasicAnimation *scaleAnimation0 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation0.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation0.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation0.fillMode = kCAFillModeForwards;
    scaleAnimation0.repeatCount = MAXFLOAT;
    scaleAnimation0.beginTime = 0;
    scaleAnimation0.duration =  0.4;

    CABasicAnimation *scaleAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation1.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation1.toValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation1.fillMode = kCAFillModeForwards;
    scaleAnimation1.repeatCount = MAXFLOAT;
    scaleAnimation1.duration = 0.8 ;
    scaleAnimation1.beginTime= 0.4 ;
    scaleAnimation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *scaleAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation2.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation2.toValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation2.fillMode = kCAFillModeForwards;
    scaleAnimation2.repeatCount = MAXFLOAT;
    scaleAnimation2.beginTime = 1.2;
    scaleAnimation2.duration =  0.6;
    
    CABasicAnimation *scaleAnimation3 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation3.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation3.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation3.fillMode = kCAFillModeForwards;
    scaleAnimation3.repeatCount = MAXFLOAT;
    scaleAnimation3.duration = 0.8 ;
    scaleAnimation3.beginTime= 1.8 ;
    scaleAnimation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *scaleAnimation4 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation4.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation4.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation4.fillMode = kCAFillModeForwards;
    scaleAnimation4.repeatCount = MAXFLOAT;
    scaleAnimation4.beginTime = 2.6;
    scaleAnimation4.duration = 0.4 ;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.duration = 3 ;
    animationGroup.animations = @[scaleAnimation0,scaleAnimation1,scaleAnimation2,scaleAnimation3,scaleAnimation4];
    animationGroup.delegate = self;
    [spreadLayer addAnimation:animationGroup forKey:nil];
   
    [self.view.layer addSublayer:spreadLayer];
}

/**
 *
 */
- (void)createRippleAnimation3
{
    CALayer *spreadLayer = [CALayer layer];
    spreadLayer.bounds = CGRectMake(0, 0, 120, 120);
    spreadLayer.backgroundColor = DDRGBAColor(0, 160, 240, 0.4).CGColor;
    spreadLayer.cornerRadius = 60;
    spreadLayer.position = CGPointMake(self.view.width/2, self.view.height/2);
    self.third_layer = spreadLayer;
    
    //设定剧本
    CABasicAnimation *scaleAnimation0 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation0.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation0.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation0.fillMode = kCAFillModeForwards;
    scaleAnimation0.repeatCount = MAXFLOAT;
    scaleAnimation0.beginTime = 0;
    scaleAnimation0.duration =  0.8;
    
    CABasicAnimation *scaleAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation1.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation1.toValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation1.fillMode = kCAFillModeForwards;
    scaleAnimation1.repeatCount = MAXFLOAT;
    scaleAnimation1.duration = 0.7 ;
    scaleAnimation1.beginTime= 0.8 ;
    scaleAnimation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *scaleAnimation3 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation3.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation3.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation3.fillMode = kCAFillModeForwards;
    scaleAnimation3.repeatCount = MAXFLOAT;
    scaleAnimation3.duration = 0.7 ;
    scaleAnimation3.beginTime= 1.5 ;
    scaleAnimation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *scaleAnimation4 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation4.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation4.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation4.fillMode = kCAFillModeForwards;
    scaleAnimation4.repeatCount = MAXFLOAT;
    scaleAnimation4.beginTime = 2.2 ;
    scaleAnimation4.duration = 0.8;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.duration = 3 ;
    animationGroup.animations = @[scaleAnimation0,scaleAnimation1,scaleAnimation3,scaleAnimation4];
    animationGroup.delegate = self;
    [spreadLayer addAnimation:animationGroup forKey:nil];
    [self.view.layer addSublayer:spreadLayer];
}

/**
 * 成功动画
 */
- (void) createSuccessAnimation
{
    CALayer *spreadLayer = [CALayer layer];
    spreadLayer.bounds = CGRectMake(0, 0, 120, 120);
    spreadLayer.cornerRadius = 60;
    spreadLayer.position = CGPointMake(self.view.width/2, self.view.height/2);
    spreadLayer.contents = (__bridge id)([UIImage imageNamed:@"OK"].CGImage);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 0.6;
    animation.beginTime = 0.0;
    animation.repeatCount = 1;
    [spreadLayer addAnimation:animation forKey:@"success"];
    [self.view.layer addSublayer:spreadLayer];
}

/**
 * 刷新百分比Label
 */
- (void) sendSecurityCodeButtonClickAction:(UILabel *)sender
                            withFirstTitle:(NSString *)originalString
                           withSecondTitle:(NSString *)changedString
{
    UILabel * _l_timeButton = (UILabel *)sender;
    
    __block int timeout= 1000; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),0.1*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        if([_l_timeButton.text isEqualToString:@"100%"])
        {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                _l_timeButton.text = @"100%";
                
            });

        }else
        {
            if(timeout <= 932){ //倒计时结束，关闭
                dispatch_source_cancel(_timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    _l_timeButton.text = @"67%";
                    
                });
            }else if (timeout <= 0)
            {
//                [self createTipView:@"未检测到设备，请重置设备，再次连接"];
            }else{
                
                NSString *strTime = [NSString stringWithFormat:@"%.2d", 1000-timeout];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:1];
                    _l_timeButton.text = [NSString stringWithFormat:@"%@%@",strTime,@"%"];
                    [UIView commitAnimations];
                    _l_timeButton.userInteractionEnabled = NO;
                });
                timeout--;
            }
        }
        });
    dispatch_resume(_timer);
}

/**
 *  广播出去
 */
- (void) tapConfirmForResult
{
    // do confirm
    NSLog(@"ESPViewController do confirm action...");
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
    NSLog(@"ESPViewController do the execute work...");
    // execute the task
    ESPTouchResult *esptouchResult = [self executeForResult];
    // show the result to the user in UI Main Thread
    dispatch_async(dispatch_get_main_queue(), ^{
    // when canceled by user, don't show the alert view again
    if (!esptouchResult.isCancelled)
    {
        if (esptouchResult.bssid == nil) {
            [self createTipView:@"未检测到设备，请重置设备，再次连接"];
        }else
        {
            [self.first_layer removeFromSuperlayer];
            [self.second_layer removeFromSuperlayer];
            [self.third_layer removeFromSuperlayer];
            [self createSuccessAnimation];
            self.deviceID = esptouchResult.bssid;
            self.tipLabel.text = @"";
            self.stateLabel.text = @"设备连接完成";
        }
    }
    });
    });
}

- (ESPTouchResult *) executeForResult
{
    [self._condition lock];
    NSString *apSsid = self.ssid;
    NSString *apPwd = self.pwd;
    NSString *apBssid = self.bssid;
    BOOL isSsidHidden = NO;
    self._esptouchTask =
    [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd andIsSsidHiden:isSsidHidden];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self._condition unlock];
    ESPTouchResult * esptouchResult = [self._esptouchTask executeForResult];
    NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResult);
    return esptouchResult;
}

//ESPTouchTask __listenAsyn() receive rubbish message, just ignore
/**
 * 创建提示框
 */
- (void)createTipView:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//         [[NSNotificationCenter defaultCenter] postNotificationName:@"SCANADDEQU" object:@(deviceId)];
        if ([message isEqualToString:@"设备添加成功"]) {
            [self.tabBarController setSelectedIndex:0];
        }else{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}
//ESPTouchTask __execute() send gc code
/**
 * 返回主页点击事件
 */
- (void)cancelClickAction:(UIButton *)sender
{
    sender.enabled = NO;
    [self._condition lock];
    if (self._esptouchTask != nil)
    {
        [self._esptouchTask interrupt];
    }
    [self._condition unlock];
    [self.navigationController popViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

/**
 * 下一步按钮点击事件
 */
- (void)nextClickAction
{
    if (self.deviceID == nil) {
        [MBProgressHUD showError:@"未完成搜索"];
    }else
    {
        [self requestAddNewEquipment];
    }
}


@end
