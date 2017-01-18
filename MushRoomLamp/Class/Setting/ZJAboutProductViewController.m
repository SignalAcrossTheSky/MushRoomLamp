//
//  ZJAboutProductViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 6/27/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJAboutProductViewController.h"
#import "Constant.h"
#import "ZJInterface.h"
#import "MBProgressHUD+NJ.h"

@interface ZJAboutProductViewController ()<ZJInterfaceDelegate>
/** 关于产品网络接口 */
@property (nonatomic,strong) ZJInterface *interfaceProductInfo;
/** 关于产品Label */
@property (nonatomic,strong) UILabel *contentLab;
@end

@implementation ZJAboutProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    
    [self getProductInfoRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 关于产品网络请求
 */
- (void)getProductInfoRequest
{
    [MBProgressHUD showMessage:@""];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
        
    param[@"typeId"] = @(1);
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    param[@"userId"] = @([[userDefault objectForKey:@"userid"] integerValue]);
    
    param[@"terminalId"] = @(1);
    
    param[@"sign"] = [ZJCommonFuction addLockFunction:param];
    
    self.interfaceProductInfo = [[ZJInterface alloc] initWithDelegate:self];
    
    [self.interfaceProductInfo interfaceWithType:INTERFACE_TYPE_ADBOUTPRODUCT param:param];
}

/**
 * 网络请求返回结果
 */
- (void)interface:(ZJInterface *)interface result:(NSDictionary *)result error:(NSError *)error
{
    [MBProgressHUD hideHUD];
    if (interface == self.interfaceProductInfo) {
        if([result[@"code"] isEqual:@(0)])
        {
            self.contentLab.text = [NSString stringWithFormat:@"     %@",result[@"data"][@"content"]];
            self.contentLab.numberOfLines = 0;
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.contentLab.text];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineSpacing:10];//调整行间距
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,self.contentLab.text.length)];
            self.contentLab.attributedText = attributedString;
            CGFloat height = [self getSpaceLabelHeight:self.contentLab.text withFont:self.contentLab.font withWidth:self.contentLab.width];
            self.contentLab.height = height;
        }else
        {
            [MBProgressHUD showError:@"获取信息失败"];
        }
    }
}

/**
 * 初始化View
 */
- (void)initView
{
    self.view.backgroundColor = DDRGBColor(237, 237, 237);
    [self.tabBarController.tabBar setHidden:YES];
    
    [self createTitleView];
    
    [self createContentView];
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
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x = 0;
    titleLabel.y = 37;
    titleLabel.width = MAINSCREEN.size.width;
    titleLabel.height = 17;
    titleLabel.text = @"关于产品";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
}

/**
 * 内容View
 */
- (void)createContentView
{
    UIView *view = [[UIView alloc] init];
    view.x = 0;
    view.y = 80;
    view.width = MAINSCREEN.size.width;
    view.height = 150;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UILabel *contentLab = [[UILabel alloc] init];
    contentLab.width = view.width - 20;
    contentLab.x = 10;
    contentLab.y = 5;
    contentLab.height = view.height;
    contentLab.font = [UIFont systemFontOfSize:16];
    contentLab.textColor = DDRGBColor(55, 55, 55);
    [view addSubview:contentLab];
    self.contentLab = contentLab;
}

/**
 * 返回上一页点击事件
 */
- (void)cancelClickAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 计算高度
 */
-(CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 10;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
                          };
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}

@end
