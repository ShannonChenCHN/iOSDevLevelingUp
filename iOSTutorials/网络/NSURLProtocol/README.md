# NSURLProtocol

URL Loading System 本身只支持 http、https、file、ftp 和 data 协议。`NSURLProtocol` 是一个抽象类，提供了处理 URL 加载的基础设施。通过实现自定义的 `NSURLProtocol` 子类，可以让我们的 app 支持自定义的数据传输协议。

另外，对于 `NSURLProtocol` 核心功能，官方文档中并没有着重提到，但是却是最重要的一点：**借助它，你不必改动应用在网络调用上的其他部分，就可以改变 URL 加载行为的全部细节**。运用这一点，我们可以自由发挥，做很多想做的事情，比如：

- [拦截图片加载请求，转为从本地文件加载](http://stackoverflow.com/questions/5572258/ios-webview-remote-html-with-local-image-files)
- [在 UIWebView 中加载 webp 图片](https://github.com/cysp/STWebPDecoder)
- [通过缓存静态资源实现 UIWebView 的预加载优化](https://github.com/ShannonChenCHN/iOSLevelingUp/issues/55#issuecomment-300365305)
- [UIWebView 离线缓存](https://github.com/rnapier/RNCachingURLProtocol)
- [为了测试对HTTP返回内容进行mock和stub](https://draveness.me/%5Bhttps://github.com/AliSoftware/OHHTTPStubs%5D)
- [实现 HTTP 请求 Mock](https://github.com/Flipboard/FLEX/tree/master/Classes/Network)


#### 一、主要原理

在 URL Loading System 中，一个 NSURLProtocol 相当于一个请求拦截器，所有通过 NSURLConnection 和 NSURLSession 发起的请求都会经过~~所有~~注册过的 NSURLProtocol 子类（注：官方文档中说并不能保证所有注册过的 protocol 类都会被访问）。这些 NSURLProtocol 子类是按照注册的时间逆序来拦截请求的，最晚注册的 NSURLProtocol 类，最先拥有处理这个请求的权利。所以当在 `-application:didFinishLoadingWithOptions:` 方法中调用 `[NSURLProtocol registerClass:[MyURLProtocol class]];` 时，你自己写的 protocol 比其他内建的 protocol 拥有更高的优先级。

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

在 `-startLoading` 中，我们可以使用任何方法来对协议对象持有的 request 进行转发，包括 NSURLSession、 NSURLConnection 甚至使用 AFNetworking 等网络库，只要你在回调方法中记得回调 client（一个遵循 `<NSURLProtocolClient>` 协议的代理）的方法。当然，你也可以像 [RNCachingURLProtocol](https://github.com/rnapier/RNCachingURLProtocol) 一样，直接读取缓存，然后在恰当的时机回调 client 的代理方法。

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


### 二、注意点

- 如果你在 `-startLoading` 中将请求交给 NSURLConnection 或者 NSURLSession 来处理，因为 NSURLConnection 和 NSURLSession 也是 URL Loading System 的一部分，其发起的请求也会被 NSURLProtocol 拦截。所以就会出现递归调用造成死循环。为了防止递归调用造成死循环，我们可以参考苹果官方的做法，在通过 NSURLConnection 或者 NSURLSession 发起请求前，在 HTTP header 中添加一个字段作为标记，然后在 `-canInitWithRequest` 方法中通过判断 HTTP header 是否有相关标记，来决定是否处理该请求。

```
/*! Used to mark our recursive requests so that we don't try to handle them (and thereby 
 *  suffer an infinite recursive death).
 */

static NSString * kOurRecursiveRequestFlagProperty = @"com.apple.dts.CustomHTTPProtocol";

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
	BOOL        shouldAccept;

	// 省略了一部分代码 ...

    // Decline our recursive requests.
    
    if (shouldAccept) {
        shouldAccept = ([self propertyForKey:kOurRecursiveRequestFlagProperty inRequest:request] == nil);
        if ( ! shouldAccept ) {
            [self customHTTPProtocol:nil logWithFormat:@"decline request %@ (recursive)", url];
        }
    }
    
    // 省略了一部分代码 ...
    
    return shouldAccept;
}
```

- 要注意的是 NSURLProtocol 只能拦截 UIURLConnection、NSURLSession 和 UIWebView 中的请求，但是因为 WKWebView 是基于独立的 WebKit 进程，所以无法拦截 WKWebView 中发出的网络请求，后来也有开发者发现 WebKit 中有些私有 API 可以实现。

- 针对 HTTP 请求重定向，也要记得回调 client 的相应代理方法。


### 启发

NSURLProtocol 的设计思想跟[依赖注入](https://github.com/ShannonChenCHN/iOS-App-Architecture/issues/10#issuecomment-346219049)的原理有些相似，开发者可以通过注册的方式，注入一个或多个自定义 NSURLProtocol 子类，
当 URL Loading System 发起请求时， client（也就是请求的管理者，实际上是一个内部的类）会在内部调用注入的 NSURLProtocol 子类的方法。我们可以感受一下 NSURLProtocol 的这种设计模式，详见[示例代码](https://github.com/ShannonChenCHN/iOSLevelingUp/tree/master/iOSTutorials/网络/NSURLProtocol/DesignPattern)。
```
NSURLConnection/NSURLSession --> client --> 一个或多个 NSURLProtocol 拦截请求 --> 发出请求
```

### 参考
- [iOS 开发中使用 NSURLProtocol 拦截 HTTP 请求](https://draveness.me/intercept)
- [NSURLProtocol - NSHipster](http://nshipster.cn/nsurlprotocol/)
- [NSURLProtocol Class Reference](https://developer.apple.com/documentation/foundation/nsurlprotocol)
- [CustomHTTPProtocol - Guides and Sample Code](https://developer.apple.com/library/content/samplecode/CustomHTTPProtocol/Introduction/Intro.html)
- [URL Session Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/CookiesandCustomProtocols/CookiesandCustomProtocols.html#//apple_ref/doc/uid/10000165i-CH10-SW3)
- [Drop-in Offline Caching for UIWebView (and NSURLProtocol)](http://robnapier.net/offline-uiwebview-nsurlprotocol)
