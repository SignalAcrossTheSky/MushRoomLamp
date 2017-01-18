//
//  ZJDayReportViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 11/8/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJDayReportViewController.h"

#import "ZJHumidityView.h"
#import "ZJAQIView.h"
#import "Constant.h"
#import "ZJInterface.h"
#import "MBProgressHUD+NJ.h"
#import "ZJTemView.h"
#import "ZJHumView.h"
#import "ZJNewAQIView.h"

@interface ZJDayReportViewController ()<UIScrollViewDelegate,ZJInterfaceDelegate>
{
    UIScrollView *reportScrView;
    UIPageControl *pageCtrl;
    NSInteger pageCount;
    NSMutableArray *nameArray;
}
@property (nonatomic,assign) CGFloat self_in_tem;
@property (nonatomic,assign) CGFloat self_out_tem;
@property (nonatomic,assign) CGFloat self_in_hum;
@property (nonatomic,assign) CGFloat self_out_hum;
@property (nonatomic,assign) CGFloat other_in_tem;
@property (nonatomic,assign) CGFloat other_out_tem;
@property (nonatomic,assign) CGFloat other_in_hum;
@property (nonatomic,assign) CGFloat other_out_hum;
@property (nonatomic,assign) CGFloat self_in_aqi;
@property (nonatomic,assign) CGFloat self_out_aqi;
@property (nonatomic,assign) CGFloat other_in_aqi;
@property (nonatomic,assign) CGFloat other_out_aqi;
/** 滚动视图 */
@property (nonatomic,strong) UIScrollView *scrollView;
/** pageControl */
@property (nonatomic,strong) UIPageControl *pageControl;
/** 我家情况标签，用来提供相对坐标 */
@property (nonatomic,strong) UILabel *myLabel;
/** 环境日报接口 */
@property (nonatomic,strong) ZJInterface *interfaceReport;
/** 蘑菇灯的名字 */
@property (nonatomic,strong) UILabel *mushRoomLab;

@end

@implementation ZJDayReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createNavigationBar];
    
    [self environmentReportRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/** 
 * 环境日报网络请求
 */
- (void)environmentReportRequest
{
    [MBProgressHUD showMessage:@""];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];;
    
    self.interfaceReport = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceReport interfaceWithType:INTERFACE_TYPE_ENVIRONMENTREPORT param:param];
}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (interface == self.interfaceReport) {
        if([result[@"code"] isEqual:@(0)])
        {
            pageCount = [result[@"data"][@"dailyContentList"] count];
            if (nameArray == nil) {
                nameArray = [NSMutableArray array];
            }
            [self createScrollView:result[@"data"][@"dailyContentList"]];
        }else
        {
            
        }
    }
}

/**
 * 创建滚动视图 和 pageControl
 */
- (void)createScrollView:(NSArray *)dailyContentList
{
    self.view.backgroundColor = DDRGBColor(208, 219, 224);

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.x = 0;
    scrollView.y = 64;
    scrollView.width = MAINSCREEN.size.width;
    scrollView.height = MAINSCREEN.size.height;
    scrollView.contentSize = CGSizeMake(MAINSCREEN.size.width * pageCount ,667 );
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    [scrollView setDelegate:self];
    scrollView.showsHorizontalScrollIndicator = NO;
    
    scrollView.backgroundColor = DDRGBColor(208, 219, 224);
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    for (int i = 0; i < pageCount; i ++) {
        NSDictionary *dic = [dailyContentList objectAtIndex:i];
        if(i == 0)
        {
            self.mushRoomLab.text = [NSString stringWithFormat:@"蘑菇日报-%@",dic[@"deviceName"]];
        }
        [nameArray addObject:dic[@"deviceName"]];
        [self.scrollView addSubview:[self createOnePageDailyReportWithDic:dic Index:i]];
    }
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(0, self.view.height - 40, self.view.width, 20);
    pageControl.numberOfPages = pageCount;
    pageControl.currentPage = 0;
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    pageControl.pageIndicatorTintColor = DDRGBColor(184, 204, 201);
    pageControl.currentPageIndicatorTintColor = DDRGBColor(41, 207, 177);
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
}

/**
 * 创建单页日报内容
 */
- (UIView *) createOnePageDailyReportWithDic:(NSDictionary *)dic Index:(int) index
{
    UIView *view = [[UIView alloc] init];
    view.x = 0 + index * MAINSCREEN.size.width;
    view.y = 0;
    view.width = MAINSCREEN.size.width;
    view.height = MAINSCREEN.size.height;
    [self.scrollView addSubview:view];
    
    UIView *selfSituation = [self createHalfViewWithTitle:@"我家情况" withDic:dic];
    UIView *areaSituation = [self createHalfViewWithTitle:@"同城平均" withDic:dic];
    [view addSubview:selfSituation];
    [view addSubview:areaSituation];
    
    UILabel *tipLab = [[UILabel alloc] init];
    tipLab.text = @"提示：日报数据为过去24小时的平均值";
    tipLab.textColor = DDRGBColor(102, 102,102);
    tipLab.font = [UIFont systemFontOfSize:12];
    tipLab.x = 0;
    tipLab.y = selfSituation.bottom + 20;
    tipLab.width = view.width;
    tipLab.height = 12;
    tipLab.textAlignment = NSTextAlignmentCenter;
    [view addSubview:tipLab];
    return view;
}

