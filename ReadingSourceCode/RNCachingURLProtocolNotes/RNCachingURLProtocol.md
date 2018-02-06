# RNCachingURLProtocol


这个框架的功能是为 UIWebView 提供了一个简单的离线缓存机制：
- 你有一个 UIWebView 加载了有图片的网站
- 当处于联网状态下，执行正常的缓存逻辑
- 当处于离线状态下，展示上一次的成功加载过的网页内容

### 类似的实现
Matt Gallagher 是通过自定义 NSURLCache 来[实现离线缓存](http://cocoawithlove.com/2010/09/substituting-local-data-for-remote.html)的。[AFCache](https://github.com/artifacts/AFCache) 是通过自定义 NSURLProtocol 子类来实现的。但是在离线缓存的测试下都存在一定的问题。

### RNCachingURLProtocol 的实现逻辑

1. 自定义 NSURLProtocol 子类，重写下面几个方法：

```
- canInitWithRequest
- canonicalRequestForRequest
- startLoading
- stopLoading
```

2. 在接收到 URL 请求时：
2.1 先判断是否有网；
2.2 如果无网络且本地有缓存，则加载缓存，并回调 `client` 的几个代理方法；
2.3 如果无网络但是本地没有缓存，并直接回调 `client` 的代理方法 `URLProtocol:didFailWithError:`；
2.4 如果本地有网络，则创建 NSURLConnection 进行下载，并在相关代理方法中分别回调 `client` 的几个代理方法，请求完成时，缓存响应元数据和真正的数据到本地沙盒。

几点说明：
- 所有的缓存都保存到沙盒中的 `Library/Caches` 目录下，当缓存空间不足时，会自动被系统清除掉（注：我在项目中使用该库时，曾有用户反应我们的 app 占用空间非常大，所以后来改为 SDWebImage 进行缓存）。
- 因为 NSURLProtocol 会缓存所有拦截到的 HTTP 请求，所以并不适合有大量网络请求的 APP。
- 作者在一开始是使用 URL 的 hash 值来作为缓存路径，但是这样会导致很多相似的 URL 的 hash 值是重复的，所以后来改成了 MD5/SHA1 的算法。

### 使用方法

直接在应用启动时，也就是 `application:didFinishLaunchingWithOptions:` 方法中注册该类即可：

```
[NSURLProtocol registerClass:[RNCachingURLProtocol class]];
```

### NSURLProtocol 的使用

#### 1. 主要原理

在 URL Loading System 中，一个 NSURLProtocol 相当于一个请求拦截器，所有通过 NSURLConnection 和 NSURLSession 发起的请求都会经过所有注册过的 NSURLProtocol 子类。这些 NSURLProtocol 子类是按照注册的时间逆序来拦截请求的，最晚注册的 NSURLProtocol 类，最先拥有处理这个请求的权利。

当一个网络请求被发起时，系统会（逆序）依次询问每一个注册过的 NSURLProtocol 子类，“是否可以处理这个请求？”：
```
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	return YES;
}
```

`canInitWithRequest ` 方法返回 `YES` 后，系统又会调用`+ canonicalRequestForRequest: ` 方法获取一个最终的 `NSURLRequest` 对象：
```
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	// 我们可以在这里对这个 request 进行加工处理
	return request;
}
```

接着，系统就会在内部初始化这个要处理请求的 NSURLProtocol 实体类:
```
- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
	return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}
```

在 `-startLoading` 中，我们可以使用任何方法来对协议对象持有的 request 进行转发，包括 NSURLSession、 NSURLConnection 甚至使用 AFNetworking 等网络库，只要你在回调方法中记得回调 client（一个遵循 `<NSURLProtocolClient>` 协议的代理）的方法。当然，你也可以像 RNCachingURLProtocol 一样，直接读取缓存，然后在恰当的时机回调 client 的代理方法。
```
- (void)startLoading {
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[[NSURLSessionConfiguration alloc] init] delegate:self delegateQueue:nil];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:self.request];
	[task resume];
}
```

client 属性是 NSURLProtocol 对象跟 URL Loading System 打交道的桥梁，`<NSURLProtocolClient>` 协议包括以下几个方法，看起来跟 NSURLConnection 的代理方法很相似：

- URLProtocol:cachedResponseIsValid:
- URLProtocol:didCancelAuthenticationChallenge:
- URLProtocol:didFailWithError:
- URLProtocol:didLoadData:
- URLProtocol:didReceiveAuthenticationChallenge:
- URLProtocol:didReceiveResponse:cacheStoragePolicy:
- URLProtocol:wasRedirectedToRequest:redirectResponse:
- URLProtocolDidFinishLoading:



#### 注意点：

在有网的情况下，RNCachingURLProtocol 会将请求交给 NSURLConnection 来处理，NSURLConnection 也是 URL Loading System 的一部分，其发起的请求也会被 NSURLProtocol 拦截。所以为了防止递归调用造成死循环，RNCachingURLProtocol 在通过 NSURLConnection 发起请求前，在 HTTP header 中添加了 X-RNCache 字段作为标记，然后在 `canInitWithRequest` 方法中通过判断 HTTP header 是否有相关标记，来决定是否处理该请求。


要注意的是 NSURLProtocol 只能拦截 UIURLConnection、NSURLSession 和 UIWebView 中的请求，但是因为 WKWebView 是基于独立的 WebKit 进程，所以无法拦截 WKWebView 中发出的网络请求，也有开发者发现 WebKit 中有些私有 API 可以实现。

### 参考：
- [Drop-in Offline Caching for UIWebView (and NSURLProtocol)](http://robnapier.net/offline-uiwebview-nsurlprotocol)
- [rnapier/RNCachingURLProtocol](https://github.com/rnapier/RNCachingURLProtocol)