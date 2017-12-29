# NSURLConnection


### 一、简介

在 iOS 原生开发中，我们通常需要借助 [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system?language=objc) 提供的网络基础架构来实现网络请求。早期的 URL Loading System 是基于 NSURLConnection 的，在 2013 的 WWDC 上，苹果推出了 NSURLConnection 的继任者：NSURLSession。SDWebImage 3.x 和 AFNetworking 1.x 中就用到了 NSURLConnection。

NSURLConnection 作为 Core Foundation / CFNetwork 框架的 API 之上的一个抽象，在 2003 年第一版的 Safari 发布时就出世了。NSURLConnection 这个名字，实际上是指代的 Foundation 框架的 URL Loading System 中一系列有关联的组件：NSURLRequest、NSURLResponse、NSURLProtocol、 NSURLCache、 NSHTTPCookieStorage、NSURLCredentialStorage 以及同名类 NSURLConnection。



### 二、使用 NSURLConnection 发起 HTTP 请求

#### 1.相关类
（1） NSURL：请求地址，定义一个网络资源路径；

（2）NSURLRequest/NSMutableURLRequest：根据 NSURL 建立一个请求。

NSMutableURLRequest 是 NSURLRequest 的子类，常用方法有：

- `setCachePolicy:`：设置缓存策略
- `setTimeoutInterval:`：设置请求超时等待时间（超过这个时间就算超时，请求失败）
- `setHTTPMethod:`：设置请求方法（比如GET和POST），默认是 GET
- `setHTTPBody:`：设置请求体
- `setValue:forHTTPHeaderField:`：设置请求头


（3）NSURLConnection：用来管理 request 的对象，可以用来启动和停止 request
（4）NSJSONSerialization：服务器返回 JSON 格式的消息时，因为 NSURLConnection 回调返回的数据是 NSData，所以需要通过 NSJSONSerialization 进行反序列化。

#### 2. 使用 NSURLConnection 发起 HTTP 请求的步骤

（1）设置请求路径：创建一个 NSURL 对象，设置请求路径

（2）创建请求对象：传入NSURL创建一个 NSURLRequest 对象，设置请求头和请求体

（3）发送请求：使用 NSURLConnection 发送NSURLRequest

   - 同步请求：阻塞当前线程，直到服务器返回，返回的消息直接通过返回值返回
   - 异步请求：异步执行，不阻塞当前线程，返回值通过 delegate 方法或者 block 回调
（4）收到响应：服务器返回响应消息内容会被转成 NSData 数据类型，因为事先已经约定好了数据格式，因此可以直接将响应消息内容反序列化为实际的类型，例如：json（字典或数组）、.plist（字典或数组）、text、xml等。

![](http://images.cnitblog.com/i/450136/201406/281617337427186.png)

#### 3. 示例代码

```
    // 1. 设置请求路径
    NSURL *url = [NSURL URLWithString:@"https://s-media-cache-ak0.pinimg.com/1200x/2e/0c/c5/2e0cc5d86e7b7cd42af225c29f21c37f.jpg"];
    
    // 2. 创建请求对象（NSURLRequest 默认的请求方式是 GET）
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 60;
    request.HTTPMethod = @"GET";
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
    forHTTPHeaderField:@"Accept"];


	// 3. 发起请求
    // 当服务器有返回数据的时候调用会开一条新的线程去发送请求，主线程继续往下走，当拿到服务器的返回数据的数据的时候再回 调block，执行回调 block 代码段。这种情况不会卡住主线程。
    // 这里的队列的作用是决定这个回调 block 操作放在哪个线程执行？
    NSOperationQueue *queueToExecuteCompletionHandler = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queueToExecuteCompletionHandler
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
         NSLog(@"--收到响应，大小：%@--",@(data.length));
    }];
```

#### 4. NSURLConnection Protocols

NSURLConnection 有以下三种协议：

- NSURLConnectionDelegate：负责处理 credential 设置和 connection 失败时的回调
- NSURLConnectionDataDelegate：继承 NSURLConnectionDelegate，用于提供服务器返回的响应信息，以及提供上传和下载时的进度信息、数据。如果不使用 Newsstand Kit 的话，必须实现该协议
- NSURLConnectionDownloadDelegate：继承 NSURLConnectionDelegate，如果你使用了 Newsstand Kit，你可以通过实现该协议来获取相关回调信息，该协议提供了断点下载（continuing interrupted file downloads）信息的回调和下载完成时的回调。这个协议是专门跟 Newsstand Kit 的 `downloadWithDelegate:` 搭配起来使用的，如果你是直接创建并使用 NSURLConnection 的话，就不要实现这个协议，实现 NSURLConnectionDataDelegate 即可。


一般我们在使用 NSURLConnection 发起请求时， 其 delegate 中只需要实现 NSURLConnectionDelegate 和 NSURLConnectionDataDelegate 中的以下几个方法即可：

```
/// 请求失败时回调
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error; 

/// 当接收到服务器的响应（连通了服务器）时会调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

/// 当接收到服务器的数据时会调用（不一定一次就能传完，可能会被调用多次，每次只传递部分数据）
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

/// 当请求成功完成时调用该方法
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;


```


### 三、使用注意点
在子线程使用 NSURLConnection 发起异步请求时，需要手动开启 [Runloop](https://github.com/ShannonChenCHN/iOSLevelingUp/issues/16#issuecomment-353788365) 以防止线程在请求返回前退出。详见 SDWebImage 和 AFNetworking 源码。


### 参考：
- [iOS开发网络篇—NSURLConnection基本使用](https://www.cnblogs.com/wendingding/p/3813572.html)
- [iOS网络1——NSURLConnection使用详解](http://www.cnblogs.com/mddblog/p/5134783.html)
- [NSURLConnection - API Documentation](https://developer.apple.com/documentation/foundation/nsurlconnection?language=objc)
