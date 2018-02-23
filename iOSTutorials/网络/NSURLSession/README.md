# NSURLSession 

[NSURLSession 相关的完整示例代码](https://github.com/ShannonChenCHN/iOSLevelingUp/tree/master/iOSTutorials/网络/NSURLSession)

### 一、简介


NSURLConnection 作为 Core Foundation / CFNetwork 框架的 API 之上的一个抽象，在 2003 年，随着第一版的 Safari 的发布就发布了。NSURLConnection 这个名字，

iOS 7 和 Mac OS X 10.9 Mavericks 中一个显著的变化就是对 Foundation 的 [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system?language=objc) 的彻底重构。

在 2013 的 WWDC 上，苹果推出了 NSURLConnection 的继任者：NSURLSession。NSURLSession 指的不仅是同名类 NSURLSession，实际上是指代的 Foundation 框架的 URL Loading System 系统中一系列有关联的组件：NSURLRequest、NSURLResponse、NSURLProtocol、 NSURLCache、 NSHTTPCookieStorage、NSURLCredentialStorage 以及同名类 NSURLSession、NSURLSessionConfiguration 以及 NSURLSessionTask 的 3 个子类：NSURLSessionDataTask，NSURLSessionUploadTask，NSURLSessionDownloadTask。

现在使用大多数主流第三方框架都已经从 NSURLConnection 迁移到了 NSURLSession，比如 AFNetworking、SDWebImage 等等如今使用的都是 NSURLSession。


![](../images/url_session_diagram_1.png)



### 二、NSURLSession 的使用
NSURLSession 主要是用来处理 App 和服务器之间的网络数据的传输。根据 NSURLSession 的创建方式，可以将 session 的行为分为四种：

- The singleton shared session：系统提供的默认共享配置，支持基本的请求。其局限性在于，不能设置 delegate 和自定义 session configuration，这也就意味着你不能进行一些自定义操作，比如断点下载、自定义请求行为、应用后台下载等等。这种 session 可以通过 `[NSURLSession sharedSession]` 来创建。
- Default sessions：跟 shared session 类似，系统会提供一些默认的共享配置，但是这种 session 可以设置 delegate 来进行断点下载等操作。这种 session 可以通过 `NSURLSessionConfiguration ` 的  `defaultSessionConfiguration` 方法来创建。 
- Ephemeral sessions：跟 default sessions 类似，但是不会将缓存、cookie、凭证等保存到本地磁盘上。这种 session 可以通过 `NSURLSessionConfiguration ` 的 `ephemeralSessionConfiguration` 方法来创建。 
- Background sessions：这种 session 能够让你的 APP 即便不再运行，也可以让后台驻留程序帮你上传、下载任务。可以通过 `NSURLSessionConfiguration ` 的 `backgroundSessionConfiguration: ` 方法来创建 background session。

创建 NSURLSession 发起请求的步骤大致如下：

1. 创建一个 NSURLSessionConfiguration 对象。
2. 创建一个 NSURLSession 对象，可以指定 session configuration 和 delegate。
3. 创建一个 NSURLRequest 对象，并使用创建好的 NSURLSession 对象获取一个代表请求的 session task 对象。这个 task 对象可能是 `NSURLSessionTask` 的三个子类之一——NSURLSessionDataTask， NSURLSessionUploadTask，或者 NSURLSessionDownloadTask。每个 task 在初始时是处于挂起状态的，当调用了 `resume` 方法后，它就真正开始发起请求了。
4. 接下来，session 就会在合适的时机依次发送消息给它的代理。详见 [NSURLSession - Class API Reference](https://developer.apple.com/documentation/foundation/nsurlsession?language=objc)。

示例代码：

```
    // 1.创建url
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    
    // 2.创建 request，并设置缓存策略为每次都从网络加载，超时时间30秒
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:30];
    
    // 3.创建 NSURLSessionConfiguration
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // 4. 创建 NSURLSession
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    // 5. 创建 NSURLSessionDataTask
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
    [dataTask resume];
```


#### 1. NSURLSessionTask

Task 是由 Session 创建的，Session 会保持对 Task 的一个强引用，直到 Task 完成或者出错才会释放。通过 NSURLSessionTask 可以获得一个 Task 的各种状态，以及对 Task 进行取消，挂起，继续等操作。

NSURLSession 提供了三种不同的 task：

- Data tasks：发送和接收 `NSData` 形式的数据。Data tasks 主要用来发送短暂的、有交互性的请求。Data tasks 可以分次返回数据，也可以一次性返回所有的数据。
- Download tasks：获取文件形式的数据，下载文件到本地，支持后台下载。
- Upload tasks：以文件的形式发送数据给服务器，也支持后台下载。

![](../images/NSURLSession.png)

所有的 task 都是可以取消，暂停或者恢复的。当一个 download task 取消时，可以通过选项来创建一个恢复数据（resume data），然后可以传递给下一次新创建的 download task，以便继续之前的下载。

`NSURLSessionTask` 的三个常用方法：

``` Objective-C
- (void)suspend;
- (void)resume;
- (void)cancel;
```

`NSURLSessionDownloadTask` 还提供了支持断点下载的方法（需要服务器也支持才能进行文件的断点下载）：

```
/// 取消正在下载的操作，并保存临时数据
- (void)cancelByProducingResumeData:(void (^)(NSData * _Nullable resumeData))completionHandler; 
```
然后再在下次继续下载操作时，调用 `NSURLSession` 的 `downloadTaskWithResumeData: completionHandler:` 方法即可实现断点下载。


#### 2. NSURLSession 的 delegate 方法

#### 2.1 NSURLSessionDelegate：用来处理 Session 层次的事件

```

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;

```

#### 2.2 NSURLSessionTaskDelegate：是使用代理的时候，任何种类 task 都要实现的代理，跟特定 task 有关的回调


```
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;
```

#### 2.3 NSURLSessionDataDelegate：特别用来处理 dataTask 的事件，跟 task 发送数据给 delegate 有关的方法

```
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler;

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(nonnull NSCachedURLResponse *)proposedResponse completionHandler:(nonnull void (^)(NSCachedURLResponse * _Nullable))completionHandler;
```
 
#### 2.4 NSURLSessionDownloadDelegate：downloadTask 的回调方法，也就是跟下载数据到本地相关的操作

```

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;


/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
```
 
#### 3. NSURLSessionConfiguration

NSURLSessionConfiguration 拥有 20 个配置属性。熟练掌握这些配置属性的用处，可以让应用程序充分地利用其网络环境。NSURLSessionConfiguration 提供的配置项包括基本网络配置、cookie 策略、安全策略、缓存策略、自定义协议类等等：

- HTTPAdditionalHeaders
- networkServiceType
- allowsCellularAccess
- timeoutIntervalForRequest
- requestCachePolicy

NSURLSessionConfiguration 有三个类工厂方法，这很好地说明了 NSURLSession 设计时所考虑的不同的使用场景：

- +defaultSessionConfiguration 返回一个标准的 configuration，这个配置实际上与 NSURLConnection 的网络堆栈（networking stack）是一样的，具有相同的共享 NSHTTPCookieStorage，共享 NSURLCache 和共享 NSURLCredentialStorage。

- +ephemeralSessionConfiguration 返回一个预设配置，这个配置中不会对缓存，Cookie 和证书进行持久性的存储。这对于实现像秘密浏览这种功能来说是很理想的。

- +backgroundSessionConfiguration:(NSString *)identifier 的独特之处在于，它会创建一个后台 session。后台 session 不同于常规的，普通的 session，它甚至可以在应用程序挂起，退出或者崩溃的情况下运行上传和下载任务。初始化时指定的标识符，被用于向任何可能在进程外恢复后台传输的守护进程（daemon）提供上下文。


#### 4. 其他相关类

- NSURL：封装 URL 信息的类。
- NSURLRequest：封装 URL 请求元数据的类，内容包括 URL、request method 等等.
- NSURLResponse：封装服务器返回的响应元数据的类，内容包括响应头、响应数据的 MIME type 和 length 等等.
- NSHTTPURLResponse：在 NSURLResponse 的基础上添加了 HTTP 请求所特有的响应信息，比如响应头。
- NSCachedURLResponse： 封装了一个 NSURLResponse 对象和服务器返回的实体 data，用于缓存。



### 四、NSURLSession 和 NSURLConnection 的对比，为什么 NSURLConnection 会被 NSURLSession 所替代？



NSURLSession 的优势：

- NSURLSession 支持 [HTTP/2.0 协议](https://zh.wikipedia.org/wiki/HTTP/2#HTTP/2%E4%B8%8EHTTP/1.1%E6%AF%94%E8%BE%83)
- 在处理下载任务的时候可以直接把数据下载到磁盘
- 支持后台下载、上传
- 同一个 session 发送多个请求，只需要建立一次连接（HTTP 1.1 的 pipeline 和 HTTP 2.0 的多路复用）
- 提供了全局的 session 并且可以统一配置，使用更加方便
- 内部实现了多线程异步请求，效率更高，使用更简单

#### 1. 请求任务

NSURLConnection 只有一个 NSURLConnection 这一个类来进行网络请求。

NSURLsessionTask 是一个抽象类，它有 3 个实体子类可以直接使用：NSURLSessionDataTask、NSURLSessionUploadTask、NSURLSessionDownloadTask。这 3 个子类分别封装了现代程序三个最基本的网络任务：获取数据（比如 JSON 或者 XML），上传文件和下载文件。借助这 3 个子类，我们可以很轻松地实现对应的请求任务。

#### 2. 请求方法的控制
NSURLConnection实例化对象，实例化开始，默认请求就发送(同步发送),不需要调用start方法。而cancel可以停止请求的发送，停止后不能继续访问，需要创建新的请求。

NSURLSession有三个控制方法，取消(cancel)、暂停(suspend)、继续(resume)，暂停以后可以通过继续恢复当前的请求任务。

#### 3. 请求的配置信息

原来的 NSURLConnection 只能通过 NSMutableURLRequest 来设置网络请求层的设置选项。

NSURLSession 的构造方法`sessionWithConfiguration:delegate:delegateQueue`中有一个NSURLSessionConfiguration 类的参数可以设置配置信息，其决定了cookie，安全和高速缓存策略，最大主机连接数，资源管理，网络超时等配置。

#### 4. 代理

NSURLConnection 有三种代理协议：

- NSURLConnectionDelegate
- NSURLConnectionDataDelegate
- NSURLConnectionDownloadDelegate

NSURLConnection 有四种代理协议：

- NSURLSessionDelegate
- NSURLSessionTaskDelegate
- NSURLSessionDataDelegate
- NSURLSessionDownloadDelegate

更详细的内容可以看看 Mattt Thompson 整理的一个完整的[映射表](https://gist.github.com/floriankugler/6870499)。


#### 5. 下载任务方式
NSURLConnection下载文件时，先是将整个文件下载到内存，然后再写入到沙盒，如果文件比较大，就会出现内存暴涨的情况。

而使用NSURLSessionUploadTask下载文件，会默认下载到沙盒中的tem文件中，不会出现内存暴涨的情况，但是在下载完成后会把tem中的临时文件删除，需要在初始化任务方法时，在completionHandler回调中增加保存文件的代码。



#### 6. 断点续传的方式

NSURLConnection进行断点下载，通过设置访问请求的HTTPHeaderField的Range属性，开启运行循环，NSURLConnection的代理方法作为运行循环的事件源，接收到下载数据时代理方法就会持续调用，并使用NSOutputStream管道流进行数据保存。

NSURLSession进行断点下载，当暂停下载任务后，如果downloadTask（下载任务）为非空，调用cancelByProducingResumeData:(void (^)(NSData *resumeData))completionHandler这个方法，这个方法接收一个参数，完成处理代码块，这个代码块有一个NSData参数resumeData，如果resumeData非空，我们就保存这个对象到视图控制器的resumeData属性中，在点击再次下载时，通过调用[ [self.session downloadTaskWithResumeData:self.resumeData]resume]方法进行继续下载操作。




### 五、问题

1.如何取消网络请求？

可以通过调用 `NSURLSessionDataTask` 的 `cancel` 方法来取消已经启动的 task。

调用 `NSURLSessionDataTask` 的 `cancel` 方法时，这个方法会立即返回，并且标记这个 task 已经被 cancell 掉了。一旦一个 task 被标记为 cancell 掉了，这个 task 的 delegate 就会收到 `URLSession:task:didCompleteWithError: ` 代理方法回调，其中的  `error` 参数中会有一个错误码 `NSURLErrorCancelled`。

在某些情况下，可能在被 cancel 的 task 确认被 cancel 前，其 delegate 就已收到代理消息了。

实际上，对于服务器来说，当客户端在请求一发出就取消了的时候，也就是说服务器还没有接收到，但是请求发出去了时，有些服务器会判断连接是否已断开。

> 参考：   
> 
> - [NSURLSessionTask - Apple Documentation](https://developer.apple.com/documentation/foundation/nsurlsessiontask/1411591-cancel)
> 
> - [iOS取消网络请求的正确姿势](https://www.jianshu.com/p/96272c18150e)

2.为什么 SDWebImage 早期版本中使用 NSURLConnection 异步下载时，需要手动启动 Runloop 来实现线程的保活，而现在版本中使用 NSURLSession 时，却不需要呢？


### 参考资料：
- [NSURLSession - Class Reference](https://developer.apple.com/documentation/foundation/nsurlsession?language=objc)
- [URLSession - objc.io](https://objccn.io/issue-5-4/)
- [URLSession Tutorial: Getting Started - Ray Wenderlich](https://www.raywenderlich.com/158106/urlsession-tutorial-getting-started)
- [NSURLSession与NSURLConnection区别](http://www.guiyongdong.com/2016/11/18/NSURLSession与NSURLConnection区别/)
- [iOS网络基础——NSURLSession使用详解(一般访问、文件下载、上传)](https://www.jianshu.com/p/2bd9cb569fc2)
- [NSURLSessionDownloadTask的深度断点续传](http://www.cnblogs.com/itlover2013/p/5454179.html)
- [浅析 iOS 应用开发中的断点续传](https://www.ibm.com/developerworks/cn/mobile/mo-cn-breakpoint/index.html)：这篇文章详细介绍了断点续传的原理，并通过代码示例演示了如何使用 AFNetworking 和 NSURLConnection 实现断点下载任务。
- [WWDC Session 705: "What’s New in Foundation Networking"](http://asciiwwdc.com/2013/sessions/705)
- [Apple WWDC 2015 - 711 - Networking with NSURLSession](https://developer.apple.com/videos/play/wwdc2015-711/)
- [URLSession Waiting For Connectivity](https://useyourloaf.com/blog/urlsession-waiting-for-connectivity/)：iOS 新推出的 API，可以设置在使用 NSURLSession 发起请求前先检查网络是否可用，不可用就等待
- [别说你会AFNetworking3.0/NSURLSession](https://www.jianshu.com/p/5969bbb4af9f)：作者是饿了么移动架构师王朝成（圣迪）
- [HTTP,HTTP2.0,SPDY,HTTPS你应该知道的一些事](http://www.alloyteam.com/2016/07/httphttp2-0spdyhttps-reading-this-is-enough/)
- [移动 APP 网络优化概述](http://blog.cnbang.net/tech/3531/)
- [NSURLSession之使用Keep-Alive长连接](https://zhongwuzw.github.io/2016/11/12/NSURLSession之使用keep-alive长连接/)
- [HTTP 中的 Keep-Alive，pipelining 和多路复用](https://github.com/ShannonChenCHN/iOSLevelingUp/issues/37#issuecomment-367964439)
