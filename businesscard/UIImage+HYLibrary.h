//
//  UIImage+HYLibrary.h
//  MDPMS
//
//  Created by luculent on 16/6/20.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HYLibrary)

/**
 *  imageOrientation调整至UIImageOrientationUp，
 *  从而避免在其他平台上打开时，需要旋转才能正常显示
 */
- (UIImage *)normalImage;

/**
 *  截取指定图片的区域，生成指定缩放比率的图片
 */
- (UIImage *)imageForCropRect:(CGRect)cropRect scale:(CGFloat)scale;

/**
 *  任意形状裁剪一个比较典型的例子就是photo中通过磁性套索进行抠图
 *  @param pointArr 套索所有的点
 */
- (UIImage*)imageForCropPaths:(NSArray *)paths ;

@end
