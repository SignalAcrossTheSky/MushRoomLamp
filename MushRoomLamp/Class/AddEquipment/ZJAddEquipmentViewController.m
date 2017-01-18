//
//  ZJAddEquipmentViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 6/23/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJAddEquipmentViewController.h"
#import "Constant.h"
#import "ZJMainTabBarController.h"
#import "ZJAEInputWifiViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MBProgressHUD.h"
#import "MBProgressHUD+NJ.h"
#import "SYQRCodeViewController.h"
#import "ZJInterface.h"
#import <AVFoundation/AVFoundation.h>

@interface ZJAddEquipmentViewController ()<ZJInterfaceDelegate>
{
    /** 设备ID */
    NSString *deviceID;
    /** parentID */
    NSString *parentID;
}

/** 添加设备接口 */
@property(nonatomic,strong) ZJInterface *interfaceAddE;
@end

@implementation ZJAddEquipmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [UIApplication sharedApplication];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
}

/**
 * 添加设备网络请求
 */
- (void) requestAddEquiment
{
    [MBProgressHUD showMessage:@"处理中..."];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"deviceId"] = deviceID;
    
    param[@"parentId"] = parentID;
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];;
    
    self.interfaceAddE = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceAddE interfaceWithType:INTERFACE_TYPE_ADDEQUIPMENT param:param];

}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (interface == self.interfaceAddE) {
        
        if ([result[@"code"] isEqual:@(0)]) {
            [self createTipView:@"添加成功"];
        }else
        {
            [self createTipView:@"添加失败"];
        }
    }
}
 
/**
 * 初始化View
 */
- (void)initView
{
    [self createNavigationBar];
    
    [self createTitleView];
    
    [self createContentView];
}

/**
 * 创建导航栏
 */
