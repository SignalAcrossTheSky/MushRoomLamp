//
//  ZJDayView.m
//  MushRoomLamp
//
//  Created by SongGang on 12/7/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJDayView.h"
#import "Constant.h"
@interface ZJDayView()
@property (nonatomic,copy) NSArray *dayArray;
/** 今天按钮 */
@property (nonatomic,strong) UIButton *todayBtn;
/** 周一按钮 */
@property (nonatomic,strong) UIButton *mondayBtn;
/** 周二按钮 */
@property (nonatomic,strong) UIButton *tuesdayBtn;
/** 周三按钮 */
@property (nonatomic,strong) UIButton *wednesdayBtn;
/** 周四按钮 */
@property (nonatomic,strong) UIButton *thursdayBtn;
/** 周五按钮 */
@property (nonatomic,strong) UIButton *fridayBtn;
/** 周六按钮 */
@property (nonatomic,strong) UIButton *saturdayBtn;
/** 周日按钮 */
@property (nonatomic,strong) UIButton *sundayBtn;

@end

@implementation ZJDayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dayArray = [[NSArray alloc] initWithObjects:@"每周一",@"每周二",@"每周三",@"每周四",@"每周五",@"每周六",@"每周日", nil];
        
        [self createDayView];
    }
    
    return self;
}

/**
 *  创建View
 */
- (void) createDayView
{
    for (int i = 0; i < 7; i ++) {
        UILabel *dayLab = [[UILabel alloc] init];
        dayLab.x = 15;
        dayLab.y = 50 * i;
        dayLab.width = 50;
        dayLab.height = 50;
        dayLab.text = [self.dayArray objectAtIndex:i];
        dayLab.textColor = DDRGBColor(115, 115, 115);
        dayLab.font = [UIFont systemFontOfSize:15];
        [self addSubview:dayLab];
        
        //Line
        UILabel *hLine = [[UILabel alloc] init];
        hLine.x = 15;
        hLine.y = 50 * (i+1);
        hLine.width = self.width - 30;
        hLine.height = 1;
        hLine.backgroundColor = DDRGBColor(230, 230, 230);
        [self addSubview:hLine];
        
        //选择按钮
        UIButton *dayBtn = [[UIButton alloc] init];
        dayBtn.y = 50 * i;
        dayBtn.width = 50;
        dayBtn.height = 50;
        dayBtn.x = self.width - dayBtn.width;
        [dayBtn setImage:[UIImage imageNamed:@"clock_select"] forState:UIControlStateSelected];
        [dayBtn setImage:[UIImage imageNamed:@"clock_noselect"] forState:UIControlStateNormal];\
        [dayBtn addTarget:self action:@selector(selectRepeatDayClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [dayBtn setSelected:NO];
        [self addSubview:dayBtn];
        
        if ( i == 0) {
            self.mondayBtn = dayBtn;
        }else if( i == 1)
        {
            self.tuesdayBtn = dayBtn;
        }else if( i == 2)
        {
            self.wednesdayBtn = dayBtn;
        }else if( i == 3)
        {
            self.thursdayBtn = dayBtn;
        }else if( i == 4)
        {
            self.fridayBtn = dayBtn;
        }else if( i == 5)
        {
            self.saturdayBtn = dayBtn;
        }else if( i == 6)
        {
            self.sundayBtn = dayBtn;
        }
    }
    
    //取消按钮
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.x = 0;
    cancelBtn.y = 350;
    cancelBtn.width = self.width/2;
    cancelBtn.height = 50;
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:DDRGBColor(153, 153, 153) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClickAction1) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    //确定按钮
    UIButton *okBtn = [[UIButton alloc] init];
    okBtn.x = cancelBtn.right;
    okBtn.y = cancelBtn.y;
    okBtn.width = self.width/2;
    okBtn.height = 50;
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    [okBtn setTitleColor:DDRGBColor(0, 240, 200) forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(okBtnClickAction1) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:okBtn];
    
    UILabel *vLine = [[UILabel alloc] init];
    vLine.width = 1;
    vLine.height = 50;
    vLine.x = cancelBtn.right;
    vLine.y = cancelBtn.y;
    vLine.backgroundColor = DDRGBColor(230, 230, 230);
    [self addSubview:vLine];
    
}

/**
 * 选择重复时间
 */
- (void)selectRepeatDayClickAction:(UIButton *)sender
{
    if ([sender isSelected]) {
        [sender setSelected:NO];
    }else
    {
        [sender setSelected:YES];
    }
}

/**
 * 取消按钮点击事件
 */
- (void)cancelBtnClickAction1
{
    if ([_delegate respondsToSelector:@selector(cancelBtnClickAction)]) {
        [_delegate cancelBtnClickAction];
    }
}

/**
 * 确定按钮点击事件
 */
- (void)okBtnClickAction1
{
    NSString *dayStr = @"";
  
    if ([self.mondayBtn isSelected]) {
        dayStr = [dayStr stringByAppendingString:@"周一,"];
    }
    
    if ([self.tuesdayBtn isSelected]) {
        dayStr = [dayStr stringByAppendingString:@"周二,"];
    }
    
    if ([self.wednesdayBtn isSelected]) {
        dayStr = [dayStr stringByAppendingString:@"周三,"];
    }
    
    if ([self.thursdayBtn isSelected]) {
        dayStr = [dayStr stringByAppendingString:@"周四,"];
    }
    
    if ([self.fridayBtn isSelected]) {
        dayStr = [dayStr stringByAppendingString:@"周五,"];
    }
    
    if ([self.saturdayBtn isSelected]) {
        dayStr = [dayStr stringByAppendingString:@"周六,"];
    }
    
    if ([self.sundayBtn isSelected]) {
        dayStr = [dayStr stringByAppendingString:@"周日,"];
    }
    
    if ([_delegate respondsToSelector:@selector(okBtnClickAction:)]) {
        [_delegate okBtnClickAction:dayStr];
    }
}

- (void)setDayStr:(NSString *)dayStr
{
    _dayStr = dayStr;
    
    NSArray *dayArray =  [dayStr componentsSeparatedByString:@","];
    
    for (NSString *str in dayArray ) {
        if ([str isEqualToString:@"今天"]) {
            [self.todayBtn setSelected:YES];
        }else if ([str isEqualToString:@"周一"])
        {
            [self.mondayBtn setSelected:YES];
        }else if ([str isEqualToString:@"周二"])
        {
            [self.tuesdayBtn setSelected:YES];
        }else if ([str isEqualToString:@"周三"])
        {
            [self.wednesdayBtn setSelected:YES];
        }else if ([str isEqualToString:@"周四"])
        {
            [self.thursdayBtn setSelected:YES];
        }else if ([str isEqualToString:@"周五"])
        {
            [self.fridayBtn setSelected:YES];
        }else if ([str isEqualToString:@"周六"])
        {
            [self.saturdayBtn setSelected:YES];
        }else if ([str isEqualToString:@"周日"])
        {
            [self.sundayBtn setSelected:YES];
        }
    }
}
@end
