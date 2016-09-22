//
//  CardInfoTableViewController.m
//  businesscard
//
//  Created by luculent on 16/9/6.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import "CardInfoTableViewController.h"
#import "HYHttpCilent/HYHttpCilent.h"

@interface CardInfoTableViewController ()

@property (strong, nonatomic) UIImageView *cardImageView;
@property (strong, nonatomic) UILabel *infoLabel;

@end

@implementation CardInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableHeaderView = self.cardImageView;
    self.tableView.tableFooterView = self.infoLabel;
    
    [self BCR_Crop:self.image];
}

- (UIImageView *)cardImageView {
    if (!_cardImageView) {
        _cardImageView = [[UIImageView alloc] init];
        _cardImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _cardImageView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.numberOfLines = 0;
        _infoLabel.frame = CGRectMake(0, 0, 0, 1000);
    }
    
    return _infoLabel;
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
        self.cardImageView.image = nil;
        
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
            self.cardImageView.image = image;
            
            CGRect rect = [UIScreen mainScreen].bounds;
            
            CGFloat rate = image.size.width/CGRectGetWidth(rect);
            CGFloat height = image.size.height/rate;
            self.cardImageView.frame = CGRectMake(0, 0, CGRectGetWidth(rect), height);
            self.tableView.tableHeaderView = nil;
            self.tableView.tableHeaderView = self.cardImageView;
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


@end
