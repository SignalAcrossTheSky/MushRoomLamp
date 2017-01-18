//
//  ZJAddClockViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 12/6/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJAddClockViewController.h"
#import "Constant.h"
#import "ZJDayView.h"
#import "ZJInterface.h"
#import "MBProgressHUD+NJ.h"

@interface ZJAddClockViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,ZJDayViewDelegate,ZJInterfaceDelegate>
{
    NSMutableArray *hourArray;
    NSMutableArray *minArray;
}
@property (nonatomic,strong) UIPickerView *pickView;
@property (nonatomic,strong) UIView *blackView;
@property (nonatomic,strong) ZJDayView *dayView;
@property (nonatomic,strong) UITextField *remarkText;
@property (nonatomic,strong) UIView *mainView;
/** 重复的天 */
@property (nonatomic,strong) UIButton *repeatDay;
/** 添加闹钟网络接口请求 */
@property (nonatomic,strong) ZJInterface *interfaceAddClock;
@end

@implementation ZJAddClockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initArray];
    
    [self createPickView];
    
    [self createRemarkAndDayView];
    
    [self createTitleView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.remarkText];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:self.remarkText];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 添加闹钟接口请求
 */
- (void)addAlarmClockRequest
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);

    param[@"deviceId"] = @([self.device_id intValue]);
    
    NSArray *weekArray = [self.repeatDay.titleLabel.text componentsSeparatedByString:@","];

    NSMutableString *newWeekArray = [NSMutableString string];
    for (int i = 0; i < weekArray.count ;i++) {
        NSString *day = [weekArray objectAtIndex:i];
        if ([day isEqualToString:@"周一"]) {
            [newWeekArray appendString:@"1,"];
        }else if ([day isEqualToString:@"周二"])
        {
            [newWeekArray appendString:@"2,"];
        }else if ([day isEqualToString:@"周三"])
        {
            [newWeekArray appendString:@"3,"];
        }else if ([day isEqualToString:@"周四"])
        {
            [newWeekArray appendString:@"4,"];
        }else if ([day isEqualToString:@"周五"])
        {
            [newWeekArray appendString:@"5,"];
        }else if ([day isEqualToString:@"周六"])
        {
            [newWeekArray appendString:@"6,"];
        }else if ([day isEqualToString:@"周日"])
        {
            [newWeekArray appendString:@"7,"];
        }
    }
    param[@"week"] = newWeekArray;
    
    param[@"hour"] = @([self.pickView selectedRowInComponent:1]);
    
    param[@"minute"] = @([self.pickView selectedRowInComponent:2]);
    
    param[@"remarks"] = self.remarkText.text;
    
//    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceAddClock = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceAddClock interfaceWithType:INTERFACE_TYPE_ADDALARMCLOCK param:param];
    
    [MBProgressHUD showMessage:@""];
}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (interface == self.interfaceAddClock) {
        if ([result[@"code"] isEqual:@(0)]) {
            [self createTipView:@"添加成功"];
        }else
        {
            [ZJCommonFuction createTipView:@"添加失败" inViewController:self];
        }
    }
}

/**
 * 初始化数组
 */
