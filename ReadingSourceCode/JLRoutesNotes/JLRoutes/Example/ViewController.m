//
//  ViewController.m
//  Example
//
//  Created by ShannonChen on 2018/1/30.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "JLRoutes.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)didSelectOpenURLButton:(id)sender {
    
    NSString *urlString = @"myapp://detail/4?title=详情页";
    NSString *encodedURLString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [JLRoutes routeURL:[NSURL URLWithString:encodedURLString]];
}


@end
