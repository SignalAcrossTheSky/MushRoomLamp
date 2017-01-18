//
//  ZJSettingViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 6/23/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJSettingViewController.h"
#import "Constant.h"
#import "ZJAboutProductViewController.h"
#import "ZJQuestionViewController.h"
#import "ZJAboutUsViewController.h"
#import "AppDelegate.h"
#import "ZJInterface.h"
#import "ZJLoginViewController.h"
#import "MBProgressHUD+NJ.h"
#import "ZJLoginAndRegisterViewController.h"

@interface ZJSettingViewController ()<ZJInterfaceDelegate>

/** 退出登录的网络请求 */
@property (nonatomic,strong) ZJInterface *interfaceQuit;
@end

@implementation ZJSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}

/**
 * 退出登录的网络请求
 */
- (void)quitRequest
{
    [MBProgressHUD showMessage:@"退出处理中..."];
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);

    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceQuit = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceQuit interfaceWithType:INTERFACE_TYPE_QIUT param:param];
}

/**
 * 网络请求
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if ([result[@"code"] isEqual:@(0)]) {
//        ZJLoginViewController *login = [[ZJLoginViewController alloc] init];
//       
//        [self presentViewController:login animated:YES completion:^{
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault removeObjectForKey:@"token"];
        [userDefault removeObjectForKey:@"userid"];
        [userDefault synchronize];
      
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];  // 获得根窗口
//        ZJLoginViewController *loginVC = [[ZJLoginViewController alloc] init];//将登录控制器设置为window的根控制器
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        ZJLoginAndRegisterViewController *loginAndRegistVC = [[ZJLoginAndRegisterViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginAndRegistVC];
        window.rootViewController = nav;
        
//        }];
        }else{
        [MBProgressHUD showError:@"退出失败"];
    }
}

/**
 * 初始化View
 */
- (void)initView
{
    self.view.backgroundColor = DDRGBColor(237, 237, 237);
    
    [self setNavigationBar];
    
    [self createTitleView];
    
//    [self createUpdateView];
    
//    [self createBrightness];
    
    [self createAboutProductView];
    
    [self createQuestionView];
    
    [self createAboutUsView];
    
    [self createQuitView];
}

/**
 * 设置 navigationBar
 */
- (void)setNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    [view addSubview:closeBtn];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 37;
    titleLabel.width = MAINSCREEN.size.width;
    titleLabel.height = 17;
    titleLabel.text = @"设置";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
}

/**
 * 创建检测新版本View
 */
- (void)createUpdateView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 80;
    view.width = MAINSCREEN.size.width;
    view.height = 56;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    //图标
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"update"]];
    icon.x = 20;
    icon.y = 17;
    icon.width = 20;
    icon.height = 22;
    [view addSubview:icon];
    
    //检测新版本
    UILabel *updateLabel = [[UILabel alloc] init];
    updateLabel.x = icon.right + 15;
    updateLabel.y = 0;
    updateLabel.width = 100;
    updateLabel.height = view.height;
    updateLabel.text = @"检测新版本";
    updateLabel.font = [UIFont systemFontOfSize:16];
    [view addSubview:updateLabel];
    
    //当前版本
    UILabel *currentLabel = [[UILabel alloc] init];
    currentLabel.width = 100;
    currentLabel.height = view.height;
    currentLabel.x = view.width - currentLabel.width - 20;
    currentLabel.y = 0;
    currentLabel.textAlignment = NSTextAlignmentRight;
    currentLabel.text = @"当前版本1.0";
    currentLabel.textColor = DDRGBColor(180, 180, 180);
    currentLabel.font = [UIFont systemFontOfSize:12];
    [view addSubview:currentLabel];
 }

/**
 * 自动调节亮度
 */
- (void) createBrightness
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 137;
    view.width = MAINSCREEN.size.width;
    view.height = 56;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    //图标
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bright"]];
    icon.x = 20;
    icon.y = 17;
    icon.width = 20;
    icon.height = 22;
    [view addSubview:icon];
    
    //自动调节亮度
    UILabel *brightLabel = [[UILabel alloc] init];
    brightLabel.x = icon.right + 15;
    brightLabel.y = 5;
    brightLabel.width = 100;
    brightLabel.height = 28;
    brightLabel.text = @"自动调节亮度";
    brightLabel.font = [UIFont systemFontOfSize:16];
    [view addSubview:brightLabel];
    
    //Tip
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.x = icon.right + 15;
    tipLabel.y = brightLabel.bottom - 5;
    tipLabel.width = 150;
    tipLabel.height = 28;
    tipLabel.text = @"根据空气环境优化亮度";
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textColor = DDRGBColor(180, 180, 180);
    [view addSubview:tipLabel];
    
    //switch开关
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.width = 51;
    switchView.height = 30;
    switchView.x = MAINSCREEN.size.width - 20 -switchView.width;
    switchView.y = 13;
    [view addSubview:switchView];
    switchView.onTintColor = DDRGBColor(0, 244, 207);
}

/**
 * 创建关于产品
 */