- (UIView *)createHalfViewWithTitle:(NSString *)strTitle withDic:(NSDictionary *)dic
{
    NSString *sideStr;
    NSInteger temValue;
    NSInteger humValue;
    NSInteger aqiValue;
    UIView *view = [[UIView alloc] init];
    if ([strTitle isEqualToString:@"我家情况"]) {
        view.x = 12;
        sideStr = @"left";
        temValue = [dic[@"deviceDaily"][@"temperature"] integerValue];
        humValue = [dic[@"deviceDaily"][@"humidity"] integerValue];
        aqiValue = [dic[@"deviceDaily"][@"airQuality"] integerValue];
    }else if([strTitle isEqualToString:@"同城平均"])
    {
        view.x = (MAINSCREEN.size.width - 36)/2 + 24;
        sideStr = @"right";
        temValue = [dic[@"cityDeviceDaily"][@"temperature"] integerValue];
        humValue = [dic[@"cityDeviceDaily"][@"humidity"] integerValue];
        aqiValue = [dic[@"cityDeviceDaily"][@"airQuality"] integerValue];
    }
   
    view.y = 15;
    view.width = (MAINSCREEN.size.width - 36)/2;
    view.height = 500;
    view.backgroundColor = DDRGBColor(61, 64, 77);
    view.layer.cornerRadius = 8;
    [self.scrollView addSubview:view];
    
    //title
    UILabel *titleLab  = [[UILabel alloc] init];
    titleLab.text = strTitle;
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont systemFontOfSize:16];
    titleLab.textColor = DDRGBColor(115, 191, 230);
    titleLab.x = 0;
    titleLab.y = 15;
    titleLab.width = view.width;
    titleLab.height = 16;
    [view addSubview:titleLab];
    
    //分割线
    UILabel *lineLab = [[UILabel alloc] init];
    lineLab.x = 10;
    lineLab.y = titleLab.bottom + 15;
    lineLab.width = view.width - 20;
    lineLab.height = 1;
    lineLab.backgroundColor = DDRGBColor(204, 204, 204);
    [view addSubview:lineLab];
    
    //温度
    UILabel *temLab = [[UILabel alloc] init];
    temLab.x = 0;
    temLab.y = lineLab.bottom + 30;
    temLab.width = view.width;
    temLab.height = 15;
    temLab.text = @"温度";
    temLab.textAlignment = NSTextAlignmentCenter;
    temLab.textColor = DDRGBColor(115, 191, 230);
    temLab.font = [UIFont systemFontOfSize:15];
    [view addSubview:temLab];
    
    ZJTemView *tv = [[ZJTemView alloc] initWithFrame:CGRectMake(30, temLab.bottom + 15, view.width - 60, 55) withInTem:temValue withSide:sideStr];
    [view addSubview:tv];
    
    //湿度
    UILabel *humLab = [[UILabel alloc] init];
    humLab.x = 0;
    humLab.y = tv.bottom + 30;
    humLab.width = view.width;
    humLab.height = 15;
    humLab.text = @"湿度";
    humLab.textAlignment = NSTextAlignmentCenter;
    humLab.textColor = DDRGBColor(115, 191, 230);
    humLab.font = [UIFont systemFontOfSize:15];
    [view addSubview:humLab];

    ZJHumView *hv = [[ZJHumView alloc] initWithFrame:CGRectMake(30, humLab.bottom + 15, view.width - 60, 55) withHum:humValue withSide:sideStr];
    [view addSubview:hv];
    
    //空气质量
    UILabel *aqiLab = [[UILabel alloc] init];
    aqiLab.x = 0;
    aqiLab.y = hv.bottom + 40;
    aqiLab.width = view.width;
    aqiLab.height = 15;
    aqiLab.text = @"空气质量";
    aqiLab.textAlignment = NSTextAlignmentCenter;
    aqiLab.textColor = DDRGBColor(115, 191, 230);
    aqiLab.font = [UIFont systemFontOfSize:15];
    [view addSubview:aqiLab];
    
    ZJNewAQIView *nav = [[ZJNewAQIView alloc] initWithFrame:CGRectMake(0, aqiLab.bottom + 10, view.width ,100) withAQI:aqiValue];
    [view addSubview:nav];
    
    return view;
}

/**
 * 创建navigation bar
 */
- (void)createNavigationBar
{
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeClickAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:closeBtn];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 37;
    titleLabel.width = MAINSCREEN.size.width;
    titleLabel.height = 17;
    titleLabel.text = @"蘑菇日报";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    self.mushRoomLab = titleLabel;
}

/**
 * 关闭日报
 */
- (void)closeClickAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma  mark 各种委托方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / MAINSCREEN.size.width;
    self.pageControl.currentPage = page;
    self.mushRoomLab.text = [NSString stringWithFormat:@"蘑菇日报-%@",[nameArray objectAtIndex:page]];
}



- (void)changePage:(id)sender {
    NSInteger page = self.pageControl.currentPage;
    self.mushRoomLab.text = [NSString stringWithFormat:@"蘑菇日报-%@",[nameArray objectAtIndex:page]];
    [self.scrollView setContentOffset:CGPointMake(MAINSCREEN.size.width * page, 0)];
}
@end
