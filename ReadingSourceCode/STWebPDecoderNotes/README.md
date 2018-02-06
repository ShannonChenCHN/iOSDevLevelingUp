# STWebPURLProtocol


这个框架的主要功能是为 UIWebView 提供了加载 WebP 图片的机制。

### 类似的实现


### STWebPURLProtocol 的实现逻辑


#### 几点说明：

### 使用方法

直接在应用启动时，也就是 `application:didFinishLaunchingWithOptions:` 方法中注册该类即可：

```
[NSURLProtocol registerClass:[STWebPURLProtocol class]];
```

### NSURLProtocol 的使用

#### 1. 主要原理



#### 2.注意点：

- UIWebView 的请求本身是有缓存的，但是我在使用该库时发现每次打开 UIWebView 会比较慢，后来自己加了离线缓存才有所改善。具体原因是什么呢？

### 启发

- 直接采用 SDWebImage 进行图片下载、解码和缓存，是否更简单？

### 参考：
