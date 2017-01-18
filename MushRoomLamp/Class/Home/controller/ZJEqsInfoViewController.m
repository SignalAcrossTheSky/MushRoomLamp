//
//  ZJEqsInfoViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 6/24/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJEqsInfoViewController.h"
#import "Constant.h"
#import "SBJson.h"
#import "ZJLampSettingViewController.h"
#import "ZJInterface.h"
#import "MBProgressHUD+NJ.h"
#import <CoreLocation/CoreLocation.h>
#import "ZJHomeController.h"

@interface ZJEqsInfoViewController ()<CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,NSURLSessionTaskDelegate,CLLocationManagerDelegate,ZJInterfaceDelegate,ZJLampSettingViewControllerDelegate>{
    
    CLLocationManager *locationmanager;
    /** tableView的datasource */
    NSMutableArray *datasource;
    /** 被删除的设备的ID */
    NSInteger deletedDeviceID;
}
/** TableView */
@property (nonatomic,strong) UITableView *tableView;
/** 定义定位属性 */
@property (nonatomic,retain) CLLocationManager *locationManager;
/** 当前city */
@property (nonatomic,copy) NSString *cityName;
/** 获取设备列表网络接口 */
@property (nonatomic,strong) ZJInterface *interfaceGetDeviceList;
/** 删除设备网络接口 */
@property (nonatomic,strong) ZJInterface *interfaceDeleteDevice;
@end

@implementation ZJEqsInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

/**
 * 生命周期方法
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:NO];
    [self getDeviceListRequest];
}

/**
 * 获取设备列表网络请求
 */
- (void)getDeviceListRequest
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = [userDefault objectForKey:@"userid"];
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceGetDeviceList = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceGetDeviceList interfaceWithType:INTERFACE_TYPE_DEVICELIST param:param];
    
    [MBProgressHUD showMessage:@"数据加载中"];
}

/**
 * 删除设备网络请求
 */
- (void)deleteDeviceRequest:(NSString* )deviceID
{
    [MBProgressHUD showMessage:@"删除中..."];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = [userDefault objectForKey:@"userid"];

    param[@"deviceId"] = deviceID;
    
    param[@"terminalId"] = @(1);
    
    deletedDeviceID = [deviceID integerValue];
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceDeleteDevice = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceDeleteDevice interfaceWithType:INTERFACE_TYPE_DELETELAMP param:param];
}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (interface == self.interfaceGetDeviceList) {
        if([result[@"code"] isEqual:@(0)])
        {
            if (datasource == nil) {
                datasource = [NSMutableArray new];
            }
            [datasource removeAllObjects];
            
//            NSArray *array = (NSArray *)result[@"data"][@"devices"];
//            if (array.count != 0) {
            [datasource addObjectsFromArray:result[@"data"][@"devices"]];
//            }
            [self.tableView reloadData];
        }else
        {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"操作异常"];
        }
    }else if (interface == self.interfaceDeleteDevice)
    {
        if ([result[@"code"] isEqual:@(0)]) {
            [MBProgressHUD showSuccess:@"删除成功"];
            [[NSUserDefaults standardUserDefaults] setInteger:deletedDeviceID forKey:@"DELETEDDEVICEID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self getDeviceListRequest];
        }else
        {
            [MBProgressHUD showError:@"删除失败"];
        }
    }
}

/**
 * 初始化View
 */
- (void)initView
{
    self.view.backgroundColor = DDRGBColor(237, 237, 237);
    [self.navigationController.navigationBar setHidden:YES];
//    [self.tabBarController.tabBar setHidden:YES];
    [self createTitleView];
//    [self createTemView];
    [self createTableView];
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
    
    //X按钮
//    UIButton *closeBtn = [[UIButton alloc] init];
//    closeBtn.x = 11;
//    closeBtn.y = 23;
//    closeBtn.width = 40;
//    closeBtn.height = 40;
//    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
//    [closeBtn addTarget:self action:@selector(cancelBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:closeBtn];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 37;
    titleLabel.width = MAINSCREEN.size.width;
    titleLabel.height = 17;
    titleLabel.text = @"全部设备";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
}

/**
 * 创建天气View
 */
