//
//  ZJRegisterViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 7/1/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJRegisterViewController.h"
#import "Constant.h"
#import "ZJInterface.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+NJ.h"
#import "ZJLoginViewController.h"

@interface ZJRegisterViewController ()<ZJInterfaceDelegate,UITextFieldDelegate>
{
//    MBProgressHUD *HUD;
}

/** 发送验证码接口 */
@property (nonatomic,strong) ZJInterface *interfaceSendSecurityCode;
/** 注册接口 */
@property (nonatomic,strong) ZJInterface *interfaceRegist;
/** 手机号输入框 */
@property (nonatomic,strong) UITextField *phoneText;
/** 验证码输入框 */
@property (nonatomic,strong) UITextField *securityCodeText;
/** 新密码输入框 */
@property (nonatomic,strong) UITextField *PwdText;
/** 确认密码输入框 */
@property (nonatomic,strong) UITextField *againPwdtext;
/** 内容View */
@property (nonatomic,strong) UIView *contentView;
@end

@implementation ZJRegisterViewController

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
 * 发送验证码网络请求
 */
- (void) requestSendSecurityCode
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    param[@"mobile"] = self.phoneText.text;
    
    param[@"type"] = @(1);
    
    param[@"terminalId"] = @(1);
    
    self.interfaceSendSecurityCode = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceSendSecurityCode interfaceWithType:INTERFACE_TYPE_MESSAGECODE param:param];
}

/**
 * 注册网络请求
 */
- (void) requestRegist
{
    [MBProgressHUD showMessage:@""];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    param[@"loginName"] = self.phoneText.text;
    
    param[@"verifyCode"] = @([self.securityCodeText.text integerValue]);
    
    param[@"loginPass"] = self.PwdText.text;
    
    param[@"terminalId"] = @(1);
    
    self.interfaceRegist = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceRegist interfaceWithType:INTERFACE_TYPE_REGISTER param:param];
}

/**
 * 网络请求反回数据
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (interface == self.interfaceSendSecurityCode) {
       
       if([result[@"code"] isEqual:@(0)])
       {
           [MBProgressHUD showError:@"验证码发送成功"];

       }else if ([result[@"code"] isEqual:@(14008)])
       {
           [self createTipView:@"超过每天10条短信发送限制"];
       }else if ([result[@"code"] isEqual:@(14009)])
       {
           [self createTipView:@"1分钟后再发送"];
       }else
       {
           [self createTipView:@"验证码发送失败"];
       }
    }else if (interface == self.interfaceRegist)
    {
        if ([result[@"code"] isEqual:@(0)]) {
            [MBProgressHUD showError:@"注册成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }else if([result[@"code"] isEqual:@(14004)])
        {
            [self createTipView:@"验证码已过期"];
        }else if([result[@"code"] isEqual:@(14005)])
        {
            [self createTipView:@"验证码不存在"];
        }else
        {
            [self createTipView:@"注册失败"];
        }
    }
}

/**
 * 初始化View
 */
- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createContentView];
    
    [self createTitleView];
}

/**
 * 创建注册View
 */
