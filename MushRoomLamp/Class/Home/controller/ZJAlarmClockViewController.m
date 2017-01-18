//
//  ZJAlarmClockViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 12/5/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJAlarmClockViewController.h"
#import "ZJClockTableViewCell.h"
#import "ZJAddClockViewController.h"
#import "Constant.h"
#import "ZJClockSetViewController.h"
#import "ZJInterface.h"
#import "MBProgressHUD+NJ.h"
#import "ZJClock.h"

@interface ZJAlarmClockViewController ()<UITableViewDelegate,UITableViewDataSource,ZJInterfaceDelegate,ZJClockTableViewCellDelegate>
{
    NSMutableArray *clockArray;
}
@property (nonatomic,strong) UITableView *tableView;
/** 闹钟列表接口 */
@property (nonatomic,strong) ZJInterface *alarmClockInterface;
/** 打开闹钟接口 */
@property (nonatomic,strong) ZJInterface *openClockinterface;
@end

@implementation ZJAlarmClockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createMainView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self alarmClockListRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createMainView
{
    self.view.backgroundColor = DDRGBColor(245, 248, 250);
    [self createTitleView];
    
    UITableView *clockTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 84, MAINSCREEN.size.width, MAINSCREEN.size.height - 84 - 49)];
    clockTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    clockTableView.backgroundColor = DDRGBColor(245, 248, 250);
    clockTableView.dataSource = self;
    clockTableView.delegate = self;
    [self.view addSubview:clockTableView];
    self.tableView = clockTableView;
    
    [self createAddClockBtn];
}

/**
 * 闹钟列表网络请求
 */
- (void)alarmClockListRequest
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = [userDefault objectForKey:@"userid"];
    
    param[@"deviceId"] = self.device_id;
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.alarmClockInterface = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.alarmClockInterface interfaceWithType:INTERFACE_TYPE_ALARMCLOCKLIST param:param];
    
    [MBProgressHUD showMessage:@"数据加载中"];
}

/**
 * 打开闹钟网络请求
 */
