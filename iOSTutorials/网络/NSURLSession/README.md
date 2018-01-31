# NSURLSession

### 一、简介

iOS 7 和 Mac OS X 10.9 Mavericks 中一个显著的变化就是对 Foundation 的 [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system?language=objc) 的彻底重构。

NSURLConnection 作为 Core Foundation / CFNetwork 框架的 API 之上的一个抽象，在 2003 年，随着第一版的 Safari 的发布就发布了。NSURLConnection 这个名字，实际上是指代的 Foundation 框架的 URL Loading System 系统中一系列有关联的组件：NSURLRequest、NSURLResponse、NSURLProtocol、 NSURLCache、 NSHTTPCookieStorage、NSURLCredentialStorage 以及同名类 NSURLConnection。

在 2013 的 WWDC 上，苹果推出了 NSURLConnection 的继任者：NSURLSession。现在使用大多数主流第三方框架都已经从 NSURLConnection 迁移到了 NSURLSession，比如 AFNetworking、SDWebImage 等等都使用了 NSURLSession。     

和 NSURLConnection 一样，NSURLSession 指的也不仅是同名类 NSURLSession，还包括一系列相互关联的类。NSURLSession 包括了与之前相同的组件，NSURLRequest 与 NSURLCache，但是把 NSURLConnection 替换成了 NSURLSession、NSURLSessionConfiguration 以及 NSURLSessionTask 的 3 个子类：NSURLSessionDataTask，NSURLSessionUploadTask，NSURLSessionDownloadTask。                                                                                       

![](../images/url_session_diagram_1.png)



### 二、NSURLSession 的使用
NSURLSession 负责发送请求和接收响应，

#### 1. NSURLSessionTask

![](../images/NSURLSession.png)


#### 2. NSURLSession 的 delegate 方法

#### 3. NSURLSessionConfiguration

### 四、NSURLSession 和 NSURLConnection 的对比，为什么 NSURLConnection 会被 NSURLSession 所替代？

### 五、问题

1. 如何取消网络请求？

可以通过调用 `NSURLSessionDataTask` 的 `cancel` 方法来取消已经启动的 task。

调用 `NSURLSessionDataTask` 的 `cancel` 方法时，这个方法会立即返回，并且标记这个 task 已经被 cancell 掉了。一旦一个 task 被标记为 cancell 掉了，这个 task 的 delegate 就会收到 `URLSession:task:didCompleteWithError: ` 代理方法回调，其中的  `error` 参数中会有一个错误码 `NSURLErrorCancelled`。

在某些情况下，可能在被 cancel 的 task 确认被 cancel 前，其 delegate 就已收到代理消息了。

实际上，对于服务器来说，当客户端在请求一发出就取消了的时候，也就是说服务器还没有接收到，但是请求发出去了时，有些服务器会判断连接是否已断开。

> 参考：
> - [NSURLSessionTask - Apple Documentation](https://developer.apple.com/documentation/foundation/nsurlsessiontask/1411591-cancel)
> - [iOS取消网络请求的正确姿势](https://www.jianshu.com/p/96272c18150e)

2. 为什么 SDWebImage 早期版本中使用 NSURLConnection 异步下载时，需要手动启动 Runloop 来实现线程的保活，而现在版本中使用 NSURLSession 时，却不需要呢？


### 参考资料：
- [NSURLSession and NSDefaultRunLoopMode](https://stackoverflow.com/questions/20098106/nsurlsession-and-nsdefaultrunloopmode)
- [NSURLSession与NSURLConnection区别](http://www.guiyongdong.com/2016/11/18/NSURLSession与NSURLConnection区别/)
- [NSURLSession VS. NSURLConnection](https://stackoverflow.com/questions/33919862/nsurlconnection-vs-nsurlsession)
- [iOS网络基础——NSURLSession使用详解(一般访问、文件下载、上传)](https://www.jianshu.com/p/2bd9cb569fc2)
- [WWDC Session 705: "What’s New in Foundation Networking"](http://asciiwwdc.com/2013/sessions/705)
- [NSURLSessionDownloadTask的深度断点续传](http://www.cnblogs.com/itlover2013/p/5454179.html)
