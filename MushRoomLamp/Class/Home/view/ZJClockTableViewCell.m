//
//  ZJClockTableViewCell.m
//  MushRoomLamp
//
//  Created by SongGang on 12/6/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJClockTableViewCell.h"
#import "Constant.h"

@interface ZJClockTableViewCell()
@property (nonatomic,strong) UILabel *timeLab;
@property (nonatomic,strong) UILabel *remarkLab;
@property (nonatomic,strong) UILabel *dayLab;
@property (nonatomic,strong) UISwitch *switchBtn;
@end

@implementation ZJClockTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createCellView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void) createCellView
{
    //时间
    UILabel *timeLab = [[UILabel alloc] init];
    timeLab.x = 15;
    timeLab.y = 0;
    timeLab.width = 70;
    timeLab.height = 60;
    timeLab.text = @"07:00";
    timeLab.textColor = DDRGBColor(102, 102,102);
    timeLab.font = [UIFont systemFontOfSize:24];
    timeLab.textAlignment = NSTextAlignmentLeft;
    [self addSubview:timeLab];
    self.timeLab = timeLab;
    
    //分割线
    UILabel *speLine = [[UILabel alloc] init];
    speLine.x = timeLab.right + 5;
    speLine.y = 10;
    speLine.width = 1;
    speLine.height = 40;
    speLine.backgroundColor = DDRGBColor(230, 230, 230);
    [self addSubview:speLine];
    
    //备注
    UILabel *remarkLab = [[UILabel alloc] init];
    remarkLab.x = speLine.right + 10;
    remarkLab.y = 15;
    remarkLab.width = 150;
    remarkLab.height = 12;
    remarkLab.textAlignment = NSTextAlignmentLeft;
    remarkLab.text = @"起床闹钟";
    remarkLab.textColor = DDRGBColor(102, 102, 102);
    remarkLab.font = [UIFont systemFontOfSize:12];
    [self addSubview:remarkLab];
    self.remarkLab = remarkLab;
    
    //时间
    UILabel *dayLabel = [[UILabel alloc] init];
    dayLabel.x = remarkLab.x;
    dayLabel.y = remarkLab.bottom + 10;
    dayLabel.width = 150;
    dayLabel.height = 12;
    dayLabel.text = @"周一，周二，周三，周四，周五，周六";
    dayLabel.font = [UIFont systemFontOfSize:12];
    dayLabel.textAlignment = NSTextAlignmentLeft;
    dayLabel.textColor = DDRGBColor(153, 153, 153);
    [self addSubview:dayLabel];
    self.dayLab = dayLabel;
    
    //开关
    UISwitch *switchBtn = [[UISwitch alloc] init];
    switchBtn.width = 51;
    switchBtn.height = 31;
    switchBtn.x = MAINSCREEN.size.width - 15 - switchBtn.width;
    switchBtn.y =  15;
    [self addSubview:switchBtn];
    switchBtn.onTintColor = DDRGBColor(0, 240, 200);
    [switchBtn addTarget:self action:@selector(openAlarmClockAction:) forControlEvents:UIControlEventValueChanged];
    self.switchBtn = switchBtn;

    //底部分割线
    UILabel *hLine = [[UILabel alloc] init];
    hLine.x = 15;
    hLine.y = 59;
    hLine.width = MAINSCREEN.size.width - 15;
    hLine.height = 1;
    hLine.backgroundColor = DDRGBColor(230, 230, 230);
    [self addSubview:hLine];
}

- (void) setDic:(NSDictionary *)dic
{
    self.timeLab.text = dic[@"time"];
    self.remarkLab.text = dic[@"remark"];
    self.dayLab.text = dic[@"day"];
    if ([dic[@"state"] isEqual:@(0)]) {
        [self.switchBtn setOn:NO];
    }else if([dic[@"state"] isEqual:@(1)]) {
        [self.switchBtn setOn:YES];
    }
    
}

- (void) openAlarmClockAction:(UISwitch *)sender
{
    int state;
    if ([sender isOn]) {
        state = 1;
    }else{
        state = 0;
    }
    
    if ([_delegate respondsToSelector:@selector(openAlarmClock:withState:)]) {
        [_delegate openAlarmClock:self.row withState:state];
    }
}

@end
