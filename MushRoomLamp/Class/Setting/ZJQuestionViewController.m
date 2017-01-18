//
//  ZJQuestionViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 6/27/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJQuestionViewController.h"
#import "Constant.h"
#import "ZJInterface.h"
#import "MBProgressHUD+NJ.h"

@interface ZJQuestionViewController ()<UITextViewDelegate,ZJInterfaceDelegate>

/** 产品意见View */
@property (nonatomic,strong) UIView *productOpinionView;
/** 网络问题View */
@property (nonatomic,strong) UIView *networkQuestionView;
/** 其他建议View */
@property (nonatomic,strong) UIView *otherAdviceView;
/** TipView */
@property (nonatomic,strong) UIView *tipView;

/** 产品意见的image */
@property (nonatomic,strong) UIButton *productOpinionImage;
/** 网络问题的image */
@property (nonatomic,strong) UIButton *networkQuestionImage;
/** 其他建议的image */
@property (nonatomic,strong) UIButton *otherAdviceImage;

/** 产品意见Text */
@property (nonatomic,strong) UITextView *productTextView;
/** 网络意见Text */
@property (nonatomic,strong) UITextView *questionTextView;
/** 其他建议Text */
@property (nonatomic,strong) UITextView *otherAdviceTextView;
/** 意见反馈网络请求 */
@property (nonatomic,strong) ZJInterface *interfaceFeedback;

@end

@implementation ZJQuestionViewController

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
 * 意见反馈网络请求
 */
- (void) feedbackRequest
{
    [MBProgressHUD showMessage:@"提交中..."];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"productAdvice"] = self.productTextView.text;
    dic[@"networkAdvice"] = self.questionTextView.text;
    dic[@"otherAdvice"] = self.otherAdviceTextView.text;
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];

    param[@"userId"] = @([[userdefault objectForKey:@"userid"] integerValue]);
    
    param[@"content"] = [ZJCommonFuction dictionaryToJson:dic];
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceFeedback = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceFeedback interfaceWithType:INTERFACE_TYPE_FEEDBACK param:param];
}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (interface == self.interfaceFeedback) {
        if ([result[@"code"] isEqual:@(0)]) {
            [self createTipView:@"提交成功"];
        }else
        {
            [self createTipView:@"提交失败"];
        }
        
    }
}

/**
 * 初始化View
 */
- (void) initView
{
    self.view.backgroundColor = DDRGBColor(237, 237, 237);
    [self.tabBarController.tabBar setHidden:YES];
    
    [self createProductOpinionView];
    
    [self createNetworkQuestionView];
    
    [self createOtherAdviceView];
    
    [self createTipView];
    
    [self createTitleView];
}

/**
 * 创建TitleView
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
    
    //提交按钮
    UIButton *submitBtn = [[UIButton alloc] init];
    submitBtn.width = 40;
    submitBtn.height = 40;
    submitBtn.x = view.width - 10 - submitBtn.width;
    submitBtn.y = 23;
    [submitBtn setImage:[UIImage imageNamed:@"submit"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:submitBtn];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 37;
    titleLabel.width = MAINSCREEN.size.width;
    titleLabel.height = 17;
    titleLabel.text = @"意见反馈";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
}

/**
 * 创建产品意见View
 */
- (void)createProductOpinionView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 80;
    view.height = MAINSCREEN.size.height;
    view.width = MAINSCREEN.size.width;
    view.backgroundColor = DDRGBColor(237, 237, 237);
    [self.view addSubview:view];
    self.productOpinionView = view;
    
    UIView *titleView = [[UIView alloc] init];
    titleView.x = 0;
    titleView.y = 0;
    titleView.width = MAINSCREEN.size.width;
    titleView.height = 56;
    titleView.backgroundColor = [UIColor whiteColor];
    [view addSubview:titleView];
    
    //图标
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"padvice"]];
    icon.x = 20;
    icon.y = 19;
    icon.width = 20;
    icon.height = 18;
    [titleView addSubview:icon];

    //产品意见
    UILabel *productLabel = [[UILabel alloc] init];
    productLabel.x = icon.right + 15;
    productLabel.y = 0;
    productLabel.width = 100;
    productLabel.height = titleView.height;
    productLabel.text = @"产品意见";
    productLabel.font = [UIFont systemFontOfSize:16];
    [titleView addSubview:productLabel];
    
    //下箭头
    UIButton *arrowImage = [[UIButton alloc] init];
    arrowImage.width = 40;
    arrowImage.height = 40;
    arrowImage.x = MAINSCREEN.size.width - arrowImage.width - 10;
    arrowImage.y = 8;
    [arrowImage setImage:[UIImage imageNamed:@"green_arrow_down"] forState:UIControlStateNormal];
    [arrowImage setImage:[UIImage imageNamed:@"green_arrow_up"] forState:UIControlStateSelected];
    [arrowImage addTarget:self action:@selector(productAdviceClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [arrowImage setSelected:NO];
    [titleView addSubview:arrowImage];
    self.productOpinionImage = arrowImage;
    
    //建议输入框
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:14];
    textView.x = 20;
    textView.y = titleView.bottom + 5;
    textView.width = view.width - 40;
    textView.height = 100;
    textView.delegate = self;
    textView.backgroundColor = DDRGBColor(237, 237, 237);
    [view addSubview:textView];
    self.productTextView = textView;
    
    //输入框上的placeholder
    UILabel *placeholderLab = [[UILabel alloc] init];
    placeholderLab.x =  10;
    placeholderLab.y =  8;
    placeholderLab.width = textView.width - 20;
    placeholderLab.height = 14;
    placeholderLab.text = @"请详细描述您的具体建议";
    placeholderLab.font = [UIFont systemFontOfSize:14];
    placeholderLab.textColor = DDRGBColor(180, 180, 180);
    [textView addSubview:placeholderLab];
}

