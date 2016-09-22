//
//  ViewController.m
//  businesscard
//
//  Created by luculent on 16/8/1.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import "ViewController.h"

#import "AFNetworking.h"
#import "HYHttpCilent/HYHttpCilent.h"

#define card_name @"card1"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    NSUInteger _index ;
}

@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) UIImagePickerController *imagepicker ;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        CGFloat colorValue = 33/255.0;
        _imageView.backgroundColor = [UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:1];
    }
    
    return _imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)prefixForUrl {
    return @"http://bcr2.intsig.net/BCRService/";
}

- (NSDictionary *)params {
    NSDictionary *params = @{@"user": @"1666487339@qq.com",
                             @"pass": @"GHCXGHJWPF4FAW6H",
                             @"lang": @"15",
                             @"json": @"1"};
    return params;
}

- (void)urlForName:(NSString *)name user:(NSString *)user pass:(NSString *)pass lang:(NSString *)lang image:(NSString *)image {
    
    
}

- (UIImagePickerController *)imagepicker {
    if (!_imagepicker) {
        _imagepicker = [[UIImagePickerController alloc]init];
        _imagepicker.view.backgroundColor = [UIColor whiteColor];
        _imagepicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagepicker.delegate = self;
        _imagepicker.allowsEditing = YES;
    }
    
    return _imagepicker;
}

- (IBAction)cardButtonAction:(id)sender {
    
    _index = 0;
    [self presentViewController:self.imagepicker animated:YES completion:nil];
}

- (IBAction)imageButtonAction:(id)sender {
    
    _index = 1;
    [self presentViewController:self.imagepicker animated:YES completion:nil];
    
}

- (void)BCR_VCF2:(UIImage *)image {
    
    NSString *urlStr = [[self prefixForUrl] stringByAppendingString:@"BCR_VCF2"];

    NSMutableURLRequest *request = (NSMutableURLRequest *)[[HYHttpCilent shareManager] textRequestWithHttpMethod:@"get" urlString:urlStr httpBody:[self params]];
    
    NSData *data = UIImageJPEGRepresentation(image, 1);
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    
    [[HYHttpCilent shareManager] taskWithRequest:request success:^(NSURLResponse *response, id responseObject) {
        
        NSLog(@"is main: %@", [NSThread isMainThread]? @"y":@"n");
        NSLog(@"success");
        self.infoLabel.text = [[responseObject description] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.imageView.image = nil;
        
    } failure:^(NSURLResponse *response, NSError *error) {
        
        NSLog(@"fail");

    }];
    
    
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [manager POST:urlStr parameters:[self params] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        
//        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"card" ofType:@"jpg"]];
//        
//        //        [formData appendPartWithFormData:[@(data.length).stringValue dataUsingEncoding:NSUTF8StringEncoding] name:@"size"];
//        [formData appendPartWithFileData:data name:@"upfile" fileName:@"upfile" mimeType:@"image/jpep"];
//        
//    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        
//        NSLog(@"success");
//        
//    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//        
//        NSLog(@"fail");
//        
//    }];


}

- (void)BCR_Crop:(UIImage *)image {
    NSString *urlStr = [[self prefixForUrl] stringByAppendingString:@"BCR_Crop"];
    
    NSMutableURLRequest *request = (NSMutableURLRequest *)[[HYHttpCilent shareManager] textRequestWithHttpMethod:@"get" urlString:urlStr httpBody:[self params]];
    
    NSData *data = UIImageJPEGRepresentation(image, 1);
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    
    [[HYHttpCilent shareManager] taskWithRequest:request success:^(NSURLResponse *response, id responseObject) {
        
        NSLog(@"success");
        
        static NSData* magicStartData = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            static const uint8_t magic[] = { 0xff, 0xd8 };
            magicStartData = [NSData dataWithBytesNoCopy:(void*)magic length:2 freeWhenDone:YES];
        });
        
        // assume data is the NSData with embedded data
        NSRange range = [responseObject rangeOfData:magicStartData options:0 range:NSMakeRange(0, [responseObject length])];
        if (range.location != NSNotFound) {
            // This assumes the subdata doesn't have a specific range and is just everything
            // after the magic, otherwise adjust
            NSData *textData = [responseObject subdataWithRange:NSMakeRange(0, range.location)];
            NSString *text = [[NSString alloc] initWithData:textData encoding:NSUTF8StringEncoding];
            self.infoLabel.text = text;
            
            NSData *imageData = [responseObject subdataWithRange:NSMakeRange(range.location, [responseObject length] - range.location)];
            UIImage *image = [UIImage imageWithData:imageData];
            self.imageView.image = image;
            
            
            CGRect rect = [UIScreen mainScreen].bounds;
            
            CGFloat rate = image.size.width/CGRectGetWidth(rect);
            CGFloat height = image.size.height/rate;
            self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(rect), height);
            self.tableView.tableHeaderView = self.imageView;
        }

    } failure:^(NSURLResponse *response, NSError *error) {
        NSLog(@"fail");        
    }];
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [manager POST:urlStr parameters:[self params] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        
//        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"card" ofType:@"jpg"]];
//        
////        [formData appendPartWithFormData:[@(data.length).stringValue dataUsingEncoding:NSUTF8StringEncoding] name:@"size"];
//        [formData appendPartWithFileData:data name:@"upfile" fileName:@"upfile" mimeType:@"image/jpep"];
//        
//    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        
//        NSLog(@"success");
//        
//    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//       
//        NSLog(@"fail");
//        
//    }];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    if (_index == 0) {
        [self BCR_VCF2:info[UIImagePickerControllerEditedImage]];
    } else {
        [self BCR_Crop:info[UIImagePickerControllerEditedImage]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
