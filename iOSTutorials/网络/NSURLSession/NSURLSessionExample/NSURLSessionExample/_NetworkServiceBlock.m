//
//  _NetworkServiceBlock.m
//  NSURLSessionExample
//
//  Created by ShannonChen on 2018/1/31.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "_NetworkServiceBlock.h"


#define SCFileBoundary @"MalJob"
#define SCNewLine @"\r\n"
#define SCEncode(str) [str dataUsingEncoding:NSUTF8StringEncoding]

@implementation _NetworkServiceBlock


/// 向网络请求数据
- (void)fetchingContentAsData  {
    
    // 1.创建url
    NSURL *url = [NSURL URLWithString:@"http://7vihfk.com1.z0.glb.clouddn.com/photo-1457369804613-52c61a468e7d.jpeg"];
    
    // 2.创建请求 并设置缓存策略为每次都从网络加载，超时时间30秒
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:30];
//    request.cachePolicy = NSURLRequestReturnCacheDataDontLoad; // 支持离线缓存
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    NSLog(@"%@, %@", cachedResponse.response, cachedResponse.data);
    
    // 3.创建 task
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
//    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 网络请求完成之后就会执行，NSURLSession自动实现多线程
        NSLog(@"%@",[NSThread currentThread]);
        if (data && (error == nil)) {
            // 网络访问成功
            NSLog(@"data=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        } else {
            // 网络访问失败
            NSLog(@"error=%@", error);
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

/// 通过提交 form 表单的形式上传文件
/// iOS 表单上传文件 https://www.jianshu.com/p/2c3644202a98
/// 四种常见的 POST 提交数据方式对应的content-type取值 http://www.cnblogs.com/wushifeng/p/6707248.html
/// iOS之网络请求之AFN表单上传之form-data http://blog.csdn.net/kws959844005/article/details/52487358
- (void)uploadingFormDataUsingAnNSDataObject {
    
    // 1.创建 url，参数
    NSURL *url = [NSURL URLWithString:@"https://www.example.com"];
    NSDictionary *params = @{
                             @"name" : @"xxxx",
                             @"password" : @"xxxxx",
                             };
    
    // 2.创建一个POST请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 3. 获取文件信息
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"filename" withExtension:@"txt"];
    NSData *fileData = [NSData dataWithContentsOfURL:filePath];
    NSString *filename = @"file.txt";
    NSString *mimeType = [self getMIMETypeOfFileWithPath:filePath];
    
    // 4.设置请求体
    NSMutableData *body = [NSMutableData data];
    
    // 4.1.文件参数
    [body appendData:SCEncode(@"--")];
    [body appendData:SCEncode(SCFileBoundary)];
    [body appendData:SCEncode(SCNewLine)];
    
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"", filename];
    [body appendData:SCEncode(disposition)];
    [body appendData:SCEncode(SCNewLine)];
    
    NSString *type = [NSString stringWithFormat:@"Content-Type: %@", mimeType];
    [body appendData:SCEncode(type)];
    [body appendData:SCEncode(SCNewLine)];
    
    [body appendData:SCEncode(SCNewLine)];
    [body appendData:fileData];
    [body appendData:SCEncode(SCNewLine)];
    
    // 4.2.非文件参数
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [body appendData:SCEncode(@"--")];
        [body appendData:SCEncode(SCFileBoundary)];
        [body appendData:SCEncode(SCNewLine)];
        
        NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", key];
        [body appendData:SCEncode(disposition)];
        [body appendData:SCEncode(SCNewLine)];
        
        [body appendData:SCEncode(SCNewLine)];
        [body appendData:SCEncode([obj description])];
        [body appendData:SCEncode(SCNewLine)];
    }];
    
    // 4.3.结束标记
    [body appendData:SCEncode(@"--")];
    [body appendData:SCEncode(SCFileBoundary)];
    [body appendData:SCEncode(@"--")];
    [body appendData:SCEncode(SCNewLine)];
    
    request.HTTPBody = body;
    
    // 5.设置请求头(告诉服务器这次传给你的是form表单文件数据，告诉服务器现在发送的是一个文件上传请求)
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", SCFileBoundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // 6. 发起请求
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    
    [dataTask resume];
}

/// 上传内存中的 NSData 对象
- (void)uploadingBodyContentUsingAnNSDataObject {
    
    // 1. 创建要上传的 NSData
    NSURL *textFileURL = [NSURL fileURLWithPath:@"/path/to/file.txt"];
    NSData *data = [NSData dataWithContentsOfURL:textFileURL];
    
    // 2. 创建请求
    NSURL *url = [NSURL URLWithString:@"https://www.example.com/"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    
    // 2.1 设置请求方式
    mutableRequest.HTTPMethod = @"POST";
    
    // 2.2 设置请求头（告诉服务器这次传给你的是 text 文件数据）
    [mutableRequest setValue:[NSString stringWithFormat:@"%@", @(data.length)] forHTTPHeaderField:@"Content-Length"];
    [mutableRequest setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    
    // 3.创建 session，采用苹果提供全局的共享session
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    // 4. 创建任务
    NSURLSessionUploadTask *uploadTask = [sharedSession uploadTaskWithRequest:mutableRequest
                                                                     fromData:data
                                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                
                                                                
                                                            }];
    [uploadTask resume];
}

/// 上传本地文件
- (void)uploadingBodyContentUsingAFile {
    
    // 获取磁盘文件地址
    NSURL *textFileURL = [NSURL fileURLWithPath:@"/path/to/file.txt"];
    
    // 创建请求
    NSURL *url = [NSURL URLWithString:@"https://www.example.com/"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    mutableRequest.HTTPMethod = @"POST";
    
    // 创建 session，采用苹果提供全局的共享session
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    NSURLSessionUploadTask *uploadTask = [sharedSession uploadTaskWithRequest:mutableRequest
                                                                     fromFile:textFileURL
                                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                
                                                            }];
    [uploadTask resume];
}

#pragma mark - Helper

- (NSString *)getMIMETypeOfFileWithPath:(NSURL *)url {
    
    // 1.创建一个请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2.发送请求（返回响应）
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    // 3.获得MIMEType
    return response.MIMEType;
}

@end