- (void) createNavigationBar
{
    self.view.backgroundColor = DDRGBColor(237, 237, 237);
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
 //   [self.tabBarController.tabBar setHidden:YES];
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
    [closeBtn addTarget:self action:@selector(cancelClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:closeBtn];
    
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
    
    //生成二维码按钮
    UIButton *qrCodeBtn = [[UIButton alloc] init];
    qrCodeBtn.width = 40;
    qrCodeBtn.height = 40;
    qrCodeBtn.x = view.width - qrCodeBtn.width - 8;
    qrCodeBtn.y = 23;
    [qrCodeBtn setImage:[UIImage imageNamed:@"scan_qrcode"] forState:UIControlStateNormal];
    [qrCodeBtn addTarget:self action:@selector(scanQRCodeClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:qrCodeBtn];
}

/**
 * 创建内容View
 */
- (void)createContentView
{
    UIImageView *image_step1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_add_step1"]];
    image_step1.width = 214;
    image_step1.height = 127;
    image_step1.x = 20;
    image_step1.y = 90;
    [self.view addSubview:image_step1];
    
    UILabel *lab_step1 = [[UILabel alloc] init];
    lab_step1.x = self.view.width/3;
    lab_step1.y = image_step1.y;
    lab_step1.width = self.view.width * 2/3 - 20;
    lab_step1.height = 40;
    lab_step1.numberOfLines = 0;
    lab_step1.text = @"1.请先使用USB线将蘑菇灯与电源连接；";
    lab_step1.textAlignment = NSTextAlignmentLeft;
    lab_step1.font = [UIFont systemFontOfSize:15];
    lab_step1.textColor = DDRGBColor(133, 133, 133);
    [self.view addSubview:lab_step1];
    
    UIImageView *image_step2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_add_step2"]];
    image_step2.x = 20;
    image_step2.y = image_step1.bottom + 50;
    image_step2.width = 188;
    image_step2.height = 137;
    [self.view addSubview:image_step2];
    
    UILabel *lab_step2 = [[UILabel alloc] init];
    lab_step2.x = self.view.width/3;
    lab_step2.y = image_step1.bottom + 10;
    lab_step2.width = self.view.width * 2/3 - 20;
    lab_step2.height = 40;
    lab_step2.text = @"2.请使用针状尖锐物长戳reset口3秒；";
    lab_step2.textAlignment = NSTextAlignmentLeft;
    lab_step2.font = [UIFont systemFontOfSize:15];
    lab_step2.textColor = DDRGBColor(133, 133, 133);
    lab_step2.numberOfLines = 0;
    lab_step2.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:lab_step2];

    UILabel *lab_step3 = [[UILabel alloc] init];
    lab_step3.y = MAINSCREEN.size.height - 140;
    lab_step3.width = self.view.width;
    lab_step3.height = 15;
    lab_step3.x = 0;
    lab_step3.text = @"完成后请点击进行下一步";
    lab_step3.font = [UIFont systemFontOfSize:15];
    lab_step3.textAlignment = NSTextAlignmentCenter;
    lab_step3.textColor = DDRGBColor(133, 133, 133);
    [self.view addSubview:lab_step3];
    
    //底部下一步按钮
    UIButton *nextButton = [[UIButton alloc] init];
    nextButton.x = 50;
    nextButton.width = MAINSCREEN.size.width - nextButton.x * 2;
    nextButton.height = 40;
    nextButton.y = lab_step3.bottom + 20;
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:DDRGBColor(255, 255, 255) forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
    nextButton.layer.cornerRadius = 8;
    nextButton.backgroundColor = DDRGBColor(54, 57, 77);
    [nextButton addTarget:self action:@selector(nextClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];

    
//    //中间的图片
//    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"round"]];
//    image.width = 100;
//    image.height = 106;
//    image.x = (MAINSCREEN.size.width - image.width)/2;
//    image.y = 150;
//    [self.view addSubview:image];
//    
//    UIImageView *lightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_light"]];
//    lightImage.width = 36;
//    lightImage.height = 49;
//    lightImage.x = (image.width - lightImage.width)/2;
//    lightImage.y = 25;
//    [image addSubview:lightImage];
//    
//    //请确认设备
//    UILabel *title1 = [[UILabel alloc] init];
//    title1.x = 0;
//    title1.y = image.bottom + 20;
//    title1.width = MAINSCREEN.size.width;
//    title1.height = 17;
//    title1.text = @"请确认设备";
//    title1.font = [UIFont systemFontOfSize:17];
//    title1.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:title1];
//    
//    //按设备指示灯
//    UILabel *title2 = [[UILabel alloc] init];
//    title2.x = 0;
//    title2.y = title1.bottom + 5;
//    title2.width = MAINSCREEN.size.width;
//    title2.height = 17;
//    title2.text = @"(按设备指示灯)";
//    title2.font = [UIFont systemFontOfSize:17];
//    title2.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:title2];
//    
//    //请点击帮助
//    UILabel *title3 = [[UILabel alloc] init];
//    title3.x = 0;
//    title3.y = title2.bottom + 10;
//    title3.width = MAINSCREEN.size.width;
//    title3.height = 12;
//    title3.text = @"提示灯未亮起？请点击帮助";
//    title3.textColor = DDRGBColor(180, 180, 180);
//    title3.font = [UIFont systemFontOfSize:12];
//    title3.textAlignment = NSTextAlignmentCenter;
////    [self.view addSubview:title3];
//    
//    //底部下一步按钮
//    UIButton *nextButton = [[UIButton alloc] init];
//    nextButton.x = 20;
//    nextButton.width = MAINSCREEN.size.width - nextButton.x * 2;
//    nextButton.height = 50;
//    nextButton.y = MAINSCREEN.size.height - 120;
//    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_bg"] forState:UIControlStateNormal];
//    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
//    [nextButton setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
//    nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    nextButton.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
//    [nextButton addTarget:self action:@selector(nextClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:nextButton];
}

/**
 * 扫描按钮点击事件
 */
- (void) scanQRCodeClickAction:(UIButton *)sender
{
    sender.enabled = NO;
    //扫描二维码
    SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
    qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString){
        NSArray *list=[qrString componentsSeparatedByString:@"///////////////////"];
        parentID = [list firstObject];
        deviceID = [list lastObject];
        [self requestAddEquiment];
        NSInteger deviceId = [deviceID integerValue];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"SCANADDEQU" object:@(deviceId)];
    };
    qrcodevc.SYQRCodeFailBlock = ^(SYQRCodeViewController *aqrvc){
        [self createTipView:@"扫描失败"];
    };
    qrcodevc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrvc){
        [self cancelClickAction];

    };
    
    [self.navigationController pushViewController:qrcodevc animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

/**
 * 返回主页点击事件
 */
- (void)cancelClickAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 下一步按钮点击事件
 */
- (void)nextClickAction
{
    ZJAEInputWifiViewController *vc  = [[ZJAEInputWifiViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


/**
 * 创建提示框
 */
- (void)createTipView:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self cancelClickAction];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WEBSOCKET" object:@([deviceID integerValue])];
    }];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

@end
