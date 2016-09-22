//
//  HYRectDetectorViewController.m
//  FaceDetectorTest1
//
//  Created by yanghaha on 16/9/4.
//  Copyright © 2016年 innoways. All rights reserved.
//

#import "HYRectDetectorViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+HYLibrary.h"
#import "CardInfoTableViewController.h"

#define HY_COLOR_RGB(r, g, b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define VIEW_COLOR_BACKGROUD HY_COLOR_RGB(33, 33, 33)

NSArray * CGRectGetCornerPoints(CGRect rect)
{
    return @[[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))],
             [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))],
             [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))],
             [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))]];
}

@interface HYRectDetectorViewController () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    CAShapeLayer *_layer;
    UIImage *_outImage;
    NSArray *_rectPoints;
}

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) UIButton *cropButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureOutput;
@property (nonatomic) CGRect rectForCropOriginImage;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation HYRectDetectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.captureSession startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.captureSession stopRunning];
}

#pragma mark - Setter && Getter

- (AVCaptureVideoDataOutput *)captureOutput {
    if (!_captureOutput) {
        _captureOutput = [[AVCaptureVideoDataOutput alloc]
                                                   init];
        _captureOutput.alwaysDiscardsLateVideoFrames = YES;
        dispatch_queue_t queue;
        queue = dispatch_queue_create("cameraQueue", NULL);
        [_captureOutput setSampleBufferDelegate:self queue:queue];
        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value = [NSNumber
                           numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary* videoSettings = [NSDictionary
                                       dictionaryWithObject:value forKey:key];
        [_captureOutput setVideoSettings:videoSettings];
    }

    return _captureOutput;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

        if ([device lockForConfiguration:nil]) {
            //设置帧率
            device.activeVideoMinFrameDuration = CMTimeMake(2, 3);
        }
        AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput
                                              deviceInputWithDevice:device  error:nil];

        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession addInput:captureInput];
        [_captureSession addOutput:self.captureOutput];
    }

    return _captureSession;
}

- (AVCaptureVideoPreviewLayer *)prevLayer {
    if (!_prevLayer) {
        _prevLayer = [AVCaptureVideoPreviewLayer
                          layerWithSession:self.captureSession];
        _prevLayer.frame = [self rectForPreviewLayer];
        _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }

    return _prevLayer;
}

- (UIButton *)cropButton {
    if (!_cropButton) {
        _cropButton = [[UIButton alloc] init];
        _cropButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cropButton setTitle:@"确定" forState:UIControlStateNormal];
        [_cropButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_cropButton addTarget:self action:@selector(toucheCropButton) forControlEvents:UIControlEventTouchUpInside];
    }

    return _cropButton;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds)-100, 320, 100);
    }

    return _imageView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        _messageLabel.text = @"正在寻找名片边框";
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:12];
        _messageLabel.layer.cornerRadius = 5.0;
        _messageLabel.layer.masksToBounds = YES;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.backgroundColor = [VIEW_COLOR_BACKGROUD colorWithAlphaComponent:0.5];
        _messageLabel.center = self.view.center;
    }
    
    return _messageLabel;
}

#pragma mark - Private

- (void)setupUI {
    
    self.view.backgroundColor = VIEW_COLOR_BACKGROUD;
    [self.view.layer addSublayer: self.prevLayer];

    [self.view addSubview:self.imageView];
    [self.view addSubview:self.cropButton];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-100]];
    [self.cropButton addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40]];
    [self.cropButton addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.cropButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    [self.view addSubview:self.messageLabel];
    [self addMessageLabelAnimation];
    
    UIBezierPath *beziPath = [UIBezierPath bezierPathWithRect:[self frameForBox]];
    UIBezierPath *contentBeziPath = [UIBezierPath bezierPathWithRect:self.prevLayer.bounds];
    contentBeziPath.usesEvenOddFillRule = YES;
    [contentBeziPath appendPath:beziPath];
    
    _layer = [CAShapeLayer layer];
    _layer.fillRule = kCAFillRuleEvenOdd;  //空心的正方形
    _layer.opacity = 0.8;
    _layer.bounds = self.prevLayer.bounds;
    _layer.path = contentBeziPath.CGPath;
    _layer.lineWidth = 1;
    _layer.position = self.prevLayer.position;
    _layer.fillColor = VIEW_COLOR_BACKGROUD.CGColor;
    [self.prevLayer addSublayer:_layer];
}

- (void)addMessageLabelAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0.0];
    animation.autoreverses = YES;
    animation.duration = 1.0;
    animation.repeatCount = FLT_MAX;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.messageLabel.layer addAnimation:animation forKey:@"message"];
}