/**
 * 创建网络问题View
 */
- (void)createNetworkQuestionView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 57;
    view.height = MAINSCREEN.size.height;
    view.width = MAINSCREEN.size.width;
    view.backgroundColor = DDRGBColor(237, 237, 237);
    [self.productOpinionView addSubview:view];
    self.networkQuestionView = view;
    
    UIView *titleView = [[UIView alloc] init];
    titleView.x = 0;
    titleView.y = 0;
    titleView.width = MAINSCREEN.size.width;
    titleView.height = 56;
    titleView.backgroundColor = [UIColor whiteColor];
    [view addSubview:titleView];
    
    //图标
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WIFI"]];
    icon.x = 20;
    icon.y = 19;
    icon.width = 20;
    icon.height = 18;
    [titleView addSubview:icon];

    //网络问题
    UILabel *networkLabel = [[UILabel alloc] init];
    networkLabel.x = icon.right + 15;
    networkLabel.y = 0;
    networkLabel.width = 100;
    networkLabel.height = titleView.height;
    networkLabel.text = @"网络问题";
    networkLabel.font = [UIFont systemFontOfSize:16];
    [titleView addSubview:networkLabel];
    
    //下箭头
    UIButton *arrowImage = [[UIButton alloc] init];
    arrowImage.width = 40;
    arrowImage.height = 40;
    arrowImage.x = MAINSCREEN.size.width - arrowImage.width - 10;
    arrowImage.y = 8;
    [arrowImage setImage:[UIImage imageNamed:@"green_arrow_down"] forState:UIControlStateNormal];
    [arrowImage setImage:[UIImage imageNamed:@"green_arrow_up"] forState:UIControlStateSelected];
    [arrowImage addTarget:self action:@selector(networkClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [arrowImage setSelected:NO];
    [titleView addSubview:arrowImage];
    self.networkQuestionImage = arrowImage;
    
    //建议输入框
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:14];
    textView.x = 20;
    textView.y = titleView.bottom + 5;
    textView.width = view.width - 40;
    textView.height = 100;
    textView.delegate = self;
    textView.backgroundColor = DDRGBColor(237, 237, 237);
    [view addSubview:textView];
    self.questionTextView = textView;
    
    //输入框上的placeholder
    UILabel *placeholderLab = [[UILabel alloc] init];
    placeholderLab.x =  10;
    placeholderLab.y =  8;
    placeholderLab.width = textView.width - 20;
    placeholderLab.height = 14;
    placeholderLab.text = @"请详细描述您的具体建议";
    placeholderLab.font = [UIFont systemFontOfSize:14];
    placeholderLab.textColor = DDRGBColor(180, 180, 180);
    [textView addSubview:placeholderLab];
}

/**
 * 创建其他建议View
 */
- (void)createOtherAdviceView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 57;
    view.height = MAINSCREEN.size.height;
    view.width = MAINSCREEN.size.width;
    view.backgroundColor = DDRGBColor(237, 237, 237);
    [self.networkQuestionView addSubview:view];
    self.otherAdviceView = view;
    
    UIView *titleView = [[UIView alloc] init];
    titleView.x = 0;
    titleView.y = 0;
    titleView.width = MAINSCREEN.size.width;
    titleView.height = 56;
    titleView.backgroundColor = [UIColor whiteColor];
    [view addSubview:titleView];
    
    //图标
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"otheradvice"]];
    icon.x = 20;
    icon.y = 19;
    icon.width = 20;
    icon.height = 18;
    [titleView addSubview:icon];
    
    //其他建议
    UILabel *networkLabel = [[UILabel alloc] init];
    networkLabel.x = icon.right + 15;
    networkLabel.y = 0;
    networkLabel.width = 100;
    networkLabel.height = titleView.height;
    networkLabel.text = @"其他建议";
    networkLabel.font = [UIFont systemFontOfSize:16];
    [titleView addSubview:networkLabel];
    
    //下箭头
    UIButton *arrowImage = [[UIButton alloc] init];
    arrowImage.width = 40;
    arrowImage.height = 40;
    arrowImage.x = MAINSCREEN.size.width - arrowImage.width - 10;
    arrowImage.y = 8;
    [arrowImage setImage:[UIImage imageNamed:@"green_arrow_down"] forState:UIControlStateNormal];
      [arrowImage setImage:[UIImage imageNamed:@"green_arrow_up"] forState:UIControlStateSelected];
    [arrowImage addTarget:self action:@selector(otherAdviceClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [arrowImage setSelected:NO];
    [titleView addSubview:arrowImage];
    self.otherAdviceImage = arrowImage;
    
    //建议输入框
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:14];
    textView.x = 20;
    textView.y = titleView.bottom + 5;
    textView.width = view.width - 40;
    textView.height = 100;
    textView.delegate = self;
    textView.backgroundColor = DDRGBColor(237, 237, 237);
    [view addSubview:textView];
    self.otherAdviceTextView = textView;
    
    //输入框上的placeholder
    UILabel *placeholderLab = [[UILabel alloc] init];
    placeholderLab.x =  10;
    placeholderLab.y =  8;
    placeholderLab.width = textView.width - 20;
    placeholderLab.height = 14;
    placeholderLab.text = @"请详细描述您的具体建议";
    placeholderLab.font = [UIFont systemFontOfSize:14];
    placeholderLab.textColor = DDRGBColor(180, 180, 180);
    [textView addSubview:placeholderLab];
}

