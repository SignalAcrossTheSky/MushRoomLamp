//
//  ZJAboutUsViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 6/27/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJAboutUsViewController.h"
#import "Constant.h"

@interface ZJAboutUsViewController ()

@end

@implementation ZJAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    titleLabel.text = @"关于我们";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
}

/**
 * 创建内容View
 */
- (void)createContentView
{
    NSArray *iconArray = [[NSArray alloc] initWithObjects:@"location",@"phone",@"post",nil];
    NSArray *nameArray = [[NSArray alloc] initWithObjects:@"杭州市拱墅区矩阵国际中心4-405室",@"consult@masterzhijia.com",@"310000",nil];
    for (int i = 0 ;i < 3; i ++) {
        UIView *view = [[UIView alloc] init];
        view.x = 0;
        view.y = 80 + 57 * i;
        view.width = MAINSCREEN.size.width;
        view.height = 56;
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        
        //图标
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[iconArray objectAtIndex:i]]];
        icon.x = 20;
        icon.y = 19;
        icon.width = 16;
        icon.height = 18;
        [view addSubview:icon];
        
        //name
        UILabel *name = [[UILabel alloc] init];
        name.x = icon.right + 20;
        name.y = 0;
        name.width = view.width - name.x;
        name.height = view.height;
        name.text = [nameArray objectAtIndex:i];
        name.textColor = DDRGBColor(100, 100, 100);
        name.font = [UIFont systemFontOfSize:14];
        [view addSubview:name];
    }
    
    //经营范围
    UILabel *title = [[UILabel alloc] init];
    title.text = @"经营范围:";
    title.textColor = DDRGBColor(100 ,100 , 100);
    title.font = [UIFont systemFontOfSize:14];
    title.x = 20;
    title.y = 271;
    title.width = MAINSCREEN.size.width - 40;
    title.height = 14;
//    [self.view addSubview:title];
    
    UILabel *content = [[UILabel alloc] init];
    content.x = 20;
    content.y = title.bottom + 10;
    content.width = MAINSCREEN.size.width - 40;
    content.text = @"计算机硬件、计算机信息技术、工业自动化技术、电子产品、通信技术、多媒体技术、教育软件、新能源技术的技术开发、技术服务、技术咨询";
    content.numberOfLines = 0;
    content.font = [UIFont systemFontOfSize:14];
    content.textColor = DDRGBColor(100, 100, 100);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,content.text.length)];
    content.attributedText = attributedString;
    CGFloat height = [self getSpaceLabelHeight:content.text withFont:content.font withWidth:content.width];
    content.height = height;
//    [self.view addSubview:content];

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
