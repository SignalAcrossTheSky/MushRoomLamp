//
//  ZJBloodPressView.m
//  MushRoomLamp
//
//  Created by SongGang on 9/18/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJBloodPressView.h"
#import "Constant.h"
#import "ZJCommonFuction.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD+NJ.h"

@interface ZJBloodPressView()

@property (nonatomic,strong) UIActivityIndicatorView*  activity;
@property (nonatomic,strong) UIView *ecgView;
@property (nonatomic,strong) UIImageView *whiteLightLine;
/** 开始检测标签 */
@property (nonatomic,strong) UILabel *startLab;
/** 结果标签 */
@property (nonatomic,strong) UILabel *resultLab;
/** 结果按钮 */
@property (nonatomic,strong) UIButton *resultBtn;
@end
@implementation ZJBloodPressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
        
//       [self createThread];
    }
    return self;
}

/**
 *  初始化View
 */
- (void)createView
{
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    closeBtn.width = 44;
    closeBtn.height = 44;
    closeBtn.x = self.width - 54;
    closeBtn.y = 40;
    [self addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(closeBloodPressView) forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundColor = [UIColor blackColor];
    UIView *ECGView = [[UIView alloc] initWithFrame:CGRectMake(0 - MAINSCREEN.size.width , 130,MAINSCREEN.size.width * 2,78)];
    for (int i = 0; i < 2; i++) {
        UIImageView *ecgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ecg.png"]];
        ecgImg.frame = CGRectMake(i * self.width, 50, self.width,78);
        [ECGView addSubview:ecgImg];
    }
    [self addSubview:ECGView];
    self.ecgView = ECGView;
    [self createAnimationInView:ECGView startPoint:CGPointMake(0, ECGView.y) endPoint:CGPointMake(self.width, ECGView.y) withImage:1];
    
    UIImageView *fingerprintImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fingerPrint"]];
    fingerprintImg.width = 149;
    fingerprintImg.height = 228;
    fingerprintImg.x = (self.width - fingerprintImg.width)/2;
    fingerprintImg.y = 80;
    [self addSubview:fingerprintImg];
    
    UIImageView *whiteLightLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLightLine"]];
    whiteLightLine.width = 112;
    whiteLightLine.height = 13;
    whiteLightLine.y = 10;
    whiteLightLine.x = (fingerprintImg.width - whiteLightLine.width)/2;
    [fingerprintImg addSubview:whiteLightLine];
    self.whiteLightLine = whiteLightLine;
    [self createAnimationInView:whiteLightLine startPoint:whiteLightLine.layer.position endPoint:CGPointMake(whiteLightLine.layer.position.x,208) withImage:0];
    
    //等待
    UILabel *waitLab = [[UILabel alloc] init];
    waitLab.width = self.width;
    waitLab.height = 18;
    waitLab.x = 0;
    waitLab.y = 318 + 40;
    waitLab.textAlignment = NSTextAlignmentCenter;
    waitLab.text = @"开始血压检测，约等待30秒";
    waitLab.textColor = [UIColor whiteColor];
    waitLab.font = [UIFont systemFontOfSize:18];
    [self addSubview:waitLab];
    self.startLab = waitLab;

    //结果
    UILabel *numLab = [[UILabel alloc] init];
    numLab.width = self.width;
    numLab.height = 28;
    numLab.x = 0;
    numLab.y = 308 + 20;
    numLab.font = [UIFont fontWithName:@"DigifaceWide" size:34];
    numLab.textColor = [UIColor whiteColor];
    numLab.textAlignment = NSTextAlignmentCenter;
    numLab.text = @"--";
    [self addSubview:numLab];
    self.resultLab = numLab;
    
    UIButton *stateBtn = [[UIButton alloc] init];
    [stateBtn setTitle:@"检测失败" forState:UIControlStateNormal];
    [stateBtn setTitleColor:DDRGBAColor(0, 244, 207, 0.7) forState:UIControlStateNormal];
    CGSize size = [ZJCommonFuction getSpaceLabelHeight:stateBtn.titleLabel.text withFont:stateBtn.titleLabel.font withWidth:9999];
    stateBtn.width = size.width + 50;
    stateBtn.height = size.height;
    stateBtn.x = (MAINSCREEN.size.width - stateBtn.width)/2;
    stateBtn.y = numLab.bottom + 30;
    stateBtn.layer.borderColor = DDRGBAColor(0, 244, 207, 1).CGColor;
    stateBtn.layer.borderWidth = 0.5;
    stateBtn.layer.cornerRadius = stateBtn.height * 0.2;
    [self addSubview:stateBtn];
    self.resultBtn = stateBtn;
}

/**
 * 创建定时刷新线程
 */
- (void)createThread

{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        
        [self loopMethod];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
        });
        
    });
}

/**
 * 定时刷新
 */
- (void)loopMethod

