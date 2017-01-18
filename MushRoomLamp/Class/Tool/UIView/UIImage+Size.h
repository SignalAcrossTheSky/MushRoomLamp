//
//  UIImage+Size.h
//  HIRE_
//
//  Created by Apple on 13-12-4.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Size)

//调整图片大小
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

@end
