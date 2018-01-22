//
//  ViewController.m
//  NSURLSessionExample
//
//  Created by ShannonChen on 2018/1/10.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "Test.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self fetchingContentAsData];
    [self downloadingContentAsAFile];
}


/// 向网络请求数据
- (void)fetchingContentAsData  {
    
    // 1.创建url
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    
    // 2.创建请求 并：设置缓存策略为每次都从网络加载 超时时间30秒
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:30];
    
    // 3.采用苹果提供的共享session
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    // 4.由系统直接返回一个dataTask任务
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 网络请求完成之后就会执行，NSURLSession自动实现多线程
        NSLog(@"%@",[NSThread currentThread]);
        if (data && (error == nil)) {
            // 网络访问成功
            NSLog(@"data=%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        } else {
            // 网络访问失败
            NSLog(@"error=%@",error);
        }
    }];
    
    // 5.每一个任务默认都是挂起的，需要调用 resume 方法
    [dataTask resume];
}

/// 文件下载
- (void)downloadingContentAsAFile {
    
    // 1.创建url
    NSURL *url = [NSURL URLWithString:@"https://hbimg.b0.upaiyun.com/9426df28cbdc87cfbf5073b870032c43af7a3f1513af4-V91vJM_fw658"];
    
    // 2.创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 3.创建会话，采用苹果提供全局的共享session
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    // 4.创建任务
    NSURLSessionDownloadTask *downloadTask = [sharedSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            // location:下载任务完成之后,文件存储的位置，这个路径默认是在tmp文件夹下!
            // 只会临时保存，因此需要将其另存
            NSLog(@"location:%@", location.path);
            
            // 采用模拟器测试，为了方便将其下载到Mac桌面
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *destinationPath = [documentsPath stringByAppendingPathComponent:url.lastPathComponent];
            NSError *fileError;
            [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:destinationPath error:&fileError];
            if (fileError == nil) {
                NSLog(@"file save success");
            } else {
                NSLog(@"file save error: %@",fileError);
            }
        } else {
            NSLog(@"download error:%@",error);
        }
    }];
    
    // 5.开启任务
    [downloadTask resume];
}


- (void)uploadingBodyContentUsingAnNSDataObject {
    
    // 创建要上传的 NSData
    NSURL *textFileURL = [NSURL fileURLWithPath:@"/path/to/file.txt"];
    NSData *data = [NSData dataWithContentsOfURL:textFileURL];
    
    // 创建请求
    NSURL *url = [NSURL URLWithString:@"https://www.example.com/"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    mutableRequest.HTTPMethod = @"POST";
    [mutableRequest setValue:[NSString stringWithFormat:@"%@", @(data.length)] forHTTPHeaderField:@"Content-Length"];
    [mutableRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionUploadTask *uploadTask = [defaultSession uploadTaskWithRequest:mutableRequest fromData:data];
    [uploadTask resume];
}


@end