- (void)createTemView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 73;
    view.width = MAINSCREEN.size.width;
    view.height = 58;
    [self.view addSubview:view];
  
    //云的标志
    UIImageView *cloudImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud"]];
    cloudImage.x = 18;
    cloudImage.y = 10;
    cloudImage.width = 33;
    cloudImage.height = 29;
    [view addSubview:cloudImage];
    
    //竖着的分割线
    UILabel *lineLabel = [[UILabel alloc] init];
    lineLabel.x = cloudImage.right + 10;
    lineLabel.y = 10;
    lineLabel.width = 2;
    lineLabel.height = 29;
    lineLabel.layer.cornerRadius = lineLabel.width/2;
    [lineLabel.layer setMasksToBounds:YES];
    lineLabel.backgroundColor = DDRGBColor(180, 180, 180);
    [view addSubview:lineLabel];
    
    //天气情况
    UILabel *temLabel = [[UILabel alloc] init];
    temLabel.x = lineLabel.right + 10;
    temLabel.y = 17;
    temLabel.height = 17;
    temLabel.text = @"多云转晴";
    if (MAINSCREEN.size.width == 320) {
        temLabel.font = [UIFont systemFontOfSize:15];
        temLabel.width = 60;
    }else
    {
        temLabel.font = [UIFont systemFontOfSize:17];
        temLabel.width = 70;
    }
    [view addSubview:temLabel];
    
    UILabel *tempLabel2 = [[UILabel alloc] init];
    tempLabel2.x = temLabel.right;
    tempLabel2.y = temLabel.y;
    tempLabel2.width = 100;
    tempLabel2.height = 17;
    tempLabel2.text = @"29℃~36℃";
    if (MAINSCREEN.size.width == 320) {
        tempLabel2.font = [UIFont systemFontOfSize:15];
        
    }else
    {
        tempLabel2.font = [UIFont systemFontOfSize:17];
    }
    tempLabel2.textColor = DDRGBColor(0, 244, 207);
    [view addSubview:tempLabel2];
    
    //轻度污染76
    UIButton *pollutionBtn = [[UIButton alloc] init];
    pollutionBtn.width = 83;
    pollutionBtn.height = 26;
    pollutionBtn.y = cloudImage.y + 3;
    pollutionBtn.x = MAINSCREEN.size.width - 20 - pollutionBtn.width;
    pollutionBtn.layer.borderColor = DDRGBColor(0, 244, 207).CGColor;
    pollutionBtn.layer.cornerRadius = pollutionBtn.height * 0.2;
    pollutionBtn.layer.borderWidth = 2;
    [pollutionBtn setTitle:@"轻度污染76" forState:UIControlStateNormal];
    [pollutionBtn setTitleColor:DDRGBColor(0, 244, 207) forState:UIControlStateNormal];
    pollutionBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [view addSubview:pollutionBtn];
}

/**
 * 创建TableView
 */
