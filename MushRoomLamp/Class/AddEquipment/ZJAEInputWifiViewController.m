//
//  ZJAEInputWifiViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 6/24/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJAEInputWifiViewController.h"
#import "Constant.h"
#import "ZJCommitViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MBProgressHUD.h"
#import "MBProgressHUD+NJ.h"

@interface ZJAEInputWifiViewController ()<UITextFieldDelegate>
/** 当前WiFi的Label */
@property (nonatomic,strong) UILabel *wifiLabel;
/** 密码TextField */
@property (nonatomic,strong) UITextField *pwdText;
/** 内容View */
@property (nonatomic,strong) UIView *contentView;
/** checkBox */
@property (nonatomic,strong) UIButton *checkBox;
@end

@implementation ZJAEInputWifiViewController

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
    
    [self setPageValue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setPageValue)
                                                 name:@"refreshAddEqu"
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"refreshAddEqu"
                                                  object:nil];
    [super viewDidDisappear:YES];
}

/**
 * 初始化View
 */
- (void)initView
{
    self.view.backgroundColor = DDRGBColor(237, 237, 237);
    
    [self createNavigationBar];
    
    [self createContentView];
    
    [self createTitleView];
    
    [self initPageValue];
    
}

/**
 * 初始化页面的值
 */
- (void)initPageValue
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *checkState = [userDefault objectForKey:@"IFCHECK"];
    if ([checkState isEqualToString:@"YES"]) {
        [self.checkBox setSelected:YES];
        NSDictionary * dic = [self fetchNetInfo];
        NSString *ssid = dic[@"SSID"];
        NSString *savedName = [userDefault objectForKey:@"WIFINAME"];
        if ([ssid isEqualToString:savedName]) {
            self.pwdText.text = [userDefault objectForKey:@"WIFIPWD"];
        }else{
            
        }
    }else{
        
        [self.checkBox setSelected:NO];
    }
}

/**
 * 创建导航栏
 */
- (void) createNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.tabBarController.tabBar setHidden:YES];
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
    titleLabel.text = @"添加设备";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
}


/**
 * 缩回键盘
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
}

/**
 * 创建内容View
 */
