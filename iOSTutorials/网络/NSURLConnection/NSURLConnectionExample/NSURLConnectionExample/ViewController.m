//
//  ViewController.m
//  NSURLConnectionExample
//
//  Created by ShannonChen on 2017/12/25.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"

static NSString * const kURLString = @"https://developer.apple.com/documentation/foundation";
//static NSString * const kURLString = @"https://s-media-cache-ak0.pinimg.com/1200x/2e/0c/c5/2e0cc5d86e7b7cd42af225c29f21c37f.jpg";

@interface ViewController () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLRequest *request;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 发送请求
    //发送同步请求，在主线程执行
//    [self sendSynchronousRequest:request];
//    [self sendAsynchronousRequest:request];
    [self sendAsynchronousRequest:self.request delegate:self];
    
}

- (NSURLRequest *)request {
    if (!_request) {
        // GET请求：请求行\请求头\请求体
        // 1. 设置请求路径
        NSURL *url = [NSURL URLWithString:kURLString];
        
        // 2.创建请求对象（NSURLRequest 默认的请求方式是 GET）
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        //    request.timeoutInterval = 60;
        //    request.HTTPMethod = @"GET";
        //    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        //    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
        //    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
        //   forHTTPHeaderField:@"Accept"];
        
        _request = request;
    }
    return _request;
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

/// 当接收到服务器的响应（连通了服务器）时会调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    
    NSMutableString *responseString = [NSMutableString string];
    [responseString appendString:@"-------请求成功--------\n"];
    
    [responseString appendFormat:@"URL: %@\n", HTTPResponse.URL];
    [responseString appendFormat:@"Content-Type: %@\n", HTTPResponse.MIMEType];
    [responseString appendFormat:@"suggestedFilename: %@\n", HTTPResponse.suggestedFilename];
    [responseString appendFormat:@"textEncodingName: %@\n", HTTPResponse.textEncodingName];
    [responseString appendFormat:@"statusCode: %@\n", @(HTTPResponse.statusCode)];
    [responseString appendFormat:@"allHeaderFields: %@\n",  HTTPResponse.allHeaderFields];
    [responseString appendString:@"---------------------\n"];
    NSLog(@"%@", responseString);

}

/// 当接收到服务器的数据时会调用（不一定一次就能传完，可能会被调用多次，每次只传递部分数据）
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
   
}

/// 当请求成功完成时调用该方法
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

/// 当请求失败时调用该方法
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}


@end