- (void)createTableView
{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.x = 0;
    tableView.y = 73;
    tableView.width = MAINSCREEN.size.width;
    tableView.height = MAINSCREEN.size.height - tableView.y - 40;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = DDRGBColor(237, 237, 237);
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma TableView DataSource
/**
 * tableView的row
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return datasource.count;
}

/**
 * tableView的定制cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ZJLampInfo *linfo = [[ZJLampInfo alloc] initWithDict:[datasource objectAtIndex:indexPath.row]];
    UIView *cellView = [self createCellViewWith:linfo withIndexPath:indexPath];
    cell.backgroundColor = DDRGBColor(237, 237, 237);
    [cell addSubview:cellView];
    
    return  cell;
}

/**
 * tableView cell的点击事件
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nc = (UINavigationController *)[self.tabBarController.viewControllers firstObject];
    ZJHomeController *hv = (ZJHomeController *)[[nc viewControllers] firstObject];
    ZJLampInfo *linfo = [[ZJLampInfo alloc] initWithDict:[datasource objectAtIndex:indexPath.row]];
    [hv chooseLamp:linfo];
    self.tabBarController.selectedIndex = 0;
//    if ([_delegate respondsToSelector:@selector(chooseLamp:)]) {
//        ZJLampInfo *linfo = [[ZJLampInfo alloc] initWithDict:[datasource objectAtIndex:indexPath.row]];
//        [_delegate chooseLamp:linfo];
//    }

}

/**
 * 定制tableView的cell
 */
- (UIView *)createCellViewWith:(ZJLampInfo *)lampInfo withIndexPath:(NSIndexPath *)indexPath;
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    view.x = 0;
    view.y = 0;
    view.width = MAINSCREEN.size.width;
    view.height = 70;
    
    //蘑菇灯图标
    UIImageView *lampImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lamp"]];
    lampImage.x = 20;
    lampImage.y = 10;
    lampImage.width = 60;
    lampImage.height = 56;
    [view addSubview:lampImage];
    
    //title name
    UILabel *name = [[UILabel alloc] init];
    name.x = lampImage.right + 10;
    name.y = 20;
    name.width = 150;
    name.height = 17;
    name.text = lampInfo.name;
    name.font = [UIFont systemFontOfSize:17];
    [view addSubview:name];
    
    //型号
    UILabel *typeLabel = [[UILabel alloc] init];
    typeLabel.x = name.x;
    typeLabel.y = name.bottom + 5;
    typeLabel.width = 200;
    typeLabel.height = 12;
    typeLabel.text = lampInfo.model;
    typeLabel.font = [UIFont systemFontOfSize:12];
    typeLabel.textColor = DDRGBColor(200, 200, 200);
    [view addSubview:typeLabel];
  
    //设置按钮
    UIButton *lampSetBtn = [[UIButton alloc] init];
    [lampSetBtn setImage:[UIImage imageNamed:@"lampset"] forState:UIControlStateNormal];
    lampSetBtn.width = 70;
    lampSetBtn.height = 70;
    lampSetBtn.x = view.width - lampSetBtn.width;
    lampSetBtn.y = 0;
    lampSetBtn.tag = indexPath.row;
    [lampSetBtn addTarget:self action:@selector(lampSetBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:lampSetBtn];
    
    //底部灰色分割线
    UILabel *line = [[UILabel alloc] init];
    line.x = 20;
    line.y = 70;
    line.width = view.width - 20;
    line.height = 1;
    line.backgroundColor = DDRGBColor(233, 233, 233);
    [view addSubview:line];
    return view;
}

/**
 * row的高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

/**
 * 头的高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 74;
}

/**
 * 定制headView
 */
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home"]];
    image.x = 30;
    image.y = 20;
    image.width = 25;
    image.height = 25;
    [view addSubview:image];
    
    UILabel *title = [[UILabel alloc] init];
    title.x = image.right + 20;
    title.y = 0;
    title.width = 150;
    title.height = 64;
    title.text = @"蘑菇灯列表";
    title.font = [UIFont systemFontOfSize:17];
    [view addSubview:title];
    
    UILabel *graylabel = [[UILabel alloc] init];
    graylabel.x = 0;
    graylabel.y = 64;
    graylabel.width = MAINSCREEN.size.width;
    graylabel.height = 10;
    graylabel.backgroundColor = DDRGBColor(237,237,237);
    [view addSubview:graylabel];
    return view;
}

/**
 * 创建设置和删除按钮
 */
-(NSArray * )tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        ZJLampInfo *lampInfo = [[ZJLampInfo alloc] initWithDict:[datasource objectAtIndex:indexPath.row]];
        [self createTipView:@"确定删除该设备" withDeviceId:lampInfo.device_id];
    }];

    deleteRowAction.backgroundColor = [UIColor grayColor];//可以定义RowAction的颜色
    return @[deleteRowAction];//最后返回这俩个RowAction 的数组
}

/**
 * 左上角X按钮的点击事件
 */
- (void)cancelBtnClickAction
{
    if ([_delegate respondsToSelector:@selector(returnHome)]) {
        [_delegate returnHome];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 代理方法
 */
- (void)changeName:(NSString *)newName withRow:(NSInteger)row
{
    NSDictionary *param = [datasource objectAtIndex:row];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:param];
    dic[@"name"] = newName;
    [dic setValue:newName forKey:@"name"];
    [datasource replaceObjectAtIndex:row withObject:dic];
    [self.tableView reloadData];
}

/**
 * 创建提示框
 */
- (void)createTipView:(NSString *)message withDeviceId:(NSString *)deviceId
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self deleteDeviceRequest:deviceId];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];

    [alertController addAction:OKAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma mark 点击事件
- (void) lampSetBtnClickAction:(UIButton *)sender
{
    ZJLampSettingViewController *vc = [[ZJLampSettingViewController alloc] init];
    ZJLampInfo *lampInfo = [[ZJLampInfo alloc] initWithDict:[datasource objectAtIndex:sender.tag]];
    vc.deviceName = lampInfo.name;
    vc.autoID = lampInfo.autoID;
    vc.device_id = lampInfo.device_id;
    vc.row = sender.tag;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
