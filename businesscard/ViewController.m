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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
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
                             @"lang": @"15"};
    return params;
}

- (void)urlForName:(NSString *)name user:(NSString *)user pass:(NSString *)pass lang:(NSString *)lang image:(NSString *)image {
    
    
}

- (IBAction)cardButtonAction:(id)sender {
    [self BCR_VCF2];
}

- (IBAction)imageButtonAction:(id)sender {
    [self BCR_Crop];
}

- (void)BCR_VCF2 {
    
    NSString *urlStr = [[self prefixForUrl] stringByAppendingString:@"BCR_VCF2"];

    NSMutableURLRequest *request = (NSMutableURLRequest *)[[HYHttpCilent shareManager] textRequestWithHttpMethod:@"get" urlString:urlStr httpBody:[self params]];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:card_name ofType:@"jpg"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    
    [[HYHttpCilent shareManager] taskWithRequest:request success:^(NSURLResponse *response, id responseObject) {
        
        NSLog(@"is main: %@", [NSThread isMainThread]? @"y":@"n");
        NSLog(@"success");
        self.textView.text = responseObject;
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

- (void)BCR_Crop {
    NSString *urlStr = [[self prefixForUrl] stringByAppendingString:@"BCR_Crop"];
    
    NSMutableURLRequest *request = (NSMutableURLRequest *)[[HYHttpCilent shareManager] textRequestWithHttpMethod:@"get" urlString:urlStr httpBody:[self params]];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:card_name ofType:@"jpg"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    
    [[HYHttpCilent shareManager] taskWithRequest:request success:^(NSURLResponse *response, id responseObject) {
        
        NSLog(@"success");
        
        UIImage *image = [UIImage imageWithData:data];
        
        self.imageView.image = image;
        self.textView.text = @"";
        
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


@end