- (void)removeMessageLabelAnimation {
    [self.messageLabel.layer removeAnimationForKey:@"message"];
    self.messageLabel.layer.opacity = 0.0;
}

#pragma mark - 坐标转换

- (CGRect)rectForPreviewLayer {

    CGRect rect = [UIScreen mainScreen].bounds;
    rect.size.height -= 64;
    return rect;
    return CGRectMake(0, 0, 270, 480);
}

- (CGFloat)scaleForOriginImageBetweenPreviewLayer {
    CGRect rect = [self rectForPreviewLayer];
    return MIN(_outImage.size.width/CGRectGetWidth(rect), _outImage.size.height/CGRectGetHeight(rect));
}

- (CGRect)frameForBox {
    CGFloat gap = 40;
    CGFloat width = CGRectGetWidth(self.prevLayer.bounds)-2*gap;
    CGFloat height = CGRectGetHeight(self.prevLayer.bounds)-2*gap;
    return CGRectMake(gap, gap, width, height);
}

- (CGPoint)pointFromQZPoint:(CGPoint)point height:(CGFloat)height {
    return CGPointMake(point.x, height-point.y);
}

/**
 *  根据传入的size，计算返回需要的rect
 */
- (CGRect)rectForCropSize {
    
    if (!CGRectIsEmpty(self.rectForCropOriginImage)) {
        return  self.rectForCropOriginImage;
    }
    
    
    CGRect rect = [self frameForBox];
    CGFloat scale = [self scaleForOriginImageBetweenPreviewLayer];
    
    CGFloat width = CGRectGetWidth(rect)*scale;
    CGFloat height = CGRectGetHeight(rect)*scale;
    CGFloat originX = (_outImage.size.width - width)/2.0;
    //    CGFloat originY = (_outImage.size.height - height)/2.0;
    CGFloat originY = (CGRectGetHeight(self.prevLayer.bounds)-CGRectGetMaxY(rect))*scale;
    originY += (_outImage.size.height-CGRectGetMaxY(self.prevLayer.bounds)*scale)/2.0;
    //    originY += CGRectGetMaxY(rect)*scale;
    self.rectForCropOriginImage = CGRectMake(originX, originY, width, height);
    
    return self.rectForCropOriginImage;
}
#pragma mark - 矩形识别

- (NSArray *)featuresWithRectangleImage:(UIImage *)sImage
{
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeRectangle
                                                  context:nil
                                                  options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio:@1.75}];
    CIImage *ciimg = [CIImage imageWithCGImage:sImage.CGImage];
    NSArray *features = [faceDetector featuresInImage:ciimg];
    return features;
}

/**
 *  识别矩形，根据具体需求调用
 */
- (void)performRectangleDetection:(UIImage *)sImage {
    
    NSArray *features = [self featuresWithRectangleImage:sImage];
    
    if (!features.count) {
        NSLog(@"没检测到矩形");
        return ;
    }

    if (features.count) {
        [self checkFeature:features.firstObject];
    }
}

//检测矩形有效性
- (void)checkFeature:(CIRectangleFeature *)feature {

    CGRect rect = [self rectForCropSize];
    if (!CGRectContainsPoint(rect, feature.topRight) ||
        !CGRectContainsPoint(rect, feature.topLeft) ||
        !CGRectContainsPoint(rect, feature.bottomRight) ||
        !CGRectContainsPoint(rect, feature.bottomLeft)) {
        NSLog(@"矩形不在检测框内");
        return ;
    }
    
    [self.captureSession stopRunning];
    UIImage *image = [_outImage imageForCropPaths:CGRectGetCornerPoints(self.rectForCropOriginImage)];

    CardInfoTableViewController *VC = [[CardInfoTableViewController alloc] init];
    VC.image = image;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - Action

//点击确定按钮开始检测
- (void)toucheCropButton {

    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
        [self removeMessageLabelAnimation];
        [self performRectangleDetection:_outImage];
    } else {
        [_layer removeFromSuperlayer];
        [self.captureSession startRunning];
        [self addMessageLabelAnimation];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                    width, height, 8, bytesPerRow, colorSpace,
                                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);

    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);

    dispatch_sync(dispatch_get_main_queue(), ^{
        _outImage = nil;
        UIImage *image = [UIImage imageWithCGImage:newImage scale:1.0
                                      orientation:UIImageOrientationRight];
        _outImage = [image normalImage];
        //考虑到性能问题，此处不错图片处理，关于坐标系的问题，在检测的时候做转换
//        _outImage = [_outImage imageForCropRect:[self rectForCropSize:_outImage.size] scale:1];
//        self.imageView.image = _outImage;
        
        //实时检测
//        [self performRectangleDetection:_outImage];
    });

    CGImageRelease(newImage);

    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}

@end
