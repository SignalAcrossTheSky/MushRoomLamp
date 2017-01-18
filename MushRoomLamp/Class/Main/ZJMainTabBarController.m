//
//  ZJMainTabBarController.m
//  MushRoomLamp
//
//  Created by SongGang on 6/23/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJMainTabBarController.h"
#import "ZJHomeController.h"
#import "ZJAddEquipmentViewController.h"
#import "ZJSettingViewController.h"
#import "Constant.h"
#import "ZJAddEquipmentViewController.h"
#import "ZJEqsInfoViewController.h"

@interface ZJMainTabBarController ()

@property (nonatomic,strong) UIView *coverView;
@end

@implementation ZJMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTabBar];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"ISCOVER"] == nil) {
        [self createCoverTeach];
    }
    
  //  [self createTransparentBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *    创建TabBar的子Controller
 */
- (void)initTabBar
{
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    ZJHomeController *vc1 = [[ZJHomeController alloc] init];
    UINavigationController *nv1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    nv1.tabBarItem.image = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nv1.tabBarItem.selectedImage = [[UIImage imageNamed:@"white_home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nv1.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    ZJAddEquipmentViewController *vc2 = [[ZJAddEquipmentViewController alloc] init];
    UINavigationController *nv2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    nv2.tabBarItem.image = [[UIImage imageNamed:@"add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nv2.tabBarItem.selectedImage = [[UIImage imageNamed:@"white_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nv2.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
//    ZJSettingViewController *vc3 = [[ZJSettingViewController alloc] init];
//    UINavigationController *nv3 = [[UINavigationController alloc] initWithRootViewController:vc3];
//    nv3.tabBarItem.image = [[UIImage imageNamed:@"setting"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    nv3.tabBarItem.selectedImage = [[UIImage imageNamed:@"white_set"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    nv3.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    ZJEqsInfoViewController *vc3 = [[ZJEqsInfoViewController alloc] init];
    UINavigationController *nv3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    nv3.tabBarItem.image = [[UIImage imageNamed:@"setting"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nv3.tabBarItem.selectedImage = [[UIImage imageNamed:@"white_set"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nv3.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);

    self.tabBar.barTintColor = DDRGBColor(0, 0, 10);
//    self.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_bg"];
    self.viewControllers = @[nv1,nv2,nv3];
}

/**
 * 创建引导遮罩
 */
- (void)createCoverTeach
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAINSCREEN.size.width, MAINSCREEN.size.height)];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    self.coverView = view;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearCover)];
    [view addGestureRecognizer:tapGesture];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAINSCREEN.size.width, MAINSCREEN.size.height - 44)];
    topView.backgroundColor = DDRGBAColor(16,16,16, 0.9);
    [view addSubview:topView];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, MAINSCREEN.size.height - 44, MAINSCREEN.size.width/2 - 20, 44)];
    leftView.backgroundColor = DDRGBAColor(16,16,16, 0.9);
    [view addSubview:leftView];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(MAINSCREEN.size.width/2 + 20, MAINSCREEN.size.height - 44, MAINSCREEN.size.width/2 - 20, 44)];
    rightView.backgroundColor = DDRGBAColor(16,16,16, 0.9);
    [view addSubview:rightView];
    
    UIImageView *teachImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_home_guide"]];
    teachImage.width = 297;
    teachImage.height = 154;
    teachImage.x = (MAINSCREEN.size.width - teachImage.width)/2;
    teachImage.y = MAINSCREEN.size.height - 44 -teachImage.height;
    [view addSubview:teachImage];
}

/**
 * 创建添加设备透明按钮
 */
- (void) createTransparentBtn
{
    UIButton *button = [[UIButton alloc] init];
    button.x = MAINSCREEN.size.width/3;
    button.y = 0;
    button.width = MAINSCREEN.size.width/3;
    button.height = 44;
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(btnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:button];
}

/**
 * 删除引导遮罩
 */
- (void)clearCover
{
    [self.coverView removeFromSuperview];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"NO" forKey:@"ISCOVER"];
    [userDefault synchronize];
}

/**
 * 透明按钮的点击事件
 */
- (void)btnClickAction
{
    ZJAddEquipmentViewController *vc = [[ZJAddEquipmentViewController alloc] init];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nv animated:YES completion:^{

    }];
}

@end
