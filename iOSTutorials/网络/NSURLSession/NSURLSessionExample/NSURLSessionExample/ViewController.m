//
//  ViewController.m
//  NSURLSessionExample
//
//  Created by ShannonChen on 2018/1/10.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "NetworkService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)sendRequestUsingDelegate:(id)sender {
    
    NetworkService *service = [NetworkService serviceWithCallbackType:NetworkServiceCallbackTypeDelegate];
    [service fetchingContentAsData];
}


- (IBAction)sendRequestUsingBlock:(id)sender {
    
    NetworkService *service = [NetworkService serviceWithCallbackType:NetworkServiceCallbackTypeBlock];
    [service fetchingContentAsData];
//    [service downloadingContentAsAFile];
    
}



@end