{
    NSTimer *timer = [NSTimer timerWithTimeInterval:4 target:self selector:@selector(ecgEvent) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

/**
 *  心电图触发事件
 */
- (void) ecgEvent
{
    self.ecgView.x = 0 - MAINSCREEN.size.width;
    self.whiteLightLine.y = 10;
    
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:4.0f];
    
    UIView.animationRepeatCount =HUGE_VALF;
    
    self.ecgView.x = 0;
    self.whiteLightLine.y = 208;
    
    [UIView commitAnimations];
}


- (void)createAnimationInView:(UIView *)view
                   startPoint:(CGPoint) sPoint
                     endPoint:(CGPoint) ePoint
                    withImage:(NSInteger )tag
{
    /* 移动 */
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // 动画选项的设定
    animation.duration = 4; // 持续时间
    animation.repeatCount = HUGE_VALF; // 重复次数
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    // 起始帧和终了帧的设定
    animation.fromValue = [NSValue valueWithCGPoint:sPoint]; // 起始帧
    animation.toValue = [NSValue valueWithCGPoint:ePoint]; // 终了帧
    
    if (tag == 0) {
        animation.autoreverses = YES;
    }
   
    // 添加动画
    [view.layer addAnimation:animation forKey:@"move-layer"];
}

- (void)closeBloodPressView
{
//    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(closeBloodPressView)]) {
        [self.delegate closeBloodPressView];
    }
}

/**
 * 设置开始状态
 */
- (void)setStartState
{
    [self.startLab setHidden:NO];
    [self.resultLab setHidden:YES];
    [self.resultBtn setHidden:YES];
    self.startLab.text = @"开始血压检测，约等待30秒";
    if (self.ecgView.layer.speed == 1 && self.whiteLightLine.layer.speed == 1) {
        return;
    }else{
        [self animationContinueInView:self.ecgView];
        [self animationContinueInView:self.whiteLightLine];
    }
}

/**
 * 设置结果状态
 */
- (void)setResultStateWithDic:(NSDictionary *)dic
{
    [self.startLab setHidden:YES];
    [self.resultLab setHidden:NO];
    [self.resultBtn setHidden:NO];
    
    if ([dic[@"data"] isKindOfClass:[NSDictionary class]]) {
        self.resultLab.text = [NSString stringWithFormat:@"%@",dic[@"data"][@"heartRate"]];
        [self.resultBtn setTitle:[NSString stringWithFormat:@"血压%@",dic[@"data"][@"state"]] forState:UIControlStateNormal];
    }else{
        NSDictionary *param = [ZJCommonFuction dictionaryWithJsonString:dic[@"data"]];
        self.resultLab.text = [NSString stringWithFormat:@"%@",param[@"heartRate"]];
        [self.resultBtn setTitle:[NSString stringWithFormat:@"血压%@",param[@"state"]] forState:UIControlStateNormal];
    }
    
    if (self.ecgView.layer.speed == 0 && self.whiteLightLine.layer.speed == 0) {
        return;
    }else{
        [self animationPauseInView:self.ecgView];
        [self animationPauseInView:self.whiteLightLine];
    }
}

/**
 * 设置错误状态
 */
- (void)setErrorState
{
    [self.startLab setHidden:YES];
    [self.resultLab setHidden:YES];
    [self.resultBtn setHidden:NO];
    [self.resultBtn setTitle:@"检测失败" forState:UIControlStateNormal];

    if (self.ecgView.layer.speed == 0 && self.whiteLightLine.layer.speed == 0) {
        return;
    }else{
        [self animationPauseInView:self.ecgView];
        [self animationPauseInView:self.whiteLightLine];
    }
}

/**
 * 设置移动状态
 */
- (void) setMoveState
{
    [self.startLab setHidden:NO];
    [self.resultLab setHidden:YES];
    [self.resultBtn setHidden:YES];
    self.startLab.text = @"检测未结束，请勿移动手指";
}

/**
 * 设置移开状态
 */
- (void) setLeaveState
{
    [self.startLab setHidden:NO];
    [self.resultLab setHidden:YES];
    [self.resultBtn setHidden:YES];
    self.startLab.text = @"检测未结束，请勿移开手指";
}

/**
 * 暂停动画
 */
- (void)animationPauseInView:(UIView *)view {
    // 将当前时间CACurrentMediaTime转换为layer上的时间, 即将parent time转换为local time
    CFTimeInterval pauseTime = [view.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    // 设置layer的timeOffset, 在继续操作也会使用到
    view.layer.timeOffset = pauseTime;
    
    // local time与parent time的比例为0, 意味着local time暂停了
    view.layer.speed = 0;
}

/**
 * 继续动画
 */
- (void)animationContinueInView:(UIView *)view {
    // 时间转换
    CFTimeInterval pauseTime = view.layer.timeOffset;
    // 计算暂停时间
    CFTimeInterval timeSincePause = CACurrentMediaTime() - pauseTime;
    // 取消
    view.layer.timeOffset = 0;
    // local time相对于parent time世界的beginTime
    view.layer.beginTime = timeSincePause;
    // 继续
    view.layer.speed = 1;
}
@end
