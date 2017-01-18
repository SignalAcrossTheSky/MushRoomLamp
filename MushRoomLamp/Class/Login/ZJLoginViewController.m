//
//  ZJLoginViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 7/1/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJLoginViewController.h"
#import "Constant.h"
#import "ZJRegisterViewController.h"
#import "ZJInterface.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+NJ.h"
#import "ZJMainTabBarController.h"
#import "ZJForgetPwdViewController.h"
#import "JPUSHService.h"

@interface ZJLoginViewController ()<ZJInterfaceDelegate,UITextFieldDelegate>
/** 登录接口 */
@property (nonatomic,strong) ZJInterface *interfaceLogin;
/** 电话号码Text */
@property (nonatomic,strong) UITextField *phoneText;
/** 密码Text */
@property (nonatomic,strong) UITextField *pwdText;
/** 内容View */
@property (nonatomic,strong) UIView *contentView;
@end

@implementation ZJLoginViewController

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
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
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
    [super viewDidDisappear:YES];
}


/**
 * 登录网络请求
 */
- (void) requestLogin
{
    [MBProgressHUD showMessage:@""];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    param[@"loginName"] = self.phoneText.text;
    
    param[@"loginPass"] = self.pwdText.text;
 
    param[@"terminalId"] = @(1);
    
    self.interfaceLogin = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceLogin interfaceWithType:INTERFACE_TYPE_LOGIN param:param];
}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (interface == self.interfaceLogin) {
        if ([result[@"code"] isEqual:@(0)]) {
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:result[@"data"][@"token"] forKey:@"token"];
            [userDefault setObject:result[@"data"][@"id"] forKey:@"userid"];
            [userDefault setObject:self.phoneText.text forKey:@"account"];
            [userDefault synchronize];
            [JPUSHService setAlias:[NSString stringWithFormat:@"me_%@",result[@"data"][@"id"]] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:nil];
            ZJMainTabBarController *vc = [[ZJMainTabBarController alloc] init];
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            window.rootViewController = vc;
        }else if ([result[@"code"] isEqual:@(12004)])
        {
            [self createTipView:@"用户不存在"];
        }else if ([result[@"code"] isEqual:@(12006)])
        {
            [self createTipView:@"账号或密码错误"];
        }else
        {
            [self createTipView:@"登录失败"];
        }
        
    }
}

/**
 * 初始化View
 */
- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self createLoginView];
    [self createTitleView];
}

/**
 * 创建登陆View
 */
