//
//  _NetworkServiceDelegate.m
//  NSURLSessionExample
//
//  Created by ShannonChen on 2018/1/31.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "_NetworkServiceDelegate.h"

@interface _NetworkServiceDelegate () <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@end

@implementation _NetworkServiceDelegate

/// 向网络请求数据
- (void)fetchingContentAsData {
    
    // 1.创建url
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    
    // 2.创建请求 并设置缓存策略为每次都从网络加载，超时时间30秒
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:30];
    
    // 3.创建 task
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request];
    [dataTask resume];
}

#pragma mark - NSURLSessionDelegate （session 级别的 delegate 回调）

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}


#pragma mark - NSURLSessionTaskDelegate（task 级别的 delegate 回调方法，跟特定的 task 有关）


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error.code == NSURLErrorCancelled) {
        NSLog(@"请求被取消了~");
    }
    
}


#pragma mark - NSURLSessionDataDelegate （跟 task 发送数据给 delegate 有关的方法）

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSLog(@"%@", response);
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"%s", __FUNCTION__);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(nonnull NSCachedURLResponse *)proposedResponse completionHandler:(nonnull void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    completionHandler(proposedResponse);
}




@end
