//
//  UIImage+Draw.m
//  HIRE_
//
//  Created by Apple on 13-12-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "UIImage+Draw.h"

@implementation UIImage (Draw)

+ (UIImage *)imageWithDrawColor:(UIColor *)color withSize:(CGRect)sizeMake
{
    CGRect rect = CGRectMake(0, 0, sizeMake.size.width, sizeMake.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

// CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha
+ (UIImage *)imageWithDrawLineColor:(UIColor *)color withSize:(CGRect)sizeMake
{
    CGRect rect = CGRectMake(0, 0, sizeMake.size.width, sizeMake.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
//    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddRect(context,rect);
    CGContextStrokePath(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


@end
