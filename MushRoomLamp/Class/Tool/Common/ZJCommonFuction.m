//
//  ZJCommonFuction.m
//  MushRoomLamp
//
//  Created by SongGang on 7/6/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import "ZJCommonFuction.h"
#import "BDUMD5Crypt.h"

@implementation ZJCommonFuction

/**
 * 发送验证码按钮点击事件
 */
+ (void) sendSecurityCodeButtonClickAction:(UIButton *)sender
                            withFirstTitle:(NSString *)originalString
                           withSecondTitle:(NSString *)changedString
{
    UIButton * _l_timeButton = (UIButton *)sender;
    
    __block int timeout=59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [_l_timeButton setTitle:originalString forState:UIControlStateNormal];
                
                _l_timeButton.userInteractionEnabled = YES;
            });
        }else{
            
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                [_l_timeButton setTitle:[NSString stringWithFormat:@"%@(%@s)",changedString,strTime] forState:UIControlStateNormal];
                [UIView commitAnimations];
                _l_timeButton.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

/**
 * 判断手机号是否满足正则表达式
 */
+ (BOOL) checkTel:(NSString *)str
{
    NSString * phoneRegex = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

/**
 * 加密方法
 */
+ (NSString *) addLockFunction:(NSDictionary *)dic
{
    NSString *sign = @"";
    NSArray *keys = [dic allKeys];
    
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    for (NSString *categoryId in sortedArray) {
        
        sign = [sign stringByAppendingString:categoryId];
        sign = [sign stringByAppendingString:[NSString stringWithFormat:@"%@",[dic objectForKey:categoryId]]];
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [BDUMD5Crypt HMACMD5WithString:sign WithKey:[userDefault objectForKey:@"token"]];
}

/**
 * 获取一个数组中的最大值
 */
+ (NSInteger)getMaxValueFrom:(NSArray *)array
{
    NSInteger temp = -100;
    
    if(array.count == 0)
    {
        return 100;
    }
    
    for (id object in array) {
        NSInteger value = [object integerValue];
        if (value == -999)
        {
            continue;
        }
        
        if (value > temp) {
            temp = value;
        }
    }
    return temp;
}

/**
 * 获取一个数组中的最小值
 */
+ (NSInteger)getMinValueFrom:(NSArray *)array
{
    NSInteger temp = 10000;
    
    if (array.count == 0) {
        return 0;
    }
    
    for (id object in array) {
        NSInteger value = [object integerValue];
        if (value == -999) {
            continue;
        }
        
        if (value < temp) {
            temp = value;
        }
    }
    return temp;
}

/**
 * 获取一个数组中最大值的index
 */
+ (NSInteger)getMaxValueIndexFrom:(NSArray *)array
{
    NSInteger index = 0;
    NSInteger value = [[array objectAtIndex:0] integerValue];
    
    for (int i = 0; i < array.count; i++) {
        if(value < [[array objectAtIndex:i] integerValue])
        {
            index = i;
            value = [[array objectAtIndex:i] integerValue];
        }
    }
    
    return index;
}

/**
 * 获取一个数组中最小值的index
 */
+ (NSInteger)getMinValueIndexFrom:(NSArray *)array
{
    NSInteger index = 0;
    NSInteger value = [[array objectAtIndex:0] integerValue];
    
    for (int i = 0; i < array.count; i++) {
        if(value > [[array objectAtIndex:i] integerValue])
        {
            index = i;
            value = [[array objectAtIndex:i] integerValue];
        }
    }
    
    return index;
}

/**
 * 一个数组中的值除以5
 */
+ (NSArray *)dividedValueWith5:(NSArray *)array
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (id object in array) {
        NSInteger value = [object integerValue]/5;
        [newArray addObject:@(value)];
    }
    
    return newArray;
}

/**
 * 一个数组中的值除以2
 */
+ (NSArray *)dividedValueWith2:(NSArray *)array
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (id object in array) {
        NSInteger value = [object integerValue]/2;
        [newArray addObject:@(value)];
    }
    return newArray;
}

/**
 * 一个数组中的值乘以2
 */
+ (NSArray *)multiplyValueWith2:(NSArray *)array
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (id object in array) {
        NSInteger value = [object integerValue]*2;
        [newArray addObject:@(value)];
    }
    return newArray;
}
/**
 * 创建提示框
 */
+ (UIAlertController *)createTipView:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alertController addAction:cancelAction];
    
    return alertController;
}

/**
 *  字典转字符串
 */
+ (NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}


/**
 * 创建提示框
 */
+ (void)createTipView:(NSString *)message  inViewController:(UIViewController *)vc
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alertController addAction:cancelAction];
    
    [vc presentViewController:alertController animated:YES completion:^{
        
    }];
}

/**
 * 获取当前viewController
 */
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

/**
 * 计算高度
 */
+(CGSize)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
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
    return size;
}

/**
 * json字符串转字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}

@end
