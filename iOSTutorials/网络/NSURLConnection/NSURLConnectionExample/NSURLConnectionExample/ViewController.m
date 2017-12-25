//
//  ViewController.m
//  NSURLConnectionExample
//
//  Created by ShannonChen on 2017/12/25.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSURLConnectionDataDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // GET请求：请求行\请求头\请求体
    // 1. 设置请求路径
    NSString *urlString = @"https://developer.apple.com/documentation/foundation";
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2.创建请求对象（NSURLRequest 默认的请求方式是 GET）
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3.发送请求
    //发送同步请求，在主线程执行
//    [self sendSynchronousRequest:request];
//    [self sendAsynchronousRequest:request];
    [self sendAsynchronousRequest:request delegate:self];
    
}

/// 异步下载
- (void)sendAsynchronousRequest:(NSURLRequest *)request delegate:(id <NSURLConnectionDelegate>)delegate {
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
}

/// 异步下载
- (void)sendAsynchronousRequest:(NSURLRequest *)request {
    NSLog(@"--开始发送请求--");
    
    // 当服务器有返回数据的时候调用会开一条新的线程去发送请求，主线程继续往下走，当拿到服务器的返回数据的数据的时候再回 调block，执行回调 block 代码段。这种情况不会卡住主线程。
    // 这里的队列的作用是决定这个回调 block 操作放在哪个线程执行？
    NSOperationQueue *queueToExecuteCompletionHandler = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queueToExecuteCompletionHandler
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
         NSLog(@"--收到响应，大小：%@--",@(data.length));
    }];
}

/// 同步下载
- (void)sendSynchronousRequest:(NSURLRequest *)request {
    
    NSLog(@"--开始发送请求--");
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    // 一直在等待服务器返回数据，这行代码会卡住，如果服务器没有返回数据，那么在主线程UI会卡住不能继续执行操作
    NSLog(@"--收到响应，大小：%@--",@(data.length));
}


#pragma mark - <NSURLConnectionDataDelegate>
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

@end