- (void) createLoginView
{
    
    UIView *view = [[UIView alloc] init];
    view.x = 15;
    view.y = 94;
    view.width = MAINSCREEN.size.width - 30;
    view.height = 88;
    view.layer.borderColor = DDRGBColor(153, 153, 153).CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 8;
    [self.view addSubview:view];
    
    UILabel *sLine = [[UILabel alloc] init];
    sLine.x = 0;
    sLine.y = view.height/2;
    sLine.width = view.width;
    sLine.height = 0.5;
    sLine.backgroundColor = DDRGBColor(153, 153, 153);
    [view addSubview:sLine];
    
    UILabel *phoneLabel = [[UILabel alloc] init];
    phoneLabel.width = 55;
    phoneLabel.height = view.height/2;
    phoneLabel.x = 0;
    phoneLabel.y = 0 ;
    phoneLabel.text = @"+86";
    phoneLabel.font = [UIFont systemFontOfSize:16];
    phoneLabel.textColor = DDRGBColor(102, 102, 102);
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:phoneLabel];
    
    UITextField *phoneText = [[UITextField alloc] init];
    phoneText.x = phoneLabel.right ;
    phoneText.y = 0;
    phoneText.width = view.width - phoneText.x;
    phoneText.height = view.height/2;
    phoneText.placeholder = @"请填写手机号码";
    phoneText.font = [UIFont systemFontOfSize:16];
    phoneText.delegate = self;
    phoneText.keyboardType = UIKeyboardTypeNumberPad;
    [view addSubview:phoneText];
    self.phoneText = phoneText;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"account"] != nil) {
        phoneText.text = [userDefault objectForKey:@"account"];
    }

    UITextField *pwdText = [[UITextField alloc] init];
    pwdText.x = 15;
    pwdText.y = sLine.bottom;
    pwdText.width = 150;
    pwdText.height = view.height/2;
    pwdText.placeholder = @"请填写密码";
    pwdText.font = [UIFont systemFontOfSize:16];
    [view addSubview:pwdText];
    pwdText.keyboardType = UIKeyboardTypeASCIICapable;
    pwdText.delegate = self;
    pwdText.secureTextEntry = YES;
    self.pwdText = pwdText;
    
    UIButton *forgetPwd = [[UIButton alloc] init];
    forgetPwd.width = 80;
    forgetPwd.height = view.height/2;
    forgetPwd.x = view.width - 5 - forgetPwd.width;
    forgetPwd.y = self.pwdText.y;
    [forgetPwd setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [forgetPwd setTitleColor:DDRGBColor(153, 153, 153) forState:UIControlStateNormal];
    forgetPwd.titleLabel.font = [UIFont systemFontOfSize:14];
    [forgetPwd addTarget:self action:@selector(forgetPwdClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:forgetPwd];

    UIButton *loginBtn = [[UIButton alloc] init];
    loginBtn.x = 15;
    loginBtn.y = view.bottom + 30;
    loginBtn.width = MAINSCREEN.size.width - 30;
    loginBtn.height = 44;
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [loginBtn setTitleColor:DDRGBColor(255, 255, 255) forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:DDRGBColor(54, 57, 76)];
    loginBtn.layer.cornerRadius = 8;
    [loginBtn addTarget:self action:@selector(loginClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
//    UIView *view = [[UIView alloc] init];
//    view.x = 0;
//    view.y = 80;
//    view.width = MAINSCREEN.size.width;
//    view.height = MAINSCREEN.size.height - 80;
//    [self.view addSubview:view];
//    self.contentView = view;
    
//    //手机登录图片
//    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo"]];
//    logo.width = 101;
//    logo.height = 106;
//    logo.x = (MAINSCREEN.size.width - logo.width)/2;
//    logo.y = 62;
//    [view addSubview:logo];
//    
//    //手机登录Label
//    UILabel *label = [[UILabel alloc] init];
//    label.x = 0;
//    label.y = logo.bottom + 10;
//    label.width = MAINSCREEN.size.width;
//    label.height = 16;
//    label.text = @"手机登录";
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont systemFontOfSize:16];
//    [view addSubview:label];
//    
//    //创建三条Line
//    for (int i = 0;i<3; i++) {
//        UILabel *line = [[UILabel alloc] init];
//        line.x = 20;
//        line.y = 260 + 45 * i;
//        line.width = MAINSCREEN.size.width - 40;
//        line.height = 1;
//        line.backgroundColor = DDRGBColor(233, 233, 233);
//        [view addSubview:line];
//    }
//    
//    //手机输入框
//    UILabel *phoneLabel = [[UILabel alloc] init];
//    phoneLabel.width = 55;
//    phoneLabel.height = 45;
//    phoneLabel.x = 20;
//    phoneLabel.y = 260 ;
//    phoneLabel.text = @"+86";
//    phoneLabel.font = [UIFont systemFontOfSize:16];
//    phoneLabel.textAlignment = NSTextAlignmentCenter;
//    [view addSubview:phoneLabel];
//    
//    UITextField *phoneText = [[UITextField alloc] init];
//    phoneText.x = phoneLabel.right + 30;
//    phoneText.y = 260;
//    phoneText.width = 150;
//    phoneText.height = 45;
//    phoneText.placeholder = @"请填写手机号码";
//    phoneText.font = [UIFont systemFontOfSize:16];
//    phoneText.delegate = self;
//    phoneText.keyboardType = UIKeyboardTypeNumberPad;
//    [view addSubview:phoneText];
//    self.phoneText = phoneText;
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    if ([userDefault objectForKey:@"account"] != nil) {
//        phoneText.text = [userDefault objectForKey:@"account"];
//    }
//    
//    //竖立的灰色线条
//    UILabel *vLine = [[UILabel alloc] init];
//    vLine.x = phoneLabel.right + 10;
//    vLine.y = phoneLabel.y;
//    vLine.width = 1;
//    vLine.height = 45;
//    vLine.backgroundColor = DDRGBColor(233, 233, 233);
//    [view addSubview:vLine];
//    
//    //填写密码输入框
//    UILabel *pwdLabel = [[UILabel alloc] init];
//    pwdLabel.width = 55;
//    pwdLabel.height = 45;
//    pwdLabel.x = 20;
//    pwdLabel.y = 305 ;
//    pwdLabel.text = @"密码";
//    pwdLabel.font = [UIFont systemFontOfSize:16];
//    pwdLabel.textAlignment = NSTextAlignmentCenter;
//    [view addSubview:pwdLabel];
//    
//    UITextField *pwdText = [[UITextField alloc] init];
//    pwdText.x = pwdLabel.right + 30;
//    pwdText.y = 305;
//    pwdText.width = 150;
//    pwdText.height = 45;
//    pwdText.placeholder = @"请填写密码";
//    pwdText.font = [UIFont systemFontOfSize:16];
//    [view addSubview:pwdText];
//    pwdText.keyboardType = UIKeyboardTypeASCIICapable;
//    pwdText.delegate = self;
//    pwdText.secureTextEntry = YES;
//    self.pwdText = pwdText;
//    
//    UIButton *forgetPwd = [[UIButton alloc] init];
//    forgetPwd.width = 80;
//    forgetPwd.height = 22;
//    forgetPwd.x = MAINSCREEN.size.width - 20 - forgetPwd.width;
//    forgetPwd.y = self.pwdText.bottom;
//    [forgetPwd setTitle:@"忘记密码?" forState:UIControlStateNormal];
//    [forgetPwd setTitleColor:DDRGBColor(153, 153, 153) forState:UIControlStateNormal];
//    forgetPwd.titleLabel.font = [UIFont systemFontOfSize:14];
//    [forgetPwd addTarget:self action:@selector(forgetPwdClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:forgetPwd];
//    
//    //底部Button
//    UIButton *loginBtn = [[UIButton alloc] init];
//    loginBtn.x = 20;
//    loginBtn.y = pwdText.bottom + 45;
//    loginBtn.width = MAINSCREEN.size.width - 40;
//    loginBtn.height = 57;
//    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
//    loginBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//    [loginBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
//    [loginBtn setBackgroundImage:[UIImage imageNamed:@"login_commit"] forState:UIControlStateNormal];
//    loginBtn.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
//    [loginBtn addTarget:self action:@selector(loginClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:loginBtn];
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
    titleLabel.text = @"登录";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    
    //注册按钮
//    UIButton *registBtn = [[UIButton alloc] init];
//    registBtn.width = 44;
//    registBtn.height = 30;
//    registBtn.y = 32;
//    registBtn.x = view.width - registBtn.width - 20;
//    [registBtn setTitle:@"注册" forState:UIControlStateNormal];
//    [registBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
//    registBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [registBtn addTarget:self action:@selector(registerBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:registBtn];
}

/**
 * 返回上一页点击事件
 */
- (void)cancelClickAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 缩回键盘
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

/**
 * 限制UItextfield的输入长度
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    
    if ([textField isEqual:self.phoneText]) {
        if (existedLength - selectedLength + replaceLength <=11) {
            return YES;
            
        }else{
            return  NO;
        }
    }else if ([textField isEqual:self.pwdText])
    {
        if (existedLength - selectedLength + replaceLength <=16) {
            NSCharacterSet *cs;
            cs = [[NSCharacterSet characterSetWithCharactersInString:kAlphaNum] invertedSet];
            NSString *filtered =
            [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            BOOL basic = [string isEqualToString:filtered];
            return basic;
        }else{
            return  NO;
        }
    }
    return YES;
}

/**
 *  键盘显示事件
 */
- (void) keyboardWillShow:(NSNotification *)notification {
    
    CGFloat textBottom;
    if ([self.phoneText isFirstResponder]) {
        textBottom = self.phoneText.bottom + 80;
    }else if ([self.pwdText isFirstResponder])
    {
        textBottom = self.pwdText.bottom + 80;
    }
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat offset = kbHeight + textBottom - MAINSCREEN.size.height;
    
    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
    //    CGFloat offset = (self.view.frame.origin.y+self.view.frame.size.height) - (self.view.frame.size.height - kbHeight);
    
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //将视图上移计算好的偏移
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.contentView.y = 0 - offset;
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
        self.contentView.y = 80;
    }];
}

/**
 * 注册按钮点击事件
 */
- (void)registerBtnClickAction
{
    ZJRegisterViewController *vc = [[ZJRegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 * 登陆按钮点击事件
 */
- (void)loginClickAction
{
    [self.view endEditing:YES];
    
    NSString *phoneStr = self.phoneText.text;
    NSString *pwdStr = self.pwdText.text;
    
    if ([phoneStr isEqualToString:@""]) {
        [MBProgressHUD showError:@"手机号为空"];
    }else if (![ZJCommonFuction checkTel:phoneStr])
    {
        [MBProgressHUD showError:@"手机号错误"];
    }else if ([pwdStr isEqualToString:@""])
    {
        [MBProgressHUD showError:@"密码为空"];
    }else
    {
        [self requestLogin];
    }
}

/**
 * 忘记按钮点击事件
 */
- (void) forgetPwdClickAction
{
    ZJForgetPwdViewController *vc = [[ZJForgetPwdViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias)  ;
}
@end