/**
 * 创建TipView
 */
- (void)createTipView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 57;
    view.width = MAINSCREEN.size.width;
    view.height = MAINSCREEN.size.height;
    view.backgroundColor = DDRGBColor(237, 237, 237);
    [self.otherAdviceView addSubview:view];
    self.tipView = view;
    
}


/**
 * UITextViewDelegate方法
 */
- (void)textViewDidChange:(UITextView *)textView
{
    UILabel *label;
    for(id object in textView.subviews)
    {
        if ([object isKindOfClass:[UILabel class]]) {
            label = (UILabel *)object;
        }
    }
    
    //限制100字数
    NSInteger number = [textView.text length];
    if (number > 100) {
        textView.text = [textView.text substringToIndex:100];

    }

    if (textView.text.length == 0) {
        label.text = @"请详细描述您的具体建议";
    }else
    {
        label.text = @"";
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

/**
 * 缩回键盘
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

/**
 * 返回上一页点击事件
 */
- (void)cancelClickAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 提交按钮点击事件
 */
- (void)submitClickAction
{
    [self feedbackRequest];
}

/**
 * 产品意见的按钮点击事件
 */
- (void)productAdviceClickAction:(UIButton *)sender
{
    UIButton *button = (UIButton *) sender;
    if ([button isSelected]) {
        [button setSelected:NO];
        [UIView animateWithDuration:0.4 animations:^{
            self.networkQuestionView.y = 57;
        } completion:^(BOOL finished) {
            
        }];

    }else {
        [button setSelected:YES];
        [UIView animateWithDuration:0.4 animations:^{
            self.networkQuestionView.y = 167;
        } completion:^(BOOL finished) {
        }];
    }
}

/**
 * 网络问题的按钮点击事件
 */
- (void)networkClickAction:(UIButton *)sender
{
    UIButton *button = (UIButton *) sender;
    if ([button isSelected]) {
        [button setSelected:NO];
        [UIView animateWithDuration:0.4 animations:^{
            self.otherAdviceView.y = 57;
        } completion:^(BOOL finished) {
            
        }];
        
    }else {
        [button setSelected:YES];
        [UIView animateWithDuration:0.4 animations:^{
            self.otherAdviceView.y = 167;
        } completion:^(BOOL finished) {
        }];
    }

}

/**
 * 其他建议的按钮点击事件
 */
- (void)otherAdviceClickAction:(UIButton *)sender
{
    UIButton *button = (UIButton *) sender;
    if ([button isSelected]) {
        [button setSelected:NO];
        [UIView animateWithDuration:0.4 animations:^{
            self.tipView.y = 57;
        } completion:^(BOOL finished) {
            
        }];
        
    }else {
        [button setSelected:YES];
        [UIView animateWithDuration:0.4 animations:^{
            self.tipView.y = 167;
        } completion:^(BOOL finished) {
        }];
    }

}

/**
 *  键盘显示事件
 */
- (void) keyboardWillShow:(NSNotification *)notification {
    
    CGFloat textBottom;
    if ([self.productTextView isFirstResponder]) {
        textBottom = 236;
    }else if ([self.questionTextView isFirstResponder])
    {
        if (self.networkQuestionView.y == 57) {
            textBottom = 293;
        }else{
            textBottom = 403;
        }
        
    }else if ([self.otherAdviceTextView isFirstResponder])
    {
        if (self.networkQuestionView.y == 57) {
            if (self.otherAdviceView.y == 57) {
                textBottom = 350;
            }else
            {
                textBottom = 460;
            }
        }else{
            
            if (self.otherAdviceView.y == 57) {
                textBottom = 460;
            }else
            {
                textBottom = 570;
            }
        }
    }
    
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
    CGFloat offset = kbHeight + textBottom - MAINSCREEN.size.height;
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //将视图上移计算好的偏移
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.productOpinionView.y = 0 - offset;
        }];
    }else
    {
        [UIView animateWithDuration:duration animations:^{
            self.productOpinionView.y = 80;
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
        self.productOpinionView.y = 80;
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
