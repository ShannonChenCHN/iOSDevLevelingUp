# RNCachingURLProtocol


这个框架通过[自定义 NSURLProtocol 子类](https://github.com/ShannonChenCHN/iOSLevelingUp/tree/master/iOSTutorials/网络/NSURLProtocol)的方式，为 UIWebView 提供了一个简单的离线缓存机制：

- 你有一个 UIWebView 加载了有图片的网站
- 当处于联网状态下，执行正常的缓存逻辑
- 当处于离线状态下，展示上一次的成功加载过的网页内容

### 类似的实现
Matt Gallagher 是通过自定义 NSURLCache 来[实现离线缓存](http://cocoawithlove.com/2010/09/substituting-local-data-for-remote.html)的。[AFCache](https://github.com/artifacts/AFCache) 是通过自定义 NSURLProtocol 子类来实现的。但是在离线缓存的测试下都存在一定的问题。

### RNCachingURLProtocol 的实现逻辑

1.自定义 NSURLProtocol 子类，重写下面几个方法：

```
- canInitWithRequest
- canonicalRequestForRequest
- startLoading
- stopLoading
```

2.在接收到 URL 请求时：

2.1 先判断是否有网；  
2.2 如果无网络且本地有缓存，则加载缓存，并回调 `client` 的几个代理方法；       
2.3 如果无网络但是本地没有缓存，并直接回调 `client` 的代理方法 `- URLProtocol:didFailWithError:`；     
2.4 如果本地有网络，则创建 NSURLConnection 进行下载，并在相关代理方法中分别回调 `client` 的几个代理方法，请求完成时，缓存响应元数据和真正的数据到本地沙盒。

#### 几点说明：

- 所有的缓存都保存到沙盒中的 `Library/Caches` 目录下，当缓存空间不足时，会自动被系统清除掉（注：我在项目中使用该库时，曾有用户反应我们的 app 占用空间非常大，所以后来改为 SDWebImage 进行缓存）。
- 因为 NSURLProtocol 会缓存所有拦截到的 HTTP 请求，所以并不适合有大量网络请求的 APP。
- 作者在一开始是使用 URL 的 hash 值来作为缓存路径，但是这样会导致很多相似的 URL 的 hash 值是重复的，所以后来[改成了 MD5/SHA1 的算法](https://github.com/rnapier/RNCachingURLProtocol/pull/15)。
- 针对[有重定向的请求](https://github.com/rnapier/RNCachingURLProtocol/blob/master/RNCachingURLProtocol.m#L150)，需要将重定向的操作回调给 `client`， 如果有 response 的话，还需要将 response 缓存下来。

### 使用方法

直接在应用启动时，也就是 `- application:didFinishLaunchingWithOptions:` 方法中注册该类即可：

```
[NSURLProtocol registerClass:[RNCachingURLProtocol class]];
```


### 参考：
- [Drop-in Offline Caching for UIWebView (and NSURLProtocol)](http://robnapier.net/offline-uiwebview-nsurlprotocol)
- [rnapier/RNCachingURLProtocol](https://github.com/rnapier/RNCachingURLProtocol)
