//
//  ViewController.m
//  NSURLConnectionExample
//
//  Created by ShannonChen on 2017/12/25.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"

//static NSString * const kURLString = @"https://developer.apple.com/documentation/foundation";
static NSString * const kURLString = @"https://s-media-cache-ak0.pinimg.com/1200x/2e/0c/c5/2e0cc5d86e7b7cd42af225c29f21c37f.jpg";

@interface ViewController () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, assign) long long serverFileLength;
@property (nonatomic, assign) long long localFileLength;
@property (nonatomic, copy) NSString *filePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 发送请求
    //发送同步请求，在主线程执行
//    [self sendSynchronousRequest:request];
//    [self sendAsynchronousRequest:request];
//    [self sendAsynchronousRequest:self.request delegate:self];
    [self startBrokenPointDownloadWithURLString:kURLString];
    
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

/// 断点续传下载
- (void)startBrokenPointDownloadWithURLString:(NSString *)URLString {
    
    // 初始化已下载文件大小
    self.localFileLength = 0;
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    self.filePath = [cachePath stringByAppendingPathComponent:@"my_image.png"];
    
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:NULL];
    
    long long  localFileLength = [dict[NSFileSize] longLongValue];
    
    // 如果没有本地文件,直接下载!
    if (!localFileLength) {
        // 下载新文件
        [self sendAsynchronousRequest:self.request delegate:self];
        
    } else if (localFileLength > self.serverFileLength) { // 如果已下载的大小，大于服务器文件大小，肯定出错了，删除文件并从新下载
        // 删除文件 remove
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
        
        // 下载新文件
        [self sendAsynchronousRequest:self.request delegate:self];
        
    } else if (localFileLength == self.serverFileLength) {
        NSLog(@"文件已经下载完毕");
    } else if (localFileLength && localFileLength < self.serverFileLength) {
        // 文件下载了一半，则使用断点续传
        self.localFileLength = localFileLength;
        
        [self getFileWithUrlString:kURLString WithStartSize:localFileLength endSize:self.serverFileLength-1];
    }
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
    
    
    // 记录需要下载的文件总长度，用于断点下载
    self.serverFileLength = response.expectedContentLength;
}

/// 当接收到服务器的数据时会调用（不一定一次就能传完，可能会被调用多次，每次只传递部分数据）
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
   
    
    // 断点续传
    // 如果这个文件不存在,响应的文件句柄就不会创建!
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    // 在这个路径下已经有文件了!
    if (fileHandle) {
        // 将文件句柄移动到文件的末尾
        [fileHandle seekToEndOfFile];
        // 写入文件的意思(会将data写入到文件句柄所操纵的文件!)
        [fileHandle writeData:data];
        
        [fileHandle closeFile];
        
    } else {
        // 第一次调用这个方法的时候,在本地还没有文件路径(没有这个文件)!
        [data writeToFile:self.filePath atomically:YES];
    }
}

/// 当请求成功完成时调用该方法
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

/// 当请求失败时调用该方法
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
}


#pragma mark - 断点下载处理

/* 断点续传(代理方法监听下载过程)
 * startSize:本次断点续传开始的位置
 * endSize:本地断点续传结束的位置
 */
-(void)getFileWithUrlString:(NSString *)urlString WithStartSize:(long long)startSize endSize:(long long)endSize
{
    // 1. 创建请求!
    NSURL *url = [NSURL URLWithString:urlString];
    // 默认就是 GET 请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 设置断点续传信息
    NSString *range = [NSString stringWithFormat:@"Bytes=%lld-%lld",startSize,endSize];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // NSUrlConnection 下载过程!
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

@end
