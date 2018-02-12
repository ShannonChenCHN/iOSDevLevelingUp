## NSURLCache

缓存策略由请求（客户端）和回应（服务端）分别指定。

### NSURLCache 的使用

- 默认就已经设置好了 4 M 的内存缓存空间，以及 20 M 的磁盘缓存空间。我们可以在 `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions` 方法中设置自定义的缓存配置：
```
   // Set app-wide shared cache (first number is megabyte value)
    NSUInteger cacheSizeMemory = 500*1024*1024; // 500 MB
    NSUInteger cacheSizeDisk = 500*1024*1024; // 500 MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
```


- 默认缓存路径为 `(user home directory)/Library/Caches/(application bundle id)`
- 客户端可以通过设置 NSURLRequest 或者 NSURLSessionConfiguration 来设置缓存策略，系统默认的缓存策略是 NSURLRequestUseProtocolCachePolicy，也就是按照协议的缓存策略进行缓存，如果是 HTTP 请求，就是根据 http 协议来的，服务器通过 `Cache-Control: max-age` 字段来告诉 NSURLCache 是否需要缓存数据。：
![](https://github.com/ShannonChenCHN/iOSLevelingUp/blob/master/iOSTutorials/网络/images/http_caching_policy_decisions_tree.png?raw=true)
- 通过实现 NSURLSession 的 `URLSession:dataTask:willCacheResponse:completionHandler:` 方法或者 NSURLConnection 的 `connection:willCacheResponse:` 方法可以对要缓存的数据进行加工处理。

### 几点说明
- 在 NSURLRequestUseProtocolCachePolicy 模式下，即便有了 NSURLCache 缓存，但是如果处于网络离线状态下，依然会返回请求错误的信息。只有在设置 NSURLRequest 的策略模式为 NSURLRequestReturnCacheDataDontLoad 策略时，才支持离线缓存。
- NSURLCache 只会对 GET 请求进行缓存（待验证）。
- 不管 header 里面的 Cache-Control 是什么，NSURLCache 其实都会一直缓存，但是我们并没有感受到。所以 header 里面的 Cache-Control 为 `no-cache` 时应该指的是不使用缓存，但是会缓存，`no-store` 表示是不进行缓存。
- 如果这个请求的响应头中有 Transfer-Encoding: Chunked, 那他也不会缓存。
- 如果一个请求的响应内容的大小超过了 NSURLCache 中对应磁盘大小的 5%, 他就不会被缓存。详见[官方文档](https://developer.apple.com/documentation/foundation/nsurlsessiondatadelegate/1411612-urlsession?language=objc)。
   > The response size is small enough to reasonably fit within the cache. (For example, if you provide a disk cache, the response must be no larger than about 5% of the disk cache size.)

### 与HTTP服务器进行交互的简单说明

#### Cache-Control头
在第一次请求到服务器资源的时候，服务器需要使用Cache-Control这个响应头来指定缓存策略，它的格式如下：`Cache-Control:max-age=xxxx`，这个头指指明缓存过期的时间
Cache-Control头具有如下选项:

- public: 指示可被任何区缓存
- private
- no-cache: 指定该响应消息不能被缓存
- no-store: 指定不应该缓存
- max-age: 指定过期时间
- min-fresh:
- max-stable:

#### Last-Modified/If-Modified-Since
Last-Modified 是由服务器返回响应头，标识资源的最后修改时间.
If-Modified-Since 则由客户端发送，标识客户端所记录的，资源的最后修改时间。服务器接收到带有该请求头的请求时，会使用该时间与资源的最后修改时间进行对比，如果发现资源未被修改过，则直接返回HTTP 304而不返回包体，告诉客户端直接使用本地的缓存。否则响应完整的消息内容。

#### Etag/If-None-Match
Etag 由服务器发送，告之当资源在服务器上的一个唯一标识符。
客户端请求时，如果发现资源过期(使用Cache-Control的max-age)，发现资源具有Etag声明，这时请求服务器时则带上If-None-Match头，服务器收到后则与资源的标识进行对比，决定返回200或者304。



### 参考
- [NSURLCache - NSHipster](http://nshipster.cn/nsurlcache/)
- [iOS网络请求缓存：NSURLCache详解](https://www.jianshu.com/p/aa49bb3555f4)
- [NSURLCache Class Reference](https://developer.apple.com/documentation/foundation/nsurlcache?language=occ)
- [被忽视的 NSURLCache](http://codingnext.com/you-forget-nsurlcache.html)
- [说说 NSURLCache 中的那些坑](http://codingnext.com/nsurlcache.html)
- [NSURLCache 网络请求缓存指南](https://segmentfault.com/a/1190000005833523)
- [How to cache using NSURLSession and NSURLCache. Not working](https://stackoverflow.com/questions/21957378/how-to-cache-using-nsurlsession-and-nsurlcache-not-working)
- [`URLSession:dataTask:willCacheResponse:completionHandler:` - API Reference](https://developer.apple.com/documentation/foundation/nsurlsessiondatadelegate/1411612-urlsession?language=objc)
- [Does AFNetworking have any caching mechanisms built-in?](https://github.com/AFNetworking/AFNetworking/wiki/AFNetworking-FAQ#does-afnetworking-have-any-caching-mechanisms-built-in)
