//
//  UIImage+Size.m
//  HIRE_
//
//  Created by Apple on 13-12-4.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "UIImage+Size.h"

@implementation UIImage (Size)

//调整图片大小
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
