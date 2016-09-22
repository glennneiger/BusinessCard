//
//  MainPageViewController.m
//  businesscard
//
//  Created by luculent on 16/9/6.
//  Copyright © 2016年 hillyoung. All rights reserved.
//

#import "MainPageViewController.h"
#import "HYRectDetectorViewController.h"

@interface MainPageViewController ()

@end

@implementation MainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)touchePushButton:(id)sender {
    HYRectDetectorViewController *VC = [[HYRectDetectorViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
