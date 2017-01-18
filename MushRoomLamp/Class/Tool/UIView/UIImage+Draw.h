//
//  UIImage+Draw.h
//  HIRE_
//
//  Created by Apple on 13-12-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Draw)

+ (UIImage *)imageWithDrawColor:(UIColor *)color withSize:(CGRect)sizeMake;


+ (UIImage *)imageWithDrawLineColor:(UIColor *)color withSize:(CGRect)sizeMake;

@end