- (void) openAlarmClockRequest:(NSDictionary *)param
{
    self.openClockinterface = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.openClockinterface interfaceWithType:INTERFACE_TYPE_OPENALARMCLOCK param:param];
    
    [MBProgressHUD showMessage:@""];
}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (self.alarmClockInterface == interface) {
        if ([result[@"code"] isEqual:@(0)]) {
            if (clockArray == nil) {
                clockArray = [[NSMutableArray alloc] init];
            }
            clockArray = result[@"data"][@"alarmClocks"];
            [self.tableView reloadData];
            
            if (clockArray.count == 0) {
                [self.tableView setHidden:YES];
            }else
            {
                [self.tableView setHidden:NO];
            }
        }
    }else if (self.openClockinterface)
    {
        if ([result[@"code"] isEqual:@(0)]) {
//            [ZJCommonFuction createTipView:@"开关成功" inViewController:self];
        }else
        {
//            [ZJCommonFuction createTipView:@"开关失败，请重新设置" inViewController:self];
        }
    }
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
    view.height = 64;
    view.backgroundColor = DDRGBColor(36, 38, 51);
    [self.view addSubview:view];
    
    //<按钮
    UIButton *closeBtn = [[UIButton alloc] init];
    closeBtn.x = 8;
    closeBtn.y = 20;
    closeBtn.width = 40;
    closeBtn.height = 40;
    [closeBtn setImage:[UIImage imageNamed:@"green_arrow_left"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(cancelClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 20;
    titleLabel.width = MAINSCREEN.size.width;
    titleLabel.height = 40;
    titleLabel.text = @"蘑菇闹钟";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
}

/**
 *  添加闹钟按钮
 */
- (void)createAddClockBtn
{
    UILabel *line = [[UILabel alloc] init];
    line.backgroundColor = DDRGBColor(230, 230, 230);
    line.width = MAINSCREEN.size.width;
    line.height = 1;
    line.x = 0;
    line.y = MAINSCREEN.size.height - 49;
    [self.view addSubview:line];
    
    UIButton *addClockBtn = [[UIButton alloc] init];
    addClockBtn.backgroundColor = [UIColor whiteColor];
    addClockBtn.x = 0;
    addClockBtn.y = MAINSCREEN.size.height - 48;
    addClockBtn.width = MAINSCREEN.size.width;
    addClockBtn.height = 49;
    [addClockBtn setImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
    [addClockBtn setTitle:@"添加闹钟" forState:UIControlStateNormal];
    [addClockBtn setTitleColor:DDRGBColor(0, 240, 200) forState:UIControlStateNormal];
    addClockBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    addClockBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
    [addClockBtn addTarget:self action:@selector(addAlarmClockClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addClockBtn];
}

/**
 * 返回上一层
 */
- (void) cancelClickAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 添加闹钟
 */
- (void) addAlarmClockClickAction
{
    ZJAddClockViewController *vc = [[ZJAddClockViewController alloc] init];
    vc.device_id = self.device_id;
    [self.navigationController pushViewController:vc animated:YES];
}

# pragma mark tableView的datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return clockArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * const cellIdentifier = @"CellIdentifier";
    ZJClockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ZJClockTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.delegate = self;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSDictionary *param = (NSDictionary *)[clockArray objectAtIndex:indexPath.row];
    
    NSString *dayStr = @"";
    NSArray *weekArray = [param[@"week"] componentsSeparatedByString:@","];
    for(id object in weekArray)
    {
        NSInteger objValue = [object integerValue];
        if (objValue == 1) {
            dayStr = [dayStr stringByAppendingString:@"周一，"];
        }else if (objValue == 2)
        {
            dayStr = [dayStr stringByAppendingString:@"周二，"];
        }else if (objValue == 3)
        {
            dayStr = [dayStr stringByAppendingString:@"周三，"];
        }else if (objValue == 4)
        {
            dayStr = [dayStr stringByAppendingString:@"周四，"];
        }else if (objValue == 5)
        {
            dayStr = [dayStr stringByAppendingString:@"周五，"];
        }else if (objValue == 6)
        {
            dayStr = [dayStr stringByAppendingString:@"周六，"];
        }else if (objValue == 7)
        {
            dayStr = [dayStr stringByAppendingString:@"周日，"];
        }
    }
    
    if (dayStr.length > 2) {
       dayStr = [dayStr substringToIndex:dayStr.length - 1];
    }

    dic[@"time"] = param[@"clockStr"];
    dic[@"remark"] = param[@"remarks"];
    dic[@"day"] = dayStr;
    dic[@"state"] = param[@"switchStatus"];
    cell.dic = dic;
    cell.row = indexPath.row;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZJClockSetViewController *vc = [[ZJClockSetViewController alloc] init];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSDictionary *param = (NSDictionary *)[clockArray objectAtIndex:indexPath.row];
    
    NSString *dayStr = @"";
    NSArray *weekArray = [param[@"week"] componentsSeparatedByString:@","];
    for(id object in weekArray)
    {
        NSInteger objValue = [object integerValue];
        if (objValue == 1) {
            dayStr = [dayStr stringByAppendingString:@"周一，"];
        }else if (objValue == 2)
        {
            dayStr = [dayStr stringByAppendingString:@"周二，"];
        }else if (objValue == 3)
        {
            dayStr = [dayStr stringByAppendingString:@"周三，"];
        }else if (objValue == 4)
        {
            dayStr = [dayStr stringByAppendingString:@"周四，"];
        }else if (objValue == 5)
        {
            dayStr = [dayStr stringByAppendingString:@"周五，"];
        }else if (objValue == 6)
        {
            dayStr = [dayStr stringByAppendingString:@"周六，"];
        }else if (objValue == 7)
        {
            dayStr = [dayStr stringByAppendingString:@"周日，"];
        }
    }
    
    if (dayStr.length > 2) {
        dayStr = [dayStr substringToIndex:dayStr.length - 1];
    }
  
    dic[@"time"] = param[@"clockStr"];
    dic[@"remark"] = param[@"remarks"];
    dic[@"day"] = dayStr;
    vc.dic = dic;
    vc.param = param;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ZJClockTableViewCellDelegate
/**
 * 打开闹钟
 */
- (void)openAlarmClock:(NSUInteger)row withState:(int)state
{
    NSDictionary *dic = (NSDictionary *)[clockArray objectAtIndex:row];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = [userDefault objectForKey:@"userid"];
    
    param[@"deviceId"] = self.device_id;
    
    param[@"clockId"] = dic[@"clockId"];
    
//    param[@"week"] = dic[@"week"];
    
//    param[@"hour"] = dic[@"hour"];
    
//    param[@"minute"] = dic[@"minute"];
    
    param[@"open"] = @(state);
    
//    param[@"remarks"] = dic[@"remarks"];
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];

    [self openAlarmClockRequest:param];
}

@end
