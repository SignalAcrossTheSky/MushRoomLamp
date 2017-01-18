//
//  ZJLoginAndRegisterViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 11/28/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJLoginAndRegisterViewController.h"
#import "Constant.h"
#import "ZJLoginViewController.h"
#import "ZJRegisterViewController.h"
@interface ZJLoginAndRegisterViewController ()

@end

@implementation ZJLoginAndRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLoginAndRegistView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 创建登录和注册页
 */
- (void)createLoginAndRegistView
{
    [self.navigationController.navigationBar setHidden:YES];
    self.view.backgroundColor = DDRGBAColor(36, 38, 51, 1);
    
    //图片
    UIImageView *imageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_first_mashroom"]];
    imageIcon.width = 145;
    imageIcon.height = 147;
    imageIcon.x = (self.view.width - imageIcon.width)/2;
    imageIcon.y = 140;
    [self.view addSubview:imageIcon];

    //注册按钮
    UIButton *registBtn = [[UIButton alloc] init];
    registBtn.x = 50;
    registBtn.y = imageIcon.bottom + 50;
    registBtn.width = self.view.width - 100;
    registBtn.height = 40;
    registBtn.layer.cornerRadius = 8;
    registBtn.layer.borderWidth = 1;
    registBtn.layer.borderColor = DDRGBColor(0, 240, 200).CGColor;
    [registBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registBtn setTitleColor:DDRGBColor(0, 240, 200) forState:UIControlStateNormal];
    registBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [registBtn addTarget:self action:@selector(registBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registBtn];
    
    //登录按钮
    UIButton *loginBtn = [[UIButton alloc] init];
    loginBtn.x = 50;
    loginBtn.y = registBtn.bottom + 20;
    loginBtn.width = self.view.width - 100;
    loginBtn.height = 40;
    loginBtn.layer.cornerRadius = 8;
    loginBtn.layer.borderWidth = 1;
    loginBtn.layer.borderColor = DDRGBColor(0, 240, 200).CGColor;
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:DDRGBColor(0, 240, 200) forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [loginBtn addTarget:self action:@selector(loginBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];

}

/**
 * 登录按钮点击事件
 */
- (void)loginBtnClickAction
{
    ZJLoginViewController *loginVC = [[ZJLoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

/**
 * 注册按钮点击事件
 */
- (void)registBtnClickAction
{
    ZJRegisterViewController *registVC = [[ZJRegisterViewController alloc] init];
    [self.navigationController pushViewController:registVC animated:YES];
}

@end
