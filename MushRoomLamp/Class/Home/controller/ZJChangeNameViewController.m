
//
//  ZJChangeNameViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 7/27/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJChangeNameViewController.h"
#import "Constant.h"
#import "ZJInterface.h"
#import "MBProgressHUD+NJ.h"

@interface ZJChangeNameViewController ()<ZJInterfaceDelegate,UITextFieldDelegate>

/** 重命名接口 */
@property (nonatomic,strong) ZJInterface *interfaceRename;
/** 命名TEXTFIELD */
@property (nonatomic,strong) UITextField *nameText;
@end

@implementation ZJChangeNameViewController

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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.nameText];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:self.nameText];
    [super viewWillDisappear:animated];
}


/**
 * 重命名网络请求
 */
- (void)requestRename
{
    [MBProgressHUD showMessage:nil];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"deviceId"] = @([self.deviceID integerValue]);
    
    param[@"name"] = self.nameText.text;
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceRename = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceRename interfaceWithType:INTERFACE_TYPE_RENAME param:param];
}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (interface == self.interfaceRename) {
        if ([result[@"code"] isEqual:@(0)]) {
            [self createTipView:@"名称修改成功"];
        }else
        {
            [self createTipView:@"名称修改失败"];
        }

    }
}

/**
 *  初始化View
 */
- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTitleView];
    [self createNameView];
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
    titleLabel.text = @"修改名称";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    
    //生成二维码按钮
    UIButton *qrCodeBtn = [[UIButton alloc] init];
    qrCodeBtn.width = 40;
    qrCodeBtn.height = 40;
    qrCodeBtn.x = view.width - qrCodeBtn.width - 8;
    qrCodeBtn.y = 23;
    [qrCodeBtn setTitle:@"确定" forState:UIControlStateNormal];
    qrCodeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [qrCodeBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
    [qrCodeBtn addTarget:self action:@selector(OKBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:qrCodeBtn];
}

/**
 * 创建命名View
 */
- (void)createNameView
{
    //原名称
    UILabel *preName = [[UILabel alloc] init];
    preName.x = 20;
    preName.y = 93;
    preName.width = 300;
    preName.height = 16;
    preName.text = [NSString stringWithFormat:@"原名称：%@",self.preName];
    preName.font = [UIFont systemFontOfSize:16];
    preName.textColor = DDRGBColor(133, 133, 133);
    [self.view addSubview:preName];
    
    //新名称
    UITextField *nameTxt = [[UITextField alloc] init];
    nameTxt.x = 20;
    nameTxt.y = preName.bottom + 20;
    nameTxt.width = self.view.width - nameTxt.x - 20;
    nameTxt.height = 40;
    nameTxt.layer.borderColor = DDRGBColor(200, 200, 200).CGColor;
    nameTxt.layer.borderWidth = 1;
    nameTxt.borderStyle = UITextBorderStyleNone;
    nameTxt.placeholder = @" 请输入新的名字";
    nameTxt.delegate = self;
    [self.view addSubview:nameTxt];
    self.nameText = nameTxt;
}

/**
 * 返回上一层按钮点击时间
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
 * 确定按钮点击事件
 */
- (void)OKBtnClickAction
{
    if ([self.nameText.text isEqualToString:@""]) {
        [self createTipView:@"新名字不能为空"];
    }else
    {
        [self requestRename];
    }
}

/**
 * 创建提示框
 */
- (void)createTipView:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        if([message isEqualToString:@"名称修改成功"])
        {
            [self.navigationController popViewControllerAnimated:YES];
            if ([_delegate respondsToSelector:@selector(resetName:)]) {
                [_delegate resetName:self.nameText.text];
            }
        }else
        {
            
        }
    }];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
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
-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSArray * currentar = [UITextInputMode activeInputModes];
    UITextInputMode * current = [currentar firstObject];
    NSString *lang = [current primaryLanguage]; // 键盘输入模式
    NSLog(@"%@",lang);
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 10) {
                textField.text = [toBeString substringToIndex:10];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 12) {
            textField.text = [toBeString substringToIndex:12];
        }
    }
}
@end