- (void)createContentView
{
    UIView *view = [[UIView alloc] init];
    view.x = 15;
    view.y = 94;
    view.width = MAINSCREEN.size.width - 30;
    view.height = 44 * 4;
    view.layer.borderWidth = 1;
    view.layer.borderColor = DDRGBColor(153, 153, 153).CGColor;
    view.layer.cornerRadius = 8;
    [self.view addSubview:view];
    
    //创建四条Line
    for (int i = 0;i<3; i++) {
        UILabel *line = [[UILabel alloc] init];
        line.x = 0;
        line.y = 44 * (i + 1);
        line.width = view.width;
        line.height = 0.5;
        line.backgroundColor = DDRGBColor(153,153,153);
        [view addSubview:line];
    }

    //手机输入框
    UILabel *phoneLabel = [[UILabel alloc] init];
    phoneLabel.width = 55;
    phoneLabel.height = view.height/4;
    phoneLabel.x = 0;
    phoneLabel.y = 0;
    phoneLabel.text = @"+86";
    phoneLabel.font = [UIFont systemFontOfSize:16];
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:phoneLabel];
    
    UITextField *phoneText = [[UITextField alloc] init];
    phoneText.x = phoneLabel.right;
    phoneText.y = 0;
    phoneText.width = view.width - phoneLabel.width;
    phoneText.height = view.height/4;
    phoneText.placeholder = @"请填写手机号码";
    phoneText.font = [UIFont systemFontOfSize:14];
    phoneText.delegate = self;
    phoneText.keyboardType = UIKeyboardTypeNumberPad;
    [view addSubview:phoneText];
    self.phoneText = phoneText;
    
    //创建设置密码
    UITextField *setPwdText = [[UITextField alloc] init];
    setPwdText.x = 15;
    setPwdText.y = phoneText.bottom;
    setPwdText.width = view.width;
    setPwdText.height = view.height/4;
    setPwdText.placeholder = @"设置6位以上登录密码";
    setPwdText.font = [UIFont systemFontOfSize:14];
    setPwdText.delegate = self;
    setPwdText.keyboardType = UIKeyboardTypeASCIICapable;
    setPwdText.secureTextEntry = YES;
    [view addSubview:setPwdText];
    self.PwdText = setPwdText;
    
    //创建确认密码
    UITextField *againPwdText = [[UITextField alloc] init];
    againPwdText.x = 15;
    againPwdText.y = setPwdText.bottom;
    againPwdText.width = view.width;
    againPwdText.height = view.height/4;
    againPwdText.placeholder = @"再次确认密码";
    againPwdText.font = [UIFont systemFontOfSize:14];
    againPwdText.delegate = self;
    againPwdText.keyboardType = UIKeyboardTypeASCIICapable;
    againPwdText.secureTextEntry = YES;
    [view addSubview:againPwdText];
    self.againPwdtext = againPwdText;

    //创建手机验证码输入框
    UITextField *securityText = [[UITextField alloc] init];
    securityText.x = 15;
    securityText.y = againPwdText.bottom;
    securityText.height = view.height/4;
    securityText.width = view.width - 100;
    securityText.placeholder = @"请填写手机验证码";
    securityText.font = [UIFont systemFontOfSize:14];
    securityText.delegate = self;
    securityText.keyboardType = UIKeyboardTypeNumberPad;
    [view addSubview:securityText];
    self.securityCodeText = securityText;
    
    //创建获取验证码按钮
    UIButton *securityBtn = [[UIButton alloc] init];
    securityBtn.width = 85;
    securityBtn.height = 44;
    securityBtn.y = securityText.y;
    securityBtn.x = view.width - 15 - securityBtn.width;
    [securityBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [securityBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
    securityBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [securityBtn addTarget:self action:@selector(sendSecurityCodeClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:securityBtn];
    
    //注册按钮
    UIButton *registBtn = [[UIButton alloc] init];
    registBtn.x = 15;
    registBtn.y = view.bottom + 30;
    registBtn.width = MAINSCREEN.size.width - 30;
    registBtn.height = 44;
    [registBtn setTitle:@"注册" forState:UIControlStateNormal];
    registBtn.layer.cornerRadius = 8;
    registBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [registBtn setTitleColor:DDRGBColor(255,255,255) forState:UIControlStateNormal];
    registBtn.backgroundColor = DDRGBColor(54, 57, 77);
    [registBtn addTarget:self action:@selector(completeClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registBtn];

//    UIView *view = [[UIView alloc] init];
//    view.x = 0;
//    view.y = 80;
//    view.width = MAINSCREEN.size.width;
//    view.height = MAINSCREEN.size.height - 80;
//    [self.view addSubview:view];
//    self.contentView = view;
//    
//    //手机登录图片
//    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logo"]];
//    logo.width = 101;
//    logo.height = 106;
//    logo.x = (MAINSCREEN.size.width - logo.width)/2;
//    logo.y = 22;
//    [view addSubview:logo];
//    
//    //手机登录Label
//    UILabel *label = [[UILabel alloc] init];
//    label.x = 0;
//    label.y = logo.bottom + 10;
//    label.width = MAINSCREEN.size.width;
//    label.height = 16;
//    label.text = @"手机注册";
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont systemFontOfSize:16];
//    [view addSubview:label];
//    
//    //创建四条Line
//    for (int i = 0;i<5; i++) {
//        
//        UILabel *line = [[UILabel alloc] init];
//        line.x = 20;
//        line.y = 180 + 45 * i;
//        line.width = MAINSCREEN.size.width - 40;
//        line.height = 1;
//        line.backgroundColor = DDRGBColor(233, 233, 233);
//        [view addSubview:line];
//        
//    }
//    
//    //手机输入框
//    UILabel *phoneLabel = [[UILabel alloc] init];
//    phoneLabel.width = 55;
//    phoneLabel.height = 45;
//    phoneLabel.x = 20;
//    phoneLabel.y = 180 ;
//    phoneLabel.text = @"+86";
//    phoneLabel.font = [UIFont systemFontOfSize:16];
//    phoneLabel.textAlignment = NSTextAlignmentCenter;
//    [view addSubview:phoneLabel];
//    
//    UITextField *phoneText = [[UITextField alloc] init];
//    phoneText.x = phoneLabel.right + 30;
//    phoneText.y = 180;
//    phoneText.width = 150;
//    phoneText.height = 45;
//    phoneText.placeholder = @"请填写手机号码";
//    phoneText.font = [UIFont systemFontOfSize:16];
//    phoneText.delegate = self;
//    phoneText.keyboardType = UIKeyboardTypeNumberPad;
//    [view addSubview:phoneText];
//    self.phoneText = phoneText;
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
//    //创建手机验证码输入框
//    UITextField *securityText = [[UITextField alloc] init];
//    securityText.x = 22;
//    securityText.y = phoneLabel.bottom;
//    securityText.height = 45;
//    securityText.width = 150;
//    securityText.placeholder = @"请填写手机验证码";
//    securityText.font = [UIFont systemFontOfSize:14];
//    securityText.delegate = self;
//    securityText.keyboardType = UIKeyboardTypeNumberPad;
//    [view addSubview:securityText];
//    self.securityCodeText = securityText;
//    
//    //创建获取验证码按钮
//    UIButton *securityBtn = [[UIButton alloc] init];
//    securityBtn.width = 100;
//    securityBtn.height = 45;
//    securityBtn.y = securityText.y;
//    securityBtn.x = view.width - 20 - securityBtn.width;
//    [securityBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
//    [securityBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
//    securityBtn.titleLabel.font = [UIFont systemFontOfSize:14];
//    [securityBtn addTarget:self action:@selector(sendSecurityCodeClickAction:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:securityBtn];
//    
//    //创建验证码竖的灰色线
//    UILabel *svLine = [[UILabel alloc] init];
//    svLine.width = 1;
//    svLine.height = 45;
//    svLine.x = securityBtn.x - 2;
//    svLine.y = securityBtn.y;
//    svLine.backgroundColor = DDRGBColor(233, 233, 233);
//    [view addSubview:svLine];
//    
//    //创建设置密码
//    UITextField *setPwdText = [[UITextField alloc] init];
//    setPwdText.x = 22;
//    setPwdText.y = securityText.bottom;
//    setPwdText.width = 200;
//    setPwdText.height = 45;
//    setPwdText.placeholder = @"设置密码";
//    setPwdText.font = [UIFont systemFontOfSize:14];
//    setPwdText.delegate = self;
//    setPwdText.keyboardType = UIKeyboardTypeASCIICapable;
//    setPwdText.secureTextEntry = YES;
//    [view addSubview:setPwdText];
//    self.PwdText = setPwdText;
//    
//    //创建确认密码
//    UITextField *againPwdText = [[UITextField alloc] init];
//    againPwdText.x = 22;
//    againPwdText.y = setPwdText.bottom;
//    againPwdText.width = 200;
//    againPwdText.height = 45;
//    againPwdText.placeholder = @"确认密码";
//    againPwdText.font = [UIFont systemFontOfSize:14];
//    againPwdText.delegate = self;
//    againPwdText.keyboardType = UIKeyboardTypeASCIICapable;
//    againPwdText.secureTextEntry = YES;
//    [view addSubview:againPwdText];
//    self.againPwdtext = againPwdText;
//    
//    //底部Button
//    UIButton *loginBtn = [[UIButton alloc] init];
//    loginBtn.x = 20;
//    loginBtn.y = 350 + 45;
//    loginBtn.width = MAINSCREEN.size.width - 40;
//    loginBtn.height = 57;
//    [loginBtn setTitle:@"完成" forState:UIControlStateNormal];
//    loginBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//    [loginBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
//    [loginBtn setBackgroundImage:[UIImage imageNamed:@"login_commit"] forState:UIControlStateNormal];
//    loginBtn.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
//    [loginBtn addTarget:self action:@selector(completeClickAction) forControlEvents:UIControlEventTouchUpInside];
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
    titleLabel.text = @"注册";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
}

/**
 * 返回上一页点击事件
 */
- (void)cancelClickAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 发送验证码按钮点击事件
 */
- (void) sendSecurityCodeClickAction:(UIButton *)sender
{
    NSString *string = self.phoneText.text;
    if ([string isEqualToString:@""]) {
        //弹出提示：请输入手机号
        [MBProgressHUD showError:@"手机号为空"];
        
    }else if (![ZJCommonFuction checkTel:string] || string.length != 11)
    {
        //弹出提示：请输入正确的手机号
        [MBProgressHUD showError:@"手机号错误"];
    }else {
        [ZJCommonFuction sendSecurityCodeButtonClickAction:sender withFirstTitle:@"获取验证码" withSecondTitle:@"重发"];
        [self requestSendSecurityCode];
    }
}

/**
 * 完成按钮点击事件
 */
- (void) completeClickAction
{
    NSString *phoneStr = self.phoneText.text;
    NSString *scStr = self.securityCodeText.text;
    NSString *newPwd = self.PwdText.text;
    NSString *againPwd = self.againPwdtext.text;
    
    if ([phoneStr isEqualToString:@""]) {
        //弹出提示：请输入手机号
        [MBProgressHUD showError:@"手机号为空"];
        
    }else if (![ZJCommonFuction checkTel:phoneStr] || phoneStr.length != 11)
    {
        //弹出提示：请输入正确的手机号
        [MBProgressHUD showError:@"手机号错误"];
    }else if ([scStr isEqualToString:@""])
    {
        [MBProgressHUD showError:@"验证码为空"];
    }else if (scStr.length != 6)
    {
        [MBProgressHUD showError:@"验证码错误"];
    }else if ([newPwd isEqualToString:@""] || [againPwd isEqualToString:@""])
    {
        [MBProgressHUD showError:@"密码为空"];
    }else if (![newPwd isEqualToString:againPwd])
    {
        [MBProgressHUD showError:@"两次密码不同"];
    }else
    {
        [self requestRegist];
    }
}

#pragma mark -- UITextFieldDelegate
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
    }else if ([textField isEqual:self.PwdText] || [textField isEqual:self.againPwdtext])
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
    }else if ([textField isEqual: self.securityCodeText]){//验证码
        
        if (existedLength - selectedLength + replaceLength <=6) {
            
            return YES;
        }else {
            return NO;
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
    }else if ([self.securityCodeText isFirstResponder])
    {
        textBottom = self.securityCodeText.bottom + 80;
    }else if ([self.PwdText isFirstResponder])
    {
        textBottom = self.PwdText.bottom + 80;
    }else if ([self.againPwdtext isFirstResponder])
    {
        textBottom = self.againPwdtext.bottom + 80;
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
    }else
    {
        [UIView animateWithDuration:duration animations:^{
            self.contentView.y = 80;
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

@end
