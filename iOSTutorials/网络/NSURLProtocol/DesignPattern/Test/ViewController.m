//
//  ViewController.m
//  Test
//
//  Created by ShannonChen on 2018/2/7.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "MyClient.h"
#import "MyCustomProtocol.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册自定义类
    [MyProtocol registerClass:[MyCustomProtocol class]];
    
    // 调用 client 的 start 方法后，会在内部访问注册过的 Protocol 子类
    MyClient *client = [[MyClient alloc] init];
    [client start];
    
    
}


@end
