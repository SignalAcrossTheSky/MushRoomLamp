//
//  ZJCommonFuction.h
//  MushRoomLamp
//
//  Created by SongGang on 7/6/16.
//  Copyright © 2016 SongGang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZJCommonFuction : NSObject

/** 发送验证码，倒计时方法 */
+ (void) sendSecurityCodeButtonClickAction:(UIButton *)sender
                            withFirstTitle:(NSString *)originalString
                           withSecondTitle:(NSString *)changedString;
/** 判断手机号是否满足正则表达式 */
+ (BOOL) checkTel:(NSString *)str;
/** 加密算法 */
+ (NSString *) addLockFunction:(NSDictionary *)dic;
/** 获取数组中最大值 */
+ (NSInteger)getMaxValueFrom:(NSArray *)array;
/** 获取数组中最小值 */
+ (NSInteger)getMinValueFrom:(NSArray *)array;
/** 一个数组中的值除以2 */
+ (NSArray *)dividedValueWith2:(NSArray *)array;
/** 一个数组中的值除以5 */
+ (NSArray *)dividedValueWith5:(NSArray *)array;
/** 获取一个数组中最大值的index */
+ (NSInteger)getMaxValueIndexFrom:(NSArray *)array;
/** 获取一个数组中最小值的index */
+ (NSInteger)getMinValueIndexFrom:(NSArray *)array;
/** 一个数组中的值乘以2 */
+ (NSArray *)multiplyValueWith2:(NSArray *)array;
/** 字典转字符串 */
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
/** 创建提示框 */
+ (void)createTipView:(NSString *)message  inViewController:(UIViewController *)vc;
/* 获取当前viewController */
+ (UIViewController *)getCurrentVC;
/** 计算高度 */
+(CGSize)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width;
/** json字符串转字典 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
@end
