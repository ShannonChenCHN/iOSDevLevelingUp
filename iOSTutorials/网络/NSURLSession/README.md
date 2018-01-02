
# 网络编程之 NSURLSession


### 一、简介

iOS 7 和 Mac OS X 10.9 Mavericks 中一个显著的变化就是对 Foundation 的 [URL Loadin System](https://developer.apple.com/documentation/foundation/url_loading_system?language=objc) 的彻底重构。

NSURLConnection 作为 Core Foundation / CFNetwork 框架的 API 之上的一个抽象，在 2003 年，随着第一版的 Safari 的发布就发布了。NSURLConnection 这个名字，实际上是指代的 Foundation 框架的 URL Loading System 系统中一系列有关联的组件：NSURLRequest、NSURLResponse、NSURLProtocol、 NSURLCache、 NSHTTPCookieStorage、NSURLCredentialStorage 以及同名类 NSURLConnection。

在 2013 的 WWDC 上，苹果推出了 NSURLConnection 的继任者：NSURLSession。现在使用大多数主流第三方框架都已经从 NSURLConnection 迁移到了 NSURLSession，比如 AFNetworking、SDWebImage 等等都使用了 NSURLSession。     

和 NSURLConnection 一样，NSURLSession 指的也不仅是同名类 NSURLSession，还包括一系列相互关联的类。NSURLSession 包括了与之前相同的组件，NSURLRequest 与 NSURLCache，但是把 NSURLConnection 替换成了 NSURLSession、NSURLSessionConfiguration 以及 NSURLSessionTask 的 3 个子类：NSURLSessionDataTask，NSURLSessionUploadTask，NSURLSessionDownloadTask。                                                                                       

![](https://koenig-media.raywenderlich.com/uploads/2017/06/url_session_diagram_1.png)


### 二、NSURLSession 的使用
NSURLSession 负责发送请求和接收响应，

#### 1. NSURLSessionTask

![](https://www.objccn.io/images/issues/issue-5/NSURLSession.png)


#### 2. NSURLSession 的 delegate 方法

#### 3. NSURLSessionConfiguration

### 三、NSURLSession 和 NSURLConnection 的对比

问题：
1. 什么是 URL Loading System？

2. NSURLConnection 与 NSURLSession 的区别？

3. 为什么 NSURLConnection 会被 NSURLSession 所替代？

4. 如何使用 NSURLConnection 和 NSURLSession

5. 何时需要使用以及如何使用 NSURLProtocol？

6. AFNetworking 为什么要对 NSURLConnection/NSURLSession 进行封装？它是如何封装的？

7. AFNetworking 2.x 和 AFNetworking 3.x 的区别是什么？

8. 为什么 SDWebImage 早期版本中使用 NSURLConnection 异步下载时，需要手动启动 Runloop 来实现线程的保活，而现在版本中使用 NSURLSession 时，却不需要呢？


### 参考：
- [NSURLSession and NSDefaultRunLoopMode](https://stackoverflow.com/questions/20098106/nsurlsession-and-nsdefaultrunloopmode)
- [NSURLSession与NSURLConnection区别](http://www.guiyongdong.com/2016/11/18/NSURLSession与NSURLConnection区别/)
- [NSURLSession VS. NSURLConnection](https://stackoverflow.com/questions/33919862/nsurlconnection-vs-nsurlsession)
- [iOS网络基础——NSURLSession使用详解(一般访问、文件下载、上传)](https://www.jianshu.com/p/2bd9cb569fc2)
- [WWDC Session 705: "What’s New in Foundation Networking"](http://asciiwwdc.com/2013/sessions/705)