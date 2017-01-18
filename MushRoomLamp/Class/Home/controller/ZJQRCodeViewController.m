//
//  ZJQRCodeViewController.m
//  MushRoomLamp
//
//  Created by SongGang on 7/13/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJQRCodeViewController.h"
#import "Constant.h"

@interface ZJQRCodeViewController ()

@end

@implementation ZJQRCodeViewController

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
- (void) initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createTitleView];
    
    [self createQRCodeView];
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
    titleLabel.text = @"二维码";
    titleLabel.textColor = DDRGBColor(0, 244, 207);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
}

/**
 * 返回按钮点击事件
 */
- (void) cancelClickAction:(UIButton *)sender
{
    sender.enabled = NO;
    [self.navigationController popViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

/**
 * 创建二维码View
 */
- (void) createQRCodeView
{
   
    UIImageView *imageview = [[UIImageView alloc] init];
    imageview.x = (MAINSCREEN.size.width - 215)/2;
    imageview.y = (MAINSCREEN.size.height - 215)/2;
    imageview.width = 215;
    imageview.height = 215;
    [self.view addSubview:imageview];
    
    // 1.实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2.恢复滤镜的默认属性 (因为滤镜有可能保存上一次的属性)
    [filter setDefaults];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userID = [userDefault objectForKey:@"userid"];
    
    NSString *str = [NSString stringWithFormat:@"%@///////////////////%@",userID,self.deviceID];

    // 3.将字符串转换成NSdata
    NSData *data  = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    // 4.通过KVO设置滤镜, 传入data, 将来滤镜就知道要通过传入的数据生成二维码
    [filter setValue:data forKey:@"inputMessage"];
    
    // 5.生成二维码
    CIImage *outputImage = [filter outputImage];
    
    imageview.image = [self excludeFuzzyImageFromCIImage:outputImage size:215];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.x = 0;
    tipLabel.y = imageview.bottom + 10;
    tipLabel.width = MAINSCREEN.size.width;
    tipLabel.height = 60;
    tipLabel.textColor = DDRGBColor(88, 88, 88);
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.text = @"其他手机安装蘑菇管家后，\n扫描此二维码可以共享设备";
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.numberOfLines = 0;
    [self.view addSubview:tipLabel];
}

/**
 * 调节二维码清晰度
 */
- (UIImage *)excludeFuzzyImageFromCIImage: (CIImage *)image size: (CGFloat)size

{
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size / CGRectGetWidth(extent), size / CGRectGetHeight(extent));
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    //创建灰度色调空间
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext * context = [CIContext contextWithOptions: nil];
    
    CGImageRef bitmapImage = [context createCGImage: image fromRect: extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    CGColorSpaceRelease(colorSpace);
    
    return [UIImage imageWithCGImage: scaledImage];
    
}


@end