- (void)initArray
{
    hourArray = [[NSMutableArray alloc] init];
    for(int i = 0 ;i < 24; i ++)
    {
        if (i < 10) {
            [hourArray addObject:[NSString stringWithFormat:@"0%d",i]];
        }else{
            [hourArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    minArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 60 ; i ++) {
        if (i < 10) {
            [minArray addObject:[NSString stringWithFormat:@"0%d",i]];
        }else
        {
            [minArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
}

/**
 * 创建titleView
 */
- (void)createTitleView
{
    self.view.backgroundColor =  DDRGBColor(245, 248, 250);
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 0;
    view.width = MAINSCREEN.size.width;
    view.height = 64;
    view.backgroundColor = DDRGBColor(36, 38, 51);
    [self.view addSubview:view];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 20;
    titleLabel.width = MAINSCREEN.size.width;
    titleLabel.height = 40;
    titleLabel.text = @"添加闹钟";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    
    //确定按钮
    UIButton *OKBtn = [[UIButton alloc] init];
    OKBtn.width = 40;
    OKBtn.height = 20;
    OKBtn.x = self.view.width - 15 - OKBtn.width;
    OKBtn.y = 30;
    [OKBtn setTitle:@"确定" forState:UIControlStateNormal];
    [OKBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    OKBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [view addSubview:OKBtn];
    [OKBtn addTarget:self action:@selector(selfOkBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    
    //取消按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.width = 40;
    cancelBtn.height = 20;
    cancelBtn.x = 15;
    cancelBtn.y = 30;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn addTarget:self action:@selector(selfCancelBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cancelBtn];
}

/**
 * 创建PickView
 */
- (void)createPickView
{
    UIView *mainView = [[UIView alloc] init];
    mainView.x = 0;
    mainView.y = 64;
    mainView.width = MAINSCREEN.size.width;
    mainView.height = MAINSCREEN.size.height - 64;
    [self.view addSubview:mainView];
    self.mainView = mainView;

    UIPickerView *pickView = [[UIPickerView alloc] init];
    pickView.delegate = self;
    pickView.dataSource = self;
    pickView.y = 20;
    pickView.x = 0;
    pickView.width = MAINSCREEN.size.width;
    pickView.height = 200;
    pickView.backgroundColor = [UIColor whiteColor];
    [self.mainView addSubview:pickView];
    self.pickView = pickView;
    
    pickView.layer.borderColor = DDRGBColor(230, 230, 230).CGColor;
    pickView.layer.borderWidth = 0.5;
}

/**
 * 创建备注和天数View
 */
- (void)createRemarkAndDayView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 230;
    view.width = MAINSCREEN.size.width;
    view.height = 120;
    view.backgroundColor = [UIColor whiteColor];
    [self.mainView addSubview:view];
    
    //备注
    UILabel *remarkLab = [[UILabel alloc] init];
    remarkLab.x = 15;
    remarkLab.y = 0;
    remarkLab.width = 40;
    remarkLab.height = 60;
    remarkLab.text = @"备注";
    remarkLab.textColor = DDRGBColor(102, 120, 102);
    remarkLab.font = [UIFont systemFontOfSize:15];
    [view addSubview:remarkLab];
    
    //竖着的线
    UILabel *vline = [[UILabel alloc] init];
    vline.x = remarkLab.right + 10;
    vline.height = 36;
    vline.y = 12;
    vline.width = 1;
    vline.backgroundColor = DDRGBColor(233, 233, 233);
    [view addSubview:vline];
    
    //输入备注
    UITextField *textField = [[UITextField alloc] init];
    textField.x = vline.right + 20;
    textField.y = 2;
    textField.width = MAINSCREEN.size.width - textField.x - 10;
    textField.height = 58;
    textField.placeholder = @"请输入备注";
    textField.clearButtonMode = UITextFieldViewModeAlways;
    [view addSubview:textField];
    self.remarkText = textField;
    
    //分割线
    UILabel *hLine = [[UILabel alloc] init];
    hLine.x = 15;
    hLine.width = MAINSCREEN.size.width - 30;
    hLine.y = remarkLab.bottom;
    hLine.height = 1;
    hLine.backgroundColor = DDRGBColor(233, 233, 233);
    [view addSubview:hLine];
    
    //重复
    UILabel *repeatLab = [[UILabel alloc] init];
    repeatLab.x = 15;
    repeatLab.y = 60;
    repeatLab.width = 40;
    repeatLab.height = 60;
    repeatLab.textColor = DDRGBColor(102, 102, 102);
    repeatLab.font = [UIFont systemFontOfSize:15];
    repeatLab.text = @"重复";
    [view addSubview:repeatLab];
    
    //重复的时间
    UIButton *dayBtn = [[UIButton alloc] init];
    dayBtn.x = repeatLab.right + 20;
    dayBtn.y = repeatLab.y;
    dayBtn.width = MAINSCREEN.size.width - dayBtn.x - 15 - 20;
    dayBtn.height = 60;
    [dayBtn setTitle:@"周一" forState:UIControlStateNormal];
    [dayBtn setTitleColor:DDRGBColor(153, 153, 153) forState:UIControlStateNormal];
    dayBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    dayBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [dayBtn addTarget:self action:@selector(repeatBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    self.repeatDay = dayBtn;
    [view addSubview:dayBtn];
    
    view.layer.borderColor = DDRGBColor(230,230,230).CGColor;
    view.layer.borderWidth = 0.5;
    
    //右箭头
    UIImageView *rightArrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray_arrow_right"]];
    rightArrowImage.width = 16;
    rightArrowImage.height = 16;
    rightArrowImage.x = MAINSCREEN.size.width - 15 - rightArrowImage.width;
    rightArrowImage.y = 82;
    [view addSubview:rightArrowImage];
}

#pragma mark pickview的datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 1) {
        return 24;
    }else if (component == 2)
    {
        return 60;
    }
    
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return MAINSCREEN.size.width/4;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    if(component == 1)
    {
        title = [NSString stringWithFormat:@"%@",[hourArray objectAtIndex:row]];
    }else if (component == 2)
    {
        title = [NSString stringWithFormat:@"%@",[minArray objectAtIndex:row]];
    }
    return title;
}

/**
 * 确定按钮点击事件
 */
- (void)selfOkBtnClickAction
{
    [self addAlarmClockRequest];
}

/**
 * 取消按钮点击事件
 */
- (void)selfCancelBtnClickAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 重复按钮点击事件
 */
- (void)repeatBtnClickAction
{
    UIView *blackCover = [[UIView alloc] init];
    blackCover.x = 0;
    blackCover.y = 0;
    blackCover.width = MAINSCREEN.size.width;
    blackCover.height = MAINSCREEN.size.height;
    blackCover.backgroundColor = DDRGBAColor(0, 0, 0, 0.8);
    [self.view addSubview:blackCover];
    self.blackView = blackCover;
    
    ZJDayView *dayView = [[ZJDayView alloc] initWithFrame:CGRectMake(15, MAINSCREEN.size.height - 400 - 15, MAINSCREEN.size.width - 30, 400)];
    dayView.delegate = self;
    dayView.backgroundColor = [UIColor whiteColor];
    dayView.layer.cornerRadius = 10;
    dayView.layer.borderColor = DDRGBColor(230, 230, 230).CGColor;
    dayView.layer.borderWidth = 1;
    dayView.dayStr = self.repeatDay.titleLabel.text;
    [self.view addSubview:dayView];
    self.dayView = dayView;
}

#pragma mark -- ZJDayViewDelegate  的代理方法
/**
 * 取消按钮点击事件
 */
- (void)cancelBtnClickAction
{
    [self.blackView removeFromSuperview];
    [self.dayView removeFromSuperview];
    self.blackView = nil;
    self.dayView = nil;
}

/**
 * 确认按钮点击事件
 */
- (void)okBtnClickAction:(NSString *)dayStr
{
    NSString *str = [dayStr substringToIndex:dayStr.length - 1];
    [self.repeatDay setTitle:str forState:UIControlStateNormal];
    [self.blackView removeFromSuperview];
    [self.dayView removeFromSuperview];
    self.blackView = nil;
    self.dayView = nil;
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

/**
 *  键盘显示事件
 */
- (void) keyboardWillShow:(NSNotification *)notification {
    
    CGFloat textBottom;
    if ([self.remarkText isFirstResponder]) {
        textBottom = self.remarkText.bottom + 230 + 64;
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
            self.mainView.y = 0 - offset;
        }];
    }else
    {
        [UIView animateWithDuration:duration animations:^{
            self.mainView.y = 64;
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
        self.mainView.y = 64;
    }];
}

/**
 * 创建提示框
 */
- (void)createTipView:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if ([message isEqualToString:@"添加成功"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

@end