- (void)createContentView
{
    UILabel *currentWifiLab = [[UILabel alloc] init];
    currentWifiLab.y = 164;
    currentWifiLab.x = 0;
    currentWifiLab.width = self.view.width;
    currentWifiLab.height = 15;
    currentWifiLab.text = @"当前Wifi：";
    currentWifiLab.textAlignment = NSTextAlignmentCenter;
    currentWifiLab.font = [UIFont systemFontOfSize:15];
    currentWifiLab.textColor = DDRGBColor(102, 102, 102);
    [self.view addSubview:currentWifiLab];
    self.wifiLabel = currentWifiLab;
    
    UITextField *pwdText = [[UITextField alloc] init];
    pwdText.x = 50;
    pwdText.y = currentWifiLab.bottom + 20;
    pwdText.width = self.view.width - 100;
    pwdText.height = 44;
    pwdText.placeholder = @"请输入Wifi密码";
    pwdText.textAlignment = NSTextAlignmentLeft;
    pwdText.delegate = self;
    pwdText.layer.borderColor = DDRGBColor(133, 133, 133).CGColor;
    pwdText.layer.cornerRadius = 8;
    pwdText.layer.borderWidth = 1;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 44)];
    pwdText.leftViewMode = UITextFieldViewModeAlways;
    pwdText.leftView = leftView;
    
    UIButton *eyeBtn = [[UIButton alloc] init];
    eyeBtn.x = pwdText.width - 30;
    eyeBtn.y = 0;
    eyeBtn.width = 44;
    eyeBtn.height = 44;
    [eyeBtn setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
    [eyeBtn addTarget:self action:@selector(eyeClickAction) forControlEvents:UIControlEventTouchUpInside];
    pwdText.rightViewMode = UITextFieldViewModeAlways;
    pwdText.rightView = eyeBtn;
    [pwdText addSubview:eyeBtn];
    [self.view addSubview:pwdText];
    self.pwdText = pwdText;
    
    //记住密码的checkBox
    UIButton *checkBox = [[UIButton alloc] init];
    checkBox.x = 50;
    checkBox.y = pwdText.bottom;
    checkBox.width = 81;
    checkBox.height = 44;
    [checkBox setImage:[UIImage imageNamed:@"checkbox_noselect"] forState:UIControlStateNormal];
    [checkBox setImage:[UIImage imageNamed:@"checkbox_select"] forState:UIControlStateSelected];
    [checkBox addTarget:self action:@selector(checkRemberPwdClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [checkBox setTitle:@"记住密码" forState:UIControlStateNormal];
    [checkBox setTitleColor:DDRGBColor(133, 133, 133) forState:UIControlStateNormal];
    checkBox.titleLabel.font = [UIFont systemFontOfSize:12];
    checkBox.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [self.view addSubview:checkBox];
    self.checkBox = checkBox;
    
    //底部标签
    UIButton *bottomBtn = [[UIButton alloc] init];
    [bottomBtn setTitle:@"选择其他Wifi" forState:UIControlStateNormal];
    [bottomBtn setTitleColor:DDRGBColor(133, 133, 133) forState:UIControlStateNormal];
    bottomBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    bottomBtn.y = pwdText.bottom ;
    bottomBtn.width = 82;
    bottomBtn.height = 44;
    bottomBtn.x = pwdText.right - bottomBtn.width;
    bottomBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [bottomBtn addTarget:self action:@selector(chooseOtherWifiAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomBtn];
    
        //底部下一步按钮
    UIButton *nextButton = [[UIButton alloc] init];
    nextButton.x = 50;
    nextButton.width = MAINSCREEN.size.width - nextButton.x * 2;
    nextButton.height = 40;
    nextButton.y =  bottomBtn.bottom + 10 ;
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:DDRGBColor(255, 255, 255) forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
    nextButton.backgroundColor = DDRGBColor(54, 74, 77);
    nextButton.layer.cornerRadius = 8;
    [nextButton addTarget:self action:@selector(nextClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
//    //内容View
//    UIView *contentView = [[UIView alloc] init];
//    contentView.x = 0;
//    contentView.y = 93;
//    contentView.width = MAINSCREEN.size.width;
//    contentView.height = MAINSCREEN.size.height - 93;
//    contentView.backgroundColor = DDRGBColor(237, 237, 237);
//    [self.view addSubview:contentView];
//    self.contentView = contentView;
//    
//    //中间的图片
//    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"round"]];
//    image.width = 100;
//    image.height = 106;
//    image.x = (MAINSCREEN.size.width - image.width)/2;
//    image.y = 150 - 93;
//    [contentView addSubview:image];
//    
//    UIImageView *lightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifi"]];
//    lightImage.width = 52;
//    lightImage.height = 50;
//    lightImage.x = (image.width - lightImage.width)/2;
//    lightImage.y = 25;
//    [image addSubview:lightImage];
//    
//    //设置Wi－Fi连接
//    UILabel *wifiLabel = [[UILabel alloc] init];
//    wifiLabel.x = 0;
//    wifiLabel.y = image.bottom + 10;
//    wifiLabel.width = MAINSCREEN.size.width;
//    wifiLabel.height = 17;
//    wifiLabel.text = @"当前WIFI:";
//    wifiLabel.font = [UIFont systemFontOfSize:17];
//    wifiLabel.textAlignment = NSTextAlignmentCenter;
//    [contentView addSubview:wifiLabel];
//    self.wifiLabel = wifiLabel;
//    
//    //密码框图片
//    UIImageView *pwdImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pwd_tet"]];
//    pwdImage.x = 20;
//    pwdImage.height = 48;
//    pwdImage.width = MAINSCREEN.size.width - pwdImage.x * 2;
//    pwdImage.y = wifiLabel.bottom + 50;
//    [contentView addSubview:pwdImage];
//    
//    //密码输入框TextField
//    UITextField *pwdText = [[UITextField alloc] init];
//    pwdText.x = pwdImage.x + 5;
//    pwdText.y = pwdImage.y;
//    pwdText.width = pwdImage.width * 3/4;
//    pwdText.height = pwdImage.height;
//    pwdText.placeholder = @"请输入Wi－Fi密码";
//    pwdText.textAlignment = NSTextAlignmentCenter;
//    pwdText.delegate = self;
//    [contentView addSubview:pwdText];
//    self.pwdText = pwdText;
//    
//    //眼睛按钮
//    UIButton *eyeBtn = [[UIButton alloc] init];
//    eyeBtn.x = pwdText.right;
//    eyeBtn.y = pwdText.y;
//    eyeBtn.width = pwdImage.width/4;
//    eyeBtn.height = pwdImage.height;
//    [eyeBtn setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
//    [eyeBtn addTarget:self action:@selector(eyeClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [contentView addSubview:eyeBtn];
//    
//    //底部标签
//    UIButton *bottomBtn = [[UIButton alloc] init];
//    [bottomBtn setTitle:@"请选择其他Wi-Fi" forState:UIControlStateNormal];
//    [bottomBtn setTitleColor:DDRGBColor(180, 180, 180) forState:UIControlStateNormal];
//    bottomBtn.titleLabel.font = [UIFont systemFontOfSize:12];
////    [bottomBtn setImage:[UIImage imageNamed:@"green_arrow_down"] forState:UIControlStateNormal];
//    bottomBtn.y = pwdImage.bottom + 10;
//    bottomBtn.width = 100;
//    bottomBtn.height = 17;
//    bottomBtn.x = pwdImage.right - bottomBtn.width;
////    bottomBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0,-170);
////    bottomBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    [bottomBtn addTarget:self action:@selector(chooseOtherWifiAction) forControlEvents:UIControlEventTouchUpInside];
//    [contentView addSubview:bottomBtn];
//    
//    //记住密码的checkBox
//    UIButton *checkBox = [[UIButton alloc] init];
//    checkBox.x = pwdImage.left;
//    checkBox.y = pwdImage.bottom + 10;
//    checkBox.width = 15;
//    checkBox.height = 15;
//    [checkBox setImage:[UIImage imageNamed:@"checkbox_noselect"] forState:UIControlStateNormal];
//    [checkBox setImage:[UIImage imageNamed:@"checkbox_select"] forState:UIControlStateSelected];
//    [checkBox addTarget:self action:@selector(checkRemberPwdClickAction:) forControlEvents:UIControlEventTouchUpInside];
//    [contentView addSubview:checkBox];
//    self.checkBox = checkBox;
//    
//    //记住密码Label
//    UILabel *remPwd = [[UILabel alloc] init];
//    remPwd.x = checkBox.right + 5;
//    remPwd.y = checkBox.y;
//    remPwd.width = 80;
//    remPwd.height = 17;
//    remPwd.text = @"记住密码";
//    remPwd.font = [UIFont systemFontOfSize:12];
//    [contentView addSubview:remPwd];
//    
//    //底部下一步按钮
//    UIButton *nextButton = [[UIButton alloc] init];
//    nextButton.x = 20;
//    nextButton.width = MAINSCREEN.size.width - nextButton.x * 2;
//    nextButton.height = 50;
//    nextButton.y =  contentView.height - 60 ;
//    [nextButton setBackgroundImage:[UIImage imageNamed:@"btn_bg"] forState:UIControlStateNormal];
//    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
//    [nextButton setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
//    nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    nextButton.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
//    [nextButton addTarget:self action:@selector(nextClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [contentView addSubview:nextButton];
}

/**
 * 设置页面值
 */
- (void) setPageValue
{
    NSDictionary * dic = [self fetchNetInfo];
    NSString *ssid = dic[@"SSID"];
    if (ssid == nil) {
        self.wifiLabel.text = [NSString stringWithFormat:@"未连接WiFi"];
    }else{
        self.wifiLabel.text = [NSString stringWithFormat:@"当前Wifi:%@",dic[@"SSID"]];
    }
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
    NSDictionary * dic = [self fetchNetInfo];
    
    if (![self checkNextBtnEnable]) {
        return ;
    }
    if ([self.checkBox isSelected]) {
     
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:dic[@"SSID"] forKey:@"WIFINAME"];
        [userDefault setObject:self.pwdText.text forKey:@"WIFIPWD"];
        [userDefault setObject:@"YES" forKey:@"IFCHECK"];
        [userDefault synchronize];
    }else{
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:@"NO" forKey:@"IFCHECK"];
        [userDefault synchronize];
    }
    
    ZJCommitViewController *vc = [[ZJCommitViewController alloc] init];
    vc.ssid = dic[@"SSID"];
    vc.bssid = dic[@"BSSID"];
    vc.pwd = self.pwdText.text;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 * 判断下一步按钮是否可以点击
 */
- (BOOL) checkNextBtnEnable
{
    NSDictionary * dic = [self fetchNetInfo];
    if (dic == nil) {
        [MBProgressHUD showError:@"未连接WiFi"];
        return NO;
    }else if ([self.pwdText.text isEqualToString:@""]){
        [MBProgressHUD showError:@"密码为空"];
      return NO;
    }
    return YES;
}

/**
 * 创建提示框
 */
- (void)createTipView:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

/**
 * 获取当前wifi名称
 */
- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
  
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

/**
 *  键盘显示事件
 */
- (void) keyboardWillShow:(NSNotification *)notification {
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
    CGFloat offset = (self.view.frame.origin.y+self.view.frame.size.height) - (self.view.frame.size.height - kbHeight);
    
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //将视图上移计算好的偏移
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.contentView.y = -100;
        }];
    }
}

/**
 *  键盘消失事件
 */
- (void) keyboardWillHide:(NSNotification *)notify {
    // 键盘动画时间
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        self.contentView.y = 93;
    }];
}

/**
 * 眼睛按钮点击事件
 */
- (void) eyeClickAction
{
    if (self.pwdText.secureTextEntry) {
        self.pwdText.secureTextEntry = NO;
    }else
    {
        self.pwdText.secureTextEntry = YES;
    }
    NSString* text = self.pwdText.text;
    self.pwdText.text = @" ";
    self.pwdText.text = text;
}

/**
 * 记住密码按钮点击事件
 */
- (void) checkRemberPwdClickAction:(UIButton *) sender
{
    if ([sender isSelected]) {
        [sender setSelected:NO];
    }else{
        [sender setSelected:YES];
    }
}

/**
 * 选择其他Wifi
 */
- (void) chooseOtherWifiAction
{
    float iosversion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (iosversion < 10) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

/**
 *  限制输入长度
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.pwdText) {
        if (textField.text.length > 16) return NO;
    }
    return YES;
}
@end
