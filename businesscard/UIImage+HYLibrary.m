//
//  UIImage+HYLibrary.m
//  MDPMS
//
//  Created by luculent on 16/6/20.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import "UIImage+HYLibrary.h"

@implementation UIImage (HYLibrary)

/**
 *  1、利用了UIImage中的drawInRect方法，它会将图像绘制到画布上，并且已经考虑好了图像的方向
 *  2、根据imageOrientation做相应的转换
 */
- (UIImage *)normalImage {

#if 1
    if (self.imageOrientation == UIImageOrientationUp) return self;

    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
#else

    if (self.imageOrientation == UIImageOrientationUp) return self;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;

#endif
}

- (UIImage *)imageForCropRect:(CGRect)cropRect scale:(CGFloat)scale {
    
    //定义myImageRect，截图的区域
    CGImageRef imageRef = self.CGImage;
    CGImageRef cropImageRef = CGImageCreateWithImageInRect(imageRef, cropRect);
    CGImageRelease(imageRef);
    
    CGSize size = cropRect.size;
    if (scale > 0) {
        size = CGSizeMake(size.width*scale, size.height*scale);
    }
    
    //绘制图片
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), cropImageRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cropImageRef);
    
    return image;
}

/*
 *  截取不规则图形
 */
- (UIImage*)imageForCropPaths:(NSArray *)paths {
    if (paths.count == 0) {
        return nil;
    }
    
    CGPoint *points = malloc(sizeof(CGPoint) * paths.count);
    for (int i = 0; i < paths.count; ++i) {
        points[i] = [[paths objectAtIndex:i] CGPointValue];
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * self.scale, self.size.height * self.scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextAddLines(context, points, paths.count);
    CGContextClosePath(context);
    CGRect boundsRect = CGContextGetPathBoundingBox(context);
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(boundsRect.size);
    context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, boundsRect.size.width, boundsRect.size.height));
    
    CGMutablePathRef  path = CGPathCreateMutable();
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-boundsRect.origin.x, -boundsRect.origin.y);
    CGPathAddLines(path, &transform, points, paths.count);
    
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    [self drawInRect:CGRectMake(-boundsRect.origin.x, -boundsRect.origin.y, self.size.width * self.scale, self.size.height * self.scale)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGPathRelease(path);
    UIGraphicsEndImageContext();
    CGContextRelease(context);

    return image;
}

@end