- (void) createAboutProductView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 81;
    view.width = MAINSCREEN.size.width;
    view.height = 56;
    view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aboutProductClickAction)];
    [view addGestureRecognizer:tapGesture];
    [self.view addSubview:view];
    
    //图标
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"product"]];
    icon.x = 20;
    icon.y = 19;
    icon.width = 20;
    icon.height = 18;
    [view addSubview:icon];
    
    //关于产品
    UILabel *productLabel = [[UILabel alloc] init];
    productLabel.x = icon.right + 15;
    productLabel.y = 0;
    productLabel.width = 100;
    productLabel.height = view.height;
    productLabel.text = @"关于产品";
    productLabel.font = [UIFont systemFontOfSize:16];
    [view addSubview:productLabel];
    
    //右箭头
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_arrow_right"]];
    arrowImage.width = 6;
    arrowImage.height = 12;
    arrowImage.x = MAINSCREEN.size.width - arrowImage.width - 20;
    arrowImage.y = 22;
    [view addSubview:arrowImage];
}

/**
 * 创建问题反馈
 */
- (void) createQuestionView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 138;
    view.width = MAINSCREEN.size.width;
    view.height = 56;
    view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(questionClickAction)];
    [view addGestureRecognizer:tapGesture];
    [self.view addSubview:view];
    
    //图标
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"question"]];
    icon.x = 20;
    icon.y = 19;
    icon.width = 20;
    icon.height = 18;
    [view addSubview:icon];
    
    //问题反馈
    UILabel *productLabel = [[UILabel alloc] init];
    productLabel.x = icon.right + 15;
    productLabel.y = 0;
    productLabel.width = 100;
    productLabel.height = view.height;
    productLabel.text = @"问题反馈";
    productLabel.font = [UIFont systemFontOfSize:16];
    [view addSubview:productLabel];
    
    //右箭头
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_arrow_right"]];
    arrowImage.width = 6;
    arrowImage.height = 12;
    arrowImage.x = MAINSCREEN.size.width - arrowImage.width - 20;
    arrowImage.y = 22;
    [view addSubview:arrowImage];
}

/**
 * 创建关于我们
 */
- (void) createAboutUsView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 195;
    view.width = MAINSCREEN.size.width;
    view.height = 56;
    view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aboutUsClickAction)];
    [view addGestureRecognizer:tapGesture];
    [self.view addSubview:view];
    
    //图标
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aboutUs"]];
    icon.x = 20;
    icon.y = 19;
    icon.width = 20;
    icon.height = 18;
    [view addSubview:icon];
    
    //关于我们
    UILabel *productLabel = [[UILabel alloc] init];
    productLabel.x = icon.right + 15;
    productLabel.y = 0;
    productLabel.width = 100;
    productLabel.height = view.height;
    productLabel.text = @"关于我们";
    productLabel.font = [UIFont systemFontOfSize:16];
    [view addSubview:productLabel];
    
    //右箭头
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_arrow_right"]];
    arrowImage.width = 6;
    arrowImage.height = 12;
    arrowImage.x = MAINSCREEN.size.width - arrowImage.width - 20;
    arrowImage.y = 22;
    [view addSubview:arrowImage];
}

/**
 * 创建退出登录View
 */
- (void)createQuitView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 271;
    view.width = MAINSCREEN.size.width;
    view.height = 56;
    view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quitAppClickAction)];
    [view addGestureRecognizer:tapGesture];
    [self.view addSubview:view];
    
    //图标
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"quit"]];
    icon.x = 20;
    icon.y = 19;
    icon.width = 20;
    icon.height = 18;
    [view addSubview:icon];
    
    //退出登录
    UILabel *productLabel = [[UILabel alloc] init];
    productLabel.x = icon.right + 15;
    productLabel.y = 0;
    productLabel.width = 100;
    productLabel.height = view.height;
    productLabel.text = @"退出登录";
    productLabel.font = [UIFont systemFontOfSize:16];
    [view addSubview:productLabel];
}

/**
 *  退出按钮点击事件
 */
- (void)quitAppClickAction
{
    [self createTipView:@"确认退出？"];
    //    [self quitRequest];
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    [userDefault removeObjectForKey:@"token"];
//    [userDefault removeObjectForKey:@"userid"];
//    [userDefault synchronize];
//    
//    AppDelegate *app = [UIApplication sharedApplication].delegate;
//    UIWindow *window = app.window;
//     exit(0);
//    [UIView animateWithDuration:1.0f animations:^{
//        window.alpha = 0;
//        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
//    } completion:^(BOOL finished) {
//        exit(0);
//    }];
}

/**
 * 关于产品按钮点击事件
 */
- (void)aboutProductClickAction
{
    ZJAboutProductViewController *vc = [[ZJAboutProductViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 * 问题反馈按钮点击事件
 */
- (void)questionClickAction
{
    ZJQuestionViewController *vc = [[ZJQuestionViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 * 关于我们按钮点击事件
 */
- (void)aboutUsClickAction
{
    ZJAboutUsViewController *vc = [[ZJAboutUsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 * 返回按钮点击事件
 */
- (void)cancelClickAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 创建提示框
 */
- (void)createTipView:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self quitRequest];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
          
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:OKAction];

    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

@end
