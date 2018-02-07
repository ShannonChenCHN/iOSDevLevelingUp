# NSURLProtocol


#### 一、主要原理

在 URL Loading System 中，一个 NSURLProtocol 相当于一个请求拦截器，所有通过 NSURLConnection 和 NSURLSession 发起的请求都会经过所有注册过的 NSURLProtocol 子类。这些 NSURLProtocol 子类是按照注册的时间逆序来拦截请求的，最晚注册的 NSURLProtocol 类，最先拥有处理这个请求的权利。所以当在 `-application:didFinishLoadingWithOptions:` 方法中调用 `[NSURLProtocol registerClass:[MyURLProtocol class]];` 时，你自己写的 protocol 比其他内建的 protocol 拥有更高的优先级。

当一个网络请求被发起时，系统（内部有一个 `_NSURLSessionLocal` 类）会依次询问每一个注册过的 NSURLProtocol 子类（按照注册时间逆序），“是否可以处理这个请求？”：

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

- `- URLProtocol:cachedResponseIsValid:`
- `- URLProtocol:didCancelAuthenticationChallenge:`
- `- URLProtocol:didFailWithError:`
- `- URLProtocol:didLoadData:`
- `- URLProtocol:didReceiveAuthenticationChallenge:`
- `- URLProtocol:didReceiveResponse:cacheStoragePolicy:`
- `- URLProtocol:wasRedirectedToRequest:redirectResponse:`
- `- URLProtocolDidFinishLoading:`

最后，为了使用 NSURLProtocol 子类，需要向 URL Loading System 进行注册。

```
[NSURLProtocol registerClass:[MyURLProtocol class]];
```


#### 2.注意点：

- 在有网的情况下，RNCachingURLProtocol 会将请求交给 NSURLConnection 来处理，NSURLConnection 也是 URL Loading System 的一部分，其发起的请求也会被 NSURLProtocol 拦截。所以为了防止递归调用造成死循环，RNCachingURLProtocol 在通过 NSURLConnection 发起请求前，在 HTTP header 中添加了 X-RNCache 字段作为标记，然后在 `canInitWithRequest` 方法中通过判断 HTTP header 是否有相关标记，来决定是否处理该请求。


- 要注意的是 NSURLProtocol 只能拦截 UIURLConnection、NSURLSession 和 UIWebView 中的请求，但是因为 WKWebView 是基于独立的 WebKit 进程，所以无法拦截 WKWebView 中发出的网络请求，后来也有开发者发现 WebKit 中有些私有 API 可以实现。

- 针对 HTTP 请求重定向，也要记得回调 client 的相应代理方法。

### 启发

- NSURLProtocol 的设计理念


### 参考
- [iOS 开发中使用 NSURLProtocol 拦截 HTTP 请求](https://draveness.me/intercept)
- [NSURLProtocol - NSHipster](http://nshipster.cn/nsurlprotocol/)
- [NSURLProtocol Class Reference](https://developer.apple.com/documentation/foundation/nsurlprotocol)
- [CustomHTTPProtocol - Guides and Sample Code](https://developer.apple.com/library/content/samplecode/CustomHTTPProtocol/Introduction/Intro.html)
- [URL Session Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/CookiesandCustomProtocols/CookiesandCustomProtocols.html#//apple_ref/doc/uid/10000165i-CH10-SW3)
- [Drop-in Offline Caching for UIWebView (and NSURLProtocol)](http://robnapier.net/offline-uiwebview-nsurlprotocol)
- [rnapier/RNCachingURLProtocol](https://github.com/rnapier/RNCachingURLProtocol)