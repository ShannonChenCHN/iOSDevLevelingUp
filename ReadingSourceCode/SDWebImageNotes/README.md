# [SDWebImage](https://github.com/rs/SDWebImage)(v3.7.3) 学习笔记

## 目录
- [简介](#一简介)
   - [设计目的](#1-设计目的)
   - [特性](#2-特性)
   - [SDWebImage 与其他框架的对比](#3-sdwebimage-与其他框架的对比)
   - [常见问题](#4-常见问题)
   - [用法](#5-用法)
   - [SDWebImage 4.0 迁移指南](#6-sdwebimage-40-迁移指南)
- [实现原理](#二实现原理)
   - [架构图](#1-架构图uml-类图)
   - [流程图](#2-流程图方法调用顺序图)
   - [目录结构](#3-目录结构)
   - [核心逻辑](#4-核心逻辑)
- [实现细节](#三实现细节)
- [知识点](#四知识点)
- [收获与疑问](#五收获与疑问)
- [延伸阅读](#六延伸阅读)

## 一、简介
### 1. 设计目的
`SDWebImage` 提供了 `UIImageView`、`UIButton` 、`MKAnnotationView` 的图片下载分类，只要一行代码就可以实现图片异步下载和缓存功能。这样开发者就无须花太多精力在图片下载细节上，专心处理业务逻辑。

### 2. 特性
- 提供 `UIImageView`, `UIButton`, `MKAnnotationView` 的分类，用来显示网络图片，以及缓存管理
- 异步下载图片
- 异步缓存（内存+磁盘），并且自动管理缓存有效性
- 后台图片解压缩
- 同一个 URL 不会重复下载
- 自动识别无效 URL，不会反复重试
- 不阻塞主线程
- 高性能
- 使用 GCD 和 ARC
- 支持多种图片格式（包括 WebP 格式）
- 支持动图（GIF）
   - 4.0 之前的动图效果并不是太好
   - 4.0 以后基于 [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage)加载动图

> 注：本文选读的代码是 3.7.3 版本的，所以动图加载还不支持 `FLAnimatedImage`。

### 3. SDWebImage 与其他框架的对比
- [How is SDWebImage better than X?](https://github.com/rs/SDWebImage/wiki/How-is-SDWebImage-better-than-X%3F)
- [iOS image caching. Libraries benchmark (SDWebImage vs FastImageCache)](https://bpoplauschi.wordpress.com/2014/03/21/ios-image-caching-sdwebimage-vs-fastimage/)

### 4. 常见问题
- 问题 1：使用 `UITableViewCell` 中的 `imageView` 加载不同尺寸的网络图片时会出现尺寸缩放问题

  > 解决方案：自定义 `UITableViewCell`，重写 `-layoutSubviews` 方法，调整位置尺寸；或者直接弃用 `UITableViewCell` 的 `imageView`，自己添加一个 imageView 作为子控件。

- 问题 2：图片刷新问题：`SDWebImage` 在进行缓存时忽略了所有服务器返回的 caching control 设置，并且在缓存时没有做时间限制，这也就意味着图片 URL 必须是静态的了，要求服务器上一个 URL 对应的图片内容不允许更新。但是如果存储图片的服务器不由自己控制，也就是说 图片内容更新了，URL 却没有更新，这种情况怎么办？

  > 解决方案：在调用 `sd_setImageWithURL: placeholderImage: options:`方法时设置 options 参数为 `SDWebImageRefreshCached`，这样虽然会降低性能，但是下载图片时会照顾到服务器返回的 caching control。

- 问题 3：在加载图片时，如何添加默认的 progress indicator ？

  > 解决方案：在调用 `-sd_setImageWithURL:`方法之前，先调用下面的方法：
   ```
	[imageView sd_setShowActivityIndicatorView:YES];
	[imageView sd_setIndicatorStyle:UIActivityIndicatorViewStyleGray];
   ```

### 5. 用法
#### 5.1 UITableView 中使用 UIImageView+WebCache
`UITabelViewCell` 中的 `UIImageView` 控件直接调用 `sd_setImageWithURL: placeholderImage:`方法即可

#### 5.2 使用回调 blocks
在 block 中得到图片下载进度和图片加载完成（下载完成或者读取缓存）的回调，如果你在图片加载完成前取消了请求操作，就不会收到成功或失败的回调
```
	[cell.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://www.domain.com/path/to/image.jpg"]
	                  placeholderImage:[UIImage imageNamed:@"placeholder.png"]
	                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
	                                ... completion code here ...
	                             }];
```

#### 5.3 SDWebImageManager 的使用
`UIImageView(WebCache)` 分类的核心在于 `SDWebImageManager` 的下载和缓存处理，`SDWebImageManager`将图片下载和图片缓存组合起来了。`SDWebImageManager`也可以单独使用。
```
	SDWebImageManager *manager = [SDWebImageManager sharedManager];
	[manager loadImageWithURL:imageURL
	                  options:0
	                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
	                        // progression tracking code
	                 }
	                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
	                    if (image) {
	                        // do something with image
	                    }
	                 }];
```


#### 5.4 单独使用 SDWebImageDownloader 异步下载图片 
我们还可以单独使用 `SDWebImageDownloader` 来下载图片，但是图片内容不会缓存。

```
	SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
	[downloader downloadImageWithURL:imageURL
	                         options:0
	                        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
	                            // progression tracking code
	                        }
	                       completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
	                            if (image && finished) {
	                                // do something with image
	                            }
	                        }];
```

#### 5.5 单独使用 SDImageCache 异步缓存图片
`SDImageCache` 支持内存缓存和异步的磁盘缓存（可选），如果你想单独使用 `SDImageCache` 来缓存数据的话，可以使用单例，也可以创建一个有独立命名空间的 `SDImageCache` 实例。

添加缓存的方法：
```
	[[SDImageCache sharedImageCache] storeImage:myImage forKey:myCacheKey];
```

默认情况下，图片数据会同时缓存到内存和磁盘中，如果你想只要内存缓存的话，可以使用下面的方法：
```
	[[SDImageCache sharedImageCache] storeImage:myImage forKey:myCacheKey toDisk:NO];
```

读取缓存时可以使用 `queryDiskCacheForKey:done:` 方法，图片缓存的 key 是唯一的，通常就是图片的 absolute URL。
```
	SDImageCache *imageCache = [[SDImageCache alloc] initWithNamespace:@"myNamespace"];
	[imageCache queryDiskCacheForKey:myCacheKey done:^(UIImage *image) {
	    // image is not nil if image was found
	}];
```


#### 5.6 自定义缓存 key
有时候，一张图片的 URL 中的一部分可能是动态变化的（比如获取权限上的限制），所以我们只需要把 URL 中不变的部分作为缓存用的 key。

```
	SDWebImageManager.sharedManager.cacheKeyFilter = ^(NSURL *url) {
	        url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
	        return [url absoluteString];
	    };
```

### 6. [SDWebImage 4.0 迁移指南](https://github.com/rs/SDWebImage/blob/master/Docs/SDWebImage-4.0-Migration-guide.md)

按照[版本号惯例(Semantic Versioning)](http://semver.org/)，从版本号可以看出 SDWebImage 4.0 是一个大版本，在结构上和 API 方面都有所改动。

除了 iOS 和 tvOS 之外，SDWebImage 4.0 还支持更多的平台——watchOS 和 Max OS X。

借助 [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage) 在动图支持上做了改进，尤其是 GIF。

## 二、实现原理
### 1. 架构图（UML 类图）
 ![Architecture](./src/SDWebImageClassDiagram.png)
 
 
### 2. 流程图（方法调用顺序图）
 ![Process](./src/SDWebImageSequenceDiagram.png)

### 3. 目录结构

- Downloader
	- `SDWebImageDownloader`
	- `SDWebImageDownloaderOperation`
- Cache
	- `SDImageCache`
- Utils
	- `SDWebImageManager`
	- `SDWebImageDecoder`
	- `SDWebImagePrefetcher`
- Categories
	- `UIView+WebCacheOperation`
	- `UIImageView+WebCache`
	- `UIImageView+HighlightedWebCache`
	- `UIButton+WebCache`
	- `MKAnnotationView+WebCache`
	- `NSData+ImageContentType`
	- `UIImage+GIF`
	- `UIImage+MultiFormat`
	- `UIImage+WebP`
- Other
    - `SDWebImageOperation`（协议）
    - `SDWebImageCompat`（宏定义、常量、通用函数）

类名|功能|
--|--|
`SDWebImageDownloader`|是专门用来下载图片和优化图片加载的，跟缓存没有关系|
`SDWebImageDownloaderOperation `|继承于 `NSOperation`，用来处理下载任务的|
`SDImageCache`|用来处理内存缓存和磁盘缓存（可选)的，其中磁盘缓存是异步进行的，因此不会阻塞主线程|
`SDWebImageManager`|作为 `UIImageView+WebCache` 背后的默默付出者，主要功能是将图片下载（`SDWebImageDownloader `）和图片缓存（`SDImageCache `）两个独立的功能组合起来|
`SDWebImageDecoder`|图片解码器，用于图片下载完成后进行解码|
`SDWebImagePrefetcher`|预下载图片，方便后续使用，图片下载的优先级低，其内部由 `SDWebImageManager` 来处理图片下载和缓存|
`UIView+WebCacheOperation`|用来记录图片加载的 operation，方便需要时取消和移除图片加载的 operation|
`UIImageView+WebCache`|集成 `SDWebImageManager` 的图片下载和缓存功能到 `UIImageView` 的方法中，方便调用方的简单使用|
`UIImageView+HighlightedWebCache`|跟 `UIImageView+WebCache` 类似，也是包装了 `SDWebImageManager`，只不过是用于加载 highlighted 状态的图片|
`UIButton+WebCache`|跟 `UIImageView+WebCache` 类似，集成 `SDWebImageManager` 的图片下载和缓存功能到 `UIButton` 的方法中，方便调用方的简单使用|
`MKAnnotationView+WebCache`|跟 `UIImageView+WebCache` 类似|
`NSData+ImageContentType`|用于获取图片数据的格式（JPEG、PNG等）|
`UIImage+GIF`|用于加载 GIF 动图|
`UIImage+MultiFormat`|根据不同格式的二进制数据转成 `UIImage` 对象|
`UIImage+WebP`|用于解码并加载 WebP 图片|
 
### 4. 核心逻辑
 
下载 [Source code(3.7.3)](https://github.com/rs/SDWebImage/archive/3.7.3.zip)，运行 `pod install`，然后打开 `SDWebImage.xcworkspace`，先 run 起来感受一下。

在了解细节之前我们先大概浏览一遍主流程，也就是最核心的逻辑。

我们从 `MasterViewController` 中的 `[cell.imageView sd_setImageWithURL:url placeholderImage:placeholderImage];` 开始看起。

经过层层调用，直到 `UIImageView+WebCache` 中最核心的方法 `sd_setImageWithURL: placeholderImage: options: progress: completed:`。该方法中，主要做了以下几件事：
   - 取消当前正在进行的加载任务 operation
   - 设置 placeholder
   - 如果 URL 不为 `nil`，就通过 `SDWebImageManager` 单例开启图片加载任务 operation，`SDWebImageManager` 的图片加载方法中会返回一个 `SDWebImageCombinedOperation` 对象，这个对象包含一个 cacheOperation 和一个 cancelBlock。

`SDWebImageManager` 的图片加载方法 `downloadImageWithURL:options:progress:completed:` 中会先拿图片缓存的 key （这个 key 默认是图片 URL）去 `SDImageCache` 单例中读取内存缓存，如果有，就返回给 `SDWebImageManager`；如果内存缓存没有，就开启异步线程，拿经过 MD5 处理的 key 去读取磁盘缓存，如果找到磁盘缓存了，就同步到内存缓存中去，然后再返回给 `SDWebImageManager`。

如果内存缓存和磁盘缓存中都没有，`SDWebImageManager` 就会调用 `SDWebImageDownloader` 单例的 `-downloadImageWithURL: options: progress: completed:` 方法去下载，该会先将传入的 `progressBlock` 和 `completedBlock` 保存起来，并在第一次下载该 URL 的图片时，创建一个 `NSMutableURLRequest` 对象和一个 `SDWebImageDownloaderOperation` 对象，并将该 `SDWebImageDownloaderOperation` 对象添加到 `SDWebImageDownloader` 的`downloadQueue` 来启动异步下载任务。

`SDWebImageDownloaderOperation` 中包装了一个 `NSURLConnection` 的网络请求，并通过 runloop 来保持 `NSURLConnection` 在 start 后、收到响应前不被干掉，下载图片时，监听 `NSURLConnection` 回调的 `-connection:didReceiveData:` 方法中会负责 progress 相关的处理和回调，`- connectionDidFinishLoading:` 方法中会负责将 data 转为 image，以及图片解码操作，并最终回调 completedBlock。

`SDWebImageDownloaderOperation` 中的图片下载请求完成后，会回调给 `SDWebImageDownloader`，然后 `SDWebImageDownloader` 再回调给 `SDWebImageManager`，`SDWebImageManager` 中再将图片分别缓存到内存和磁盘上（可选），并回调给 `UIImageView`，`UIImageView` 中再回到主线程设置 `image` 属性。至此，图片的下载和缓存操作就圆满结束了。

当然，`SDWebImage` 中还有很多细节可以深挖，包括一些巧妙设计和知识点，接下来再看看`SDWebImage` 中的实现细节。


## 三、实现细节

> 注：为了节省篇幅，这里使用伪代码的方式来解读，具体的阅读注解见 [ShannonChenCHN/SDWebImage-3.7.3](https://github.com/ShannonChenCHN/iOSLevelingUp/tree/master/ReadingSourceCode/SDWebImageNotes/SDWebImage-3.7.3)。

从上面的核心逻辑分析可以看出，`SDWebImage` 最核心的功能也就是以下 4 件事：   

- 下载（`SDWebImageDownloader `）
- 缓存（`SDImageCache`）
- 将缓存和下载的功能组合起来（`SDWebImageManager`）
- 封装成 UIImageView 等类的分类方法（`UIImageView+WebCache` 等）

### 1. 图片下载
### 1.1 SDWebImageDownloader

`SDWebImageDownloader` 继承于 `NSObject`，主要承担了异步下载图片和优化图片加载的任务。

**几个问题**
- 如何实现异步下载，也就是多张图片同时下载？
- 如何处理同一张图片（同一个 URL）多次下载的情况？

**枚举定义**
```
// 下载选项
typedef NS_OPTIONS(NSUInteger, SDWebImageDownloaderOptions) {
    SDWebImageDownloaderLowPriority = 1 << 0,
    SDWebImageDownloaderProgressiveDownload = 1 << 1,
    SDWebImageDownloaderUseNSURLCache = 1 << 2,
    SDWebImageDownloaderIgnoreCachedResponse = 1 << 3,
    SDWebImageDownloaderContinueInBackground = 1 << 4,
    SDWebImageDownloaderHandleCookies = 1 << 5,
    SDWebImageDownloaderAllowInvalidSSLCertificates = 1 << 6,
    SDWebImageDownloaderHighPriority = 1 << 7,
};

// 下载任务执行顺序
typedef NS_ENUM(NSInteger, SDWebImageDownloaderExecutionOrder) {
    SDWebImageDownloaderFIFOExecutionOrder, // 先进先出
    SDWebImageDownloaderLIFOExecutionOrder  // 后进先出
};
```

**.h 文件中的属性：**
```
@property (assign, nonatomic) BOOL shouldDecompressImages;  // 下载完成后是否需要解压缩图片，默认为 YES
@property (assign, nonatomic) NSInteger maxConcurrentDownloads;
@property (readonly, nonatomic) NSUInteger currentDownloadCount;
@property (assign, nonatomic) NSTimeInterval downloadTimeout;
@property (assign, nonatomic) SDWebImageDownloaderExecutionOrder executionOrder;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (nonatomic, copy) SDWebImageDownloaderHeadersFilterBlock headersFilter;
```

**.m 文件中的属性：**
```
@property (strong, nonatomic) NSOperationQueue *downloadQueue; // 图片下载任务是放在这个 NSOperationQueue 任务队列中来管理的
@property (weak, nonatomic) NSOperation *lastAddedOperation;
@property (assign, nonatomic) Class operationClass;
@property (strong, nonatomic) NSMutableDictionary *HTTPHeaders;
@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t barrierQueue;
@property (strong, nonatomic) NSMutableDictionary *URLCallbacks; // 图片下载的回调 block 都是存储在这个属性中，该属性是一个字典，key 是图片的 URL，value 是一个数组，包含每个图片的多组回调信息。用 JSON 格式表示的话，就是下面这种形式：

```

**.h 文件中方法**

```
+ (SDWebImageDownloader *)sharedDownloader;

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (NSString *)valueForHTTPHeaderField:(NSString *)field;

- (void)setOperationClass:(Class)operationClass; // 创建 operation 用的类

- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                         options:(SDWebImageDownloaderOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageDownloaderCompletedBlock)completedBlock;
                                       
- (void)setSuspended:(BOOL)suspended;
```

**.m 文件中的方法**

```
// Lifecycle
+ (void)initialize;
+ (SDWebImageDownloader *)sharedDownloader;
- init;
- (void)dealloc;

// Setter and getter
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (NSString *)valueForHTTPHeaderField:(NSString *)field;
- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrentDownloads;
- (NSUInteger)currentDownloadCount;
- (NSInteger)maxConcurrentDownloads;
- (void)setOperationClass:(Class)operationClass;

// Download
- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                         options:(SDWebImageDownloaderOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageDownloaderCompletedBlock)completedBlock;
- (void)addProgressCallback:(SDWebImageDownloaderProgressBlock)progressBlock
          andCompletedBlock:(SDWebImageDownloaderCompletedBlock)completedBlock
                     forURL:(NSURL *)url
             createCallback:(SDWebImageNoParamsBlock)createCallback;

// Download queue            
- (void)setSuspended:(BOOL)suspended;
```


**具体实现：**

先看看 `+initialize` 方法，这个方法中主要是通过注册通知 让`SDNetworkActivityIndicator` 监听下载事件，来显示和隐藏状态栏上的 network activity indicator。为了让 `SDNetworkActivityIndicator` 文件可以不用导入项目中来（如果不要的话），这里使用了 runtime 的方式来实现动态创建类以及调用方法。

```
+ (void)initialize {
	if (NSClassFromString(@"SDNetworkActivityIndicator")) {
		id activityIndicator = [NSClassFromString(@"SDNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
		
		# 先移除通知观察者 SDNetworkActivityIndicator
		# 再添加通知观察者 SDNetworkActivityIndicator
	}
}
```

`+sharedDownloader` 方法中调用了 `-init` 方法来创建一个单例，`-init`方法中做了一些初始化设置和默认值设置，包括设置最大并发数（6）、下载超时时长（15s）等。
```
- (id)init {
	#设置下载 operation 的默认执行顺序（先进先出还是先进后出）
	#初始化 _downloadQueue（下载队列），_URLCallbacks（下载回调 block 的容器），_barrierQueue（GCD 队列）
	#设置 _downloadQueue 的队列最大并发数默认值为 6
	#设置 _HTTPHeaders 默认值 
	#设置默认下载超时时长 15s 
	...
}

```

除了以上两个方法之外，这个类中最核心的方法就是 `- downloadImageWithURL: options: progress: completed:` 方法，这个方法中首先通过调用 `-addProgressCallback: andCompletedBlock: forURL: createCallback:` 方法来保存每个 url 对应的回调 block，`-addProgressCallback: ...` 方法先进行错误检查，判断 URL 是否为空，然后再将 URL 对应的 `progressBlock` 和 `completedBlock` 保存到 `URLCallbacks ` 属性中去。

`URLCallbacks` 属性是一个 `NSMutableDictionary` 对象，key 是图片的 URL，value 是一个数组，包含每个图片的多组回调信息。用 JSON 格式表示的话，就是下面这种形式：

```
{
    "callbacksForUrl1": [
        {
            "kProgressCallbackKey": "progressCallback1_1",
            "kCompletedCallbackKey": "completedCallback1_1"
        },
        {
            "kProgressCallbackKey": "progressCallback1_2",
            "kCompletedCallbackKey": "completedCallback1_2"
        }
    ],
    "callbacksForUrl2": [
        {
            "kProgressCallbackKey": "progressCallback2_1",
            "kCompletedCallbackKey": "completedCallback2_1"
        },
        {
            "kProgressCallbackKey": "progressCallback2_2",
            "kCompletedCallbackKey": "completedCallback2_2"
        }
    ]
}
```

这里有个细节需要注意，因为可能同时下载多张图片，所以就可能出现多个线程同时访问 `URLCallbacks` 属性的情况。为了保证线程安全，所以这里使用了 `dispatch_barrier_sync` 来分步执行添加到 `barrierQueue` 中的任务，这样就能保证同一时间只有一个线程能对 `URLCallbacks` 进行操作。

``` 
- (void)addProgressCallback:(SDWebImageDownloaderProgressBlock)progressBlock andCompletedBlock:(SDWebImageDownloaderCompletedBlock)completedBlock forURL:(NSURL *)url createCallback:(SDWebImageNoParamsBlock)createCallback {
	#1. 判断 url 是否为 nil，如果为 nil 则直接回调 completedBlock，返回失败的结果，然后 return，因为 url 会作为存储 callbacks 的 key
	
	#2. 处理同一个 URL 的多次下载请求（MARK: 使用 dispatch_barrier_sync 函数来保证同一时间只有一个线程能对 URLCallbacks 进行操作)：
	  ## 从属性 URLCallbacks(一个字典) 中取出对应 url 的 callBacksForURL(这是一个数组，因为可能一个 url 不止在一个地方下载)
	  ## 如果没有取到，也就意味着这个 url 是第一次下载，那就初始化一个 callBacksForURL 放到属性 URLCallbacks 中
	  ## 往数组 callBacksForURL 中添加 包装有 callbacks（progressBlock 和 completedBlock）的字典
	  ## 更新 URLCallbacks 存储的对应 url 的 callBacksForURL
	  
	#3. 如果这个 url 是第一次请求下载，就回调 createCallback

}


```

如果这个 URL 是第一次被下载，就要回调 `createCallback`，`createCallback` 主要做的就是创建并开启下载任务，下面是 `createCallback` 的具体实现逻辑：


```

- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url options:(SDWebImageDownloaderOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageDownloaderCompletedBlock)completedBlock {
	 #1. 调用 - [SDWebImageDownloader addProgressCallback: andCompletedBlock: forURL: createCallback: ] 方法，直接把入参 url、progressBlock 和 completedBlock 传进该方法，并在第一次下载该 URL 时回调 createCallback
	 
		## createCallback 的回调处理：{
		  1.1 创建下载 request ，设置 request 的 cachePolicy、HTTPShouldHandleCookies、HTTPShouldUsePipelining，以及 allHTTPHeaderFields（这个属性交由外面处理，设计的比较巧妙）

		  1.2 创建 SDWebImageDownloaderOperation（继承自 NSOperation）

		      ### 1.2.1 SDWebImageDownloaderOperation 的 progressBlock 回调处理 {
		      		  （这个 block 有两个回调参数：接收到的数据大小和预计数据大小）
		      	 	  这里用了 weak-strong dance
		      	 	  首先使用 strongSelf 强引用 weakSelf，目的是为了保住 self 不被释放  
		      	 	  然后检查 self 是否已经被释放（这里为什么先“保活”后“判空”呢？因为如果先判空的话，有可能判空后 self 就被释放了）
		      	 	  取出 url 对应的回调 block 数组（这里取的时候有些讲究，考虑了多线程问题，而且取的是 copy 的内容）
		      	 	  遍历数组，从每个元素（字典）中取出 progressBlock 进行回调 	  
		      	   }
		      ### 1.2.2 SDWebImageDownloaderOperation 的 completedBlock 回调处理 {
		      		   （这个 block 有四个回调参数：图片 UIImage，图片数据 NSData，错误 NSError，是否结束 isFinished）
		      		   同样，这里也用了 weak-strong dance
		      		   接着，取出 url 对应的回调 block 数组
		      		   如果结束了（isFinished），就移除 url 对应的回调 block 数组（移除的时候也要考虑多线程问题）
		      		   遍历数组，从每个元素（字典）中取出 completedBlock 进行回调 
		      }
		      ### SDWebImageDownloaderOperation 的 cancelBlock 回调处理 {
		      		   同样，这里也用了 weak-strong dance
		      		   然后移除 url 对应的所有回调 block
		      }
		  1.3 设置下载完成后是否需要解压缩
		  1.4 如果设置了 username 和 password，就给 operation 的下载请求设置一个 NSURLCredential  
		  1.5 设置 operation 的队列优先级
		  1.6 将 operation 加入到队列 downloadQueue 中，队列（NSOperationQueue）会自动管理 operation 的执行
		  1.7 如果 operation 执行顺序是先进后出，就设置 operation 依赖关系（先加入的依赖于后加入的），并记录最后一个 operation（lastAddedOperation）
		}

	 #2. 返回 createCallback 中创建的 operation（SDWebImageDownloaderOperation）
}

```

`createCallback` 方法中调用了 `- [SDWebImageDownloaderOperation initWithRequest: options: progress:]` 方法来创建下载任务 `SDWebImageDownloaderOperation`。那么，这个 `SDWebImageDownloaderOperation ` 类究竟是干什么的呢？下一节再看。


**知识点**：
1. SDWebImageDownloaderOptions 枚举使用了位运算
   应用：通过“与”运算符，可以判断是否设置了某个枚举选项，因为每个枚举选择项中只有一位是1，其余位都是 0，所以只有参与运算的另一个二进制值在同样的位置上也为 1，与 运算的结果才不会为 0.
   ```
     0101 (相当于 SDWebImageDownloaderLowPriority | SDWebImageDownloaderUseNSURLCache)
   & 0100 (= 1 << 2，也就是 SDWebImageDownloaderUseNSURLCache)
   = 0100 (> 0，也就意味着 option 参数中设置了 SDWebImageDownloaderUseNSURLCache)
   ```
2. `dispatch_barrier_sync` 函数的使用
3. weak-strong dance 
4. HTTP header 的理解
5. `NSOperationQueue` 的使用
6. `NSURLRequest` 的 `cachePolicy`、`HTTPShouldHandleCookies`、`HTTPShouldUsePipelining`
7. `NSURLCredential` 
8. `createCallback` 里面为什么要用 wself？
	```
	NSTimeInterval timeoutInterval = wself.downloadTimeout;
	```

### 1.2 SDWebImageDownloaderOperation

每张图片的下载都会发出一个异步的 HTTP 请求，这个请求就是由 `SDWebImageDownloaderOperation` 管理的。

`SDWebImageDownloaderOperation` 继承 `NSOperation`，遵守 `SDWebImageOperation`、`NSURLConnectionDataDelegate` 协议。

`SDWebImageOperation` 协议只定义了一个方法 `-cancel`，用来取消 operation。

**几个问题**
- 如何实现下载的网络请求？
- 如何管理整个图片下载的过程？
- 图片下载完成后需要做哪些处理？

**.h 文件中的属性：**

```
@property (strong, nonatomic, readonly) NSURLRequest *request; // 用来给 operation 中的 connection 使用的请求
@property (assign, nonatomic) BOOL shouldDecompressImages; // 下载完成后是否需要解压缩
@property (nonatomic, assign) BOOL shouldUseCredentialStorage; 
@property (nonatomic, strong) NSURLCredential *credential;
@property (assign, nonatomic, readonly) SDWebImageDownloaderOptions options;
@property (assign, nonatomic) NSInteger expectedSize;
@property (strong, nonatomic) NSURLResponse *response;

其他继承自 NSOperation 的属性（略）

```

**.m 文件中的属性：**

```
@property (copy, nonatomic) SDWebImageDownloaderProgressBlock progressBlock;    
@property (copy, nonatomic) SDWebImageDownloaderCompletedBlock completedBlock;
@property (copy, nonatomic) SDWebImageNoParamsBlock cancelBlock;

@property (assign, nonatomic, getter = isExecuting) BOOL executing; // 覆盖了 NSOperation 的 executing
@property (assign, nonatomic, getter = isFinished) BOOL finished;  // 覆盖了 NSOperation 的 finished
@property (assign, nonatomic) NSInteger expectedSize;
@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, atomic) NSThread *thread;

@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId; // Xcode 的 BaseSDK 设置为 iOS 4.0 时以上使用

// 成员变量
size_t width, height;  				// 图片宽高
UIImageOrientation orientation;  	// 图片方向
BOOL responseFromCached;
```

**.h 文件中的方法：**

```
- (id)initWithRequest:(NSURLRequest *)request
              options:(SDWebImageDownloaderOptions)options
             progress:(SDWebImageDownloaderProgressBlock)progressBlock
            completed:(SDWebImageDownloaderCompletedBlock)completedBlock
            cancelled:(SDWebImageNoParamsBlock)cancelBlock;    

其他继承自 NSOperation 的方法（略）

```
         
**.m 文件中的方法：**        
    
```
// 覆盖了父类的属性，需要重新实现属性合成方法
@synthesize executing = _executing;
@synthesize finished = _finished;

// Initialization
- (id)initWithRequest:(NSURLRequest *)request
              options:(SDWebImageDownloaderOptions)options
             progress:(SDWebImageDownloaderProgressBlock)progressBlock
            completed:(SDWebImageDownloaderCompletedBlock)completedBlock
            cancelled:(SDWebImageNoParamsBlock)cancelBlock;
// Operation
- (void)start;
- (void)cancel;
- (void)cancelInternalAndStop;
- (void)cancelInternal;
- (void)done;
- (void)reset;

// Setter and getter
- (void)setFinished:(BOOL)finished; 
- (void)setExecuting:(BOOL)executing; 
- (BOOL)isConcurrent; 

// NSURLConnectionDataDelegate 方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response; //  下载过程中的 response 回调
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data; // 下载过程中 data 回调
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection; // 下载完成时回调
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error; // 下载失败时回调
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse; // 在 connection 存储 cached response 到缓存中之前调用
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection __unused *)connection; //  URL loader 是否应该使用 credential storage
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge; // connection 发送身份认证的请求之前被调用

// Helper
+ (UIImageOrientation)orientationFromPropertyValue:(NSInteger)value;
- (UIImage *)scaledImageForKey:(NSString *)key image:(UIImage *)image;
- (BOOL)shouldContinueWhenAppEntersBackground;

```        

**具体实现：**

首先来看看指定初始化方法 `-initWithRequest:options:progress:completed:cancelled:`，这个方法是保存一些传入的参数，设置一些属性的初始默认值。

```
- (id)initWithRequest:(NSURLRequest *)request
              options:(SDWebImageDownloaderOptions)options
             progress:(SDWebImageDownloaderProgressBlock)progressBlock
            completed:(SDWebImageDownloaderCompletedBlock)completedBlock
            cancelled:(SDWebImageNoParamsBlock)cancelBlock {
	# 接受参数，设置属性
	# 设置属性_shouldUseCredentialStorage、_executing、_finished、_expectedSize、responseFromCached 的默认值/初始值
}
```

当创建的 `SDWebImageDownloaderOperation` 对象被加入到 downloader 的 downloadQueue 中时，该对象的 `-start` 方法就会被自动调用。
`-start` 方法中首先创建了用来下载图片数据的 `NSURLConnection`，然后开启 connection，同时发出开始图片下载的 `SDWebImageDownloadStartNotification` 通知，为了防止非主线程的请求被 kill 掉，这里开启 runloop 保活，直到请求返回。

```
- (void)start {
	# 给 `self` 加锁 {
		## 如果 `self` 被 cancell 掉的话，finished 属性变为 YES，reset 下载数据和回调 block，然后直接 return。

		## 如果允许程序退到后台后继续下载，就标记为允许后台执行，在后台任务过期的回调 block 中 {
			首先来一个 weak-strong dance
			调用 cancel 方法（这个方法里面又做了一些处理，反正就是 cancel 掉当前的 operation）
			调用 UIApplication 的 endBackgroundTask： 方法结束任务
			记录结束后的 taskId
			
		}
		
		## 标记 executing 属性为 YES
		## 创建 connection，赋值给 connection 属性
		## 获取 currentThread，赋值给 thread 属性

	}
	
	# 启动 connection
	# 因为上面初始化 connection 时可能会失败，所以这里我们需要根据不同情况做处理
		## A.如果 connection 不为 nil
			### 回调 progressBlock（初始的 receivedSize 为 0，expectSize 为 -1）
			### 发出 SDWebImageDownloadStartNotification 通知（SDWebImageDownloader 会监听到）
			### 开启 runloop
			### runloop 结束后继续往下执行（也就是 cancel 掉或者 NSURLConnection 请求完毕代理回调后调用了 CFRunLoopStop）
		
		## B.如果 connection 为 nil，回调 completedBlock，返回 connection 初始化失败的错误信息
	# 下载完成后，调用 endBackgroundTask: 标记后台任务结束
}
```
`NSURLConnection` 请求图片数据时，服务器返回的的结果是通过 `NSURLConnectionDataDelegate` 的代理方法回调的，其中最主要的是以下三个方法：

```
- connection:didReceiveResponse: //  下载过程中的 response 回调，调用一次
- connection:didReceiveData:     // 下载过程中 data 回调，调用多次
- connectionDidFinishLoading:    // 下载完成时回调，调用一次
```

前两个方法是在下载过程中回调的，第三个方法是在下载完成时回调的。第一个方法 `- connection:didReceiveResponse: ` 被调用后，接着会多次调用 `- connection:didReceiveData:` 方法来更新进度、拼接图片数据，当图片数据全部下载完成时，`- connectionDidFinishLoading:` 方法就会被调用。

```
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	#A. 返回 code 不是 304 Not Modified
		1. 获取 expectedSize，回调 progressBlock
		2. 初始化 imageData 属性
		3. 发送 SDWebImageDownloadReceiveResponseNotification 通知
	#B. 针对 304 Not Modified 做处理，直接 cancel operation，并返回缓存的 image
		1. 取消连接
		2. 发送 SDWebImageDownloadStopNotification 通知
		3. 回调 completedBlock
		4. 停止 runloop
}
```

```
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	# 1.拼接图片数据
	# 2.针对 `SDWebImageDownloaderProgressiveDownload` 做的处理
		## 2.1 根据更新的 imageData 创建 CGImageSourceRef 对象
		## 2.2 首次获取到数据时，读取图片属性：width, height, orientation
		## 2.3 图片还没下载完，但不是第一次拿到数据，使用现有图片数据 CGImageSourceRef 创建 CGImageRef 对象
		## 2.4 对图片进行缩放、解码，回调 completedBlock
	# 3.回调 progressBlock
}

```

```
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	# 1. 下载结束，停止 runloop，发送 SDWebImageDownloadStopNotification 通知和 SDWebImageDownloadFinishNotification 通知
	# 2. 回调 completionBlock
		# 2.1 如果是返回的结果是 URL Cache，就回调图片数据为 nil 的 completionBlock
		# 2.2 如果有图片数据
			# 2.2.1 针对不同图片格式进行数据转换 data -> image
			# 2.2.2 据图片名中是否带 @2x 和 @3x 来做 scale 处理
			# 2.2.3 如果需要解码，就进行图片解码（如果不是 GIF 图）
			# 2.2.4 判断图片尺寸是否为空，并回调 completionBlock
		# 2.3 如果没有图片数据，回调带有错误信息的 completionBlock
	# 3. 将 completionBlock 置为 nil
	# 4. 重置
}


```

当图片的所有数据下载完成后，`SDWebImageDownloader` 传入的 `completionBlock` 被调用，至此，整个图片的下载过程就结束了。从上面的解读中我们可以看到，一张图片的数据下载是由一个 `NSConnection` 对象来完成的，这个对象的整个生命周期（从创建到下载结束）又是由 `SDWebImageDownloaderOperation` 来控制的，将 operation 加入到 operation queue 中就可以实现多张图片同时下载了。

简单概括成一句话就是，`NSConnection` 负责网络请求，`NSOperation` 负责多线程。

**知识点**

1. `NSOperation` 的 `-start` 方法、`-main` 方法和 `-cancel` 方法
2. `-start` 方法中为什么要调用 `CFRunLoopRun()` 或者 `CFRunLoopRunInMode()` 函数？       
  
  参考：
  - http://stanoz-io.top/2016/05/17/NSRunLoop_Note/
  - http://tom555cat.com/2016/08/01/SdWebImage之RunLoop/
  - http://blog.ibireme.com/2015/05/18/runloop/
  - https://github.com/rs/SDWebImage/issues/497
  - https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html

3. `SDWebImageDownloaderOperation` 中是什么时候开启异步线程的？

4. `NSURLConnection` 的几个代理方法分别在什么时候调用？

5.  `NSURLCache` 是什么？

### 2. 图片缓存——SDImageCache

首先我们想一想，为什么需要缓存？
- 以空间换时间，提升用户体验：加载同一张图片，读取缓存是肯定比远程下载的速度要快得多的
- 减少不必要的网络请求，提升性能，节省流量：一般来讲，同一张图片的 URL 是不会经常变化的，所以没有必要重复下载。另外，现在的手机存储空间都比较大，相对于流量来，缓存占的那点空间算不了什么

`SDImageCache` 管理着一个内存缓存和磁盘缓存（可选），同时在写入磁盘缓存时采取异步执行，所以不会阻塞主线程，影响用户体验。

**几个问题**
- 从读取速度和保存时间上来考虑，缓存该怎么存？key 怎么定？
- 内存缓存怎么存？
- 磁盘缓存怎么存？路径、文件名怎么定？
- 使用时怎么读取缓存？
- 什么时候需要移除缓存？怎么移除？

**枚举**
```
typedef NS_ENUM(NSInteger, SDImageCacheType) {
    SDImageCacheTypeNone,   // 没有读取到图片缓存，需要从网上下载
    SDImageCacheTypeDisk,   // 磁盘中的缓存
    SDImageCacheTypeMemory  // 内存中的缓存
};
```

**.h 文件中的属性：**

```
@property (assign, nonatomic) BOOL shouldDecompressImages;  // 读取磁盘缓存后，是否需要对图片进行解压缩

@property (assign, nonatomic) NSUInteger maxMemoryCost; // 其实就是 NSCache 的 totalCostLimit，内存缓存总消耗的最大限制，cost 是根据内存中的图片的像素大小来计算的
@property (assign, nonatomic) NSUInteger maxMemoryCountLimit; // 其实就是 NSCache 的 countLimit，内存缓存的最大数目

@property (assign, nonatomic) NSInteger maxCacheAge;    // 磁盘缓存的最大时长，也就是说缓存存多久后需要删掉
@property (assign, nonatomic) NSUInteger maxCacheSize;  // 磁盘缓存文件总体积最大限制，以 bytes 来计算
```

**.m 文件中的属性：**
```
@property (strong, nonatomic) NSCache *memCache;
@property (strong, nonatomic) NSString *diskCachePath;
@property (strong, nonatomic) NSMutableArray *customPaths; // // 只读的路径，比如 bundle 中的文件路径，用来在 SDWebImage 下载、读取缓存之前预加载用的
@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t ioQueue;

NSFileManager *_fileManager;

```


**.h 文件中的方法：**

```
+ (SDImageCache *)sharedImageCache;
- (id)initWithNamespace:(NSString *)ns;
- (id)initWithNamespace:(NSString *)ns diskCacheDirectory:(NSString *)directory;

-(NSString *)makeDiskCachePath:(NSString*)fullNamespace;


- (void)addReadOnlyCachePath:(NSString *)path;


- (void)storeImage:(UIImage *)image forKey:(NSString *)key;
- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk;
- (void)storeImage:(UIImage *)image recalculateFromImage:(BOOL)recalculate imageData:(NSData *)imageData forKey:(NSString *)key toDisk:(BOOL)toDisk;

- (NSOperation *)queryDiskCacheForKey:(NSString *)key done:(SDWebImageQueryCompletedBlock)doneBlock;

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;
- (UIImage *)imageFromDiskCacheForKey:(NSString *)key;


- (void)removeImageForKey:(NSString *)key;
- (void)removeImageForKey:(NSString *)key withCompletion:(SDWebImageNoParamsBlock)completion;
- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk;
- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(SDWebImageNoParamsBlock)completion;

- (void)clearMemory;

- (void)clearDiskOnCompletion:(SDWebImageNoParamsBlock)completion;
- (void)clearDisk;
- (void)cleanDiskWithCompletionBlock:(SDWebImageNoParamsBlock)completionBlock;
- (void)cleanDisk;


- (NSUInteger)getSize;
- (NSUInteger)getDiskCount;
- (void)calculateSizeWithCompletionBlock:(SDWebImageCalculateSizeBlock)completionBlock;


- (void)diskImageExistsWithKey:(NSString *)key completion:(SDWebImageCheckCacheCompletionBlock)completionBlock;
- (BOOL)diskImageExistsWithKey:(NSString *)key;


- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path;
- (NSString *)defaultCachePathForKey:(NSString *)key;
```

**.m 文件中的方法和函数：**

1. 方法

```
// Lifecycle
+ (SDImageCache *)sharedImageCache;
- (id)init;
- (id)initWithNamespace:(NSString *)ns;
- (id)initWithNamespace:(NSString *)ns diskCacheDirectory:(NSString *)directory;
- (void)dealloc;

// Cache Path
- (void)addReadOnlyCachePath:(NSString *)path; // 添加只读路径，比如 bundle 中的文件路径，用来在 SDWebImage 下载、读取缓存之前预加载用的
- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path;
- (NSString *)defaultCachePathForKey:(NSString *)key;
- (NSString *)cachedFileNameForKey:(NSString *)key
-(NSString *)makeDiskCachePath:(NSString*)fullNamespace;

// Store Image
- (void)storeImage:(UIImage *)image recalculateFromImage:(BOOL)recalculate imageData:(NSData *)imageData forKey:(NSString *)key toDisk:(BOOL)toDisk 
- (void)storeImage:(UIImage *)image forKey:(NSString *)key;
- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk;


// Check if image exists
- (BOOL)diskImageExistsWithKey:(NSString *)key;
- (void)diskImageExistsWithKey:(NSString *)key completion:(SDWebImageCheckCacheCompletionBlock)completionBlock;

// Query the image cache
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;
- (UIImage *)imageFromDiskCacheForKey:(NSString *)key;
- (NSData *)diskImageDataBySearchingAllPathsForKey:(NSString *)key;
- (UIImage *)diskImageForKey:(NSString *)key;
- (NSOperation *)queryDiskCacheForKey:(NSString *)key done:(SDWebImageQueryCompletedBlock)doneBlock;
- (UIImage *)scaledImageForKey:(NSString *)key image:(UIImage *)image;

// Remove specified image
- (void)removeImageForKey:(NSString *)key;
- (void)removeImageForKey:(NSString *)key withCompletion:(SDWebImageNoParamsBlock)completion;
- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk;
- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(SDWebImageNoParamsBlock)completion;

// Setter and getter
- (void)setMaxMemoryCost:(NSUInteger)maxMemoryCost;
- (NSUInteger)maxMemoryCost;
- (NSUInteger)maxMemoryCountLimit;
- (void)setMaxMemoryCountLimit:(NSUInteger)maxCountLimit;

// Clear and clean
- (void)clearMemory;
- (void)clearDisk;
- (void)clearDiskOnCompletion:(SDWebImageNoParamsBlock)completion;
- (void)cleanDisk;
- (void)cleanDiskWithCompletionBlock:(SDWebImageNoParamsBlock)completionBlock;
- (void)backgroundCleanDisk;

// Cache Size
- (NSUInteger)getSize;
- (NSUInteger)getDiskCount;
- (void)calculateSizeWithCompletionBlock:(SDWebImageCalculateSizeBlock)completionBlock;

```

2.函数
```
NSUInteger SDCacheCostForImage(UIImage *image);
BOOL ImageDataHasPNGPreffix(NSData *data);

```

**具体实现：**

`SDImageCache` 的内存缓存是通过一个继承 `NSCache` 的 `AutoPurgeCache` 类来实现的，`NSCache` 是一个类似于 `NSMutableDictionary` 存储 key-value 的容器，主要有以下几个特点：
- 自动删除机制：当系统内存紧张时，`NSCache`会自动删除一些缓存对象
- 线程安全：从不同线程中对同一个 `NSCache` 对象进行增删改查时，不需要加锁
- 不同于 `NSMutableDictionary`，`NSCache`存储对象时不会对 key 进行 copy 操作

`SDImageCache` 的磁盘缓存是通过异步操作 `NSFileManager` 存储缓存文件到沙盒来实现的。

1. 初始化

`-init` 方法中默认调用了 `-initWithNamespace:` 方法，`-initWithNamespace:` 方法又调用了 `-makeDiskCachePath:` 方法来初始化缓存目录路径， 同时还调用了 `-initWithNamespace:diskCacheDirectory:` 方法来实现初始化。下面是初始化方法调用栈：


```
-init
    -initWithNamespace:
        -makeDiskCachePath:
        -initWithNamespace:diskCacheDirectory:
```

`-initWithNamespace:diskCacheDirectory:` 是一个 Designated Initializer，这个方法中主要是初始化实例变量、属性，设置属性默认值，并根据 namespace 设置完整的缓存目录路径，除此之外，还针对 iOS 添加了通知观察者，用于内存紧张时清空内存缓存，以及程序终止运行时和程序退到后台时清扫磁盘缓存。


2. 写入缓存

写入缓存的操作主要是由 `- storeImage:recalculateFromImage:imageData:forKey:toDisk:` 方法处理的，在存储缓存数据时，先计算图片像素大小，并存储到内存缓存中去，然后如果需要存到磁盘（沙盒）中，就开启异步线程将图片的二进制数据存储到磁盘（沙盒）中。

如果需要在存储之前将传进来的 `image` 转成 `NSData`，而不是直接使用传入的 `imageData`，那么就要针对 iOS 系统下，按不同的图片格式来转成对应的 `NSData` 对象。那么图片格式是怎么判断的呢？这里是根据是否有 alpha 通道以及图片数据的[前 8 位字节](http://www.w3.org/TR/PNG-Structure.html)来判断是不是 PNG 图片，不是 PNG 的话就按照 JPG 来处理。

将图片数据存储到磁盘（沙盒）时，需要提供一个包含文件名的路径，这个文件名是一个对 `key` 进行 MD5 处理后生成的字符串。

```
- (void)storeImage:(UIImage *)image recalculateFromImage:(BOOL)recalculate imageData:(NSData *)imageData forKey:(NSString *)key toDisk:(BOOL)toDisk {
    # 1. 添加内存缓存
        # 1.1 计算图片像素大小
        # 1.2 将 image 存入 memCache 中

    # 2. 如果需要存储到沙盒的话，就异步执行磁盘缓存操作
        # 2.1 如果需要 recalculate (重新转 data)或者传进来的 imageData 为空的话，就再转一次 data，因为存为文件的必须是二进制数据
            # 2.1.1 如果 imageData 为 nil，就根据 image 是否有 alpha 通道来判断图片是否是 PNG 格式的
            # 2.1.2 如果 imageData 不为 nil，就根据 imageData 的前 8 位字节来判断是不是 PNG 格式的，因为 PNG 图片有一个唯一签名，前 8 位字节是（十进制）： 137 80 78 71 13 10 26 10
            # 2.1.3 根据图片格式将 UIImage 转为对应的二进制数据 NSData

        # 2.2 借助 NSFileManager 将图片二进制数据存储到沙盒，存储的文件名是对 key 进行 MD5 处理后生成的字符串

}
```

3.读取缓存

`SDWebImage` 在给 `UIImageView` 加载图片时首先需要查询缓存，查询缓存的操作主要是 `-queryDiskCacheForKey:done:` 方法来实现的，该方法首先会调用 `-imageFromMemoryCacheForKey` 方法来查询内存缓存，也就是从 `memCache` 中去找，如果找到了对应的图片（一个 `UIImage` 对象），就直接回调 `doneBlock`，并直接返回。 如果内存缓存中没有找到对应的图片，就开启异步队列，调用 `-diskImageForKey` 读取磁盘缓存，读取成功之后，再保存到内存缓存，最后再回到主队列，回调 `doneBlock`。

其中读取磁盘缓存并不是一步就完成了的，读取磁盘缓存时，会先从沙盒中去找，如果沙盒中没有，再从 `customPaths` （也就是 bundle）中去找，找到之后，再对数据进行转换，后面的图片处理步骤跟图片下载成功后的图片处理步骤一样——先将 data 转成 image，再进行根据文件名中的 @2x、@3x 进行缩放处理，如果需要解压缩，最后再解压缩一下。

```
- (NSOperation *)queryDiskCacheForKey:(NSString *)key done:(SDWebImageQueryCompletedBlock)doneBlock {
    # 1.先检查内存缓存，如果找到了就回调 doneBlock，并直接返回
    
    # 2.开启异步队列，读取硬盘缓存
        # 2.1 读取磁盘缓存
        # 2.2 如果有磁盘缓存，就保存到内存缓存
        # 2.3 回到主队列，回调 doneBlock
}
```

4.清扫磁盘缓存

每新加载一张图片，就会新增一份缓存，时间一长，磁盘上的缓存只会越来越多，所以我们需要定期清除部分缓存。值得注意的是，清扫磁盘缓存（clean）和清空磁盘缓存（clear）是两个不同的概念，清空是删除整个缓存目录，清扫只是删除部分缓存文件。

清扫磁盘缓存有两个指标：一是缓存有效期，二是缓存体积最大限制。`SDImageCache`中的缓存有效期是通过 `maxCacheAge` 属性来设置的，默认值是 1 周，缓存体积最大限制是通过 `maxCacheSize` 来设置的，默认值为 0。

`SDImageCache` 在初始化时添加了通知观察者，所以在应用即将终止时和退到后台时，都会调用 `-cleanDiskWithCompletionBlock:` 方法来异步清扫缓存，清扫磁盘缓存的逻辑是，先遍历所有缓存文件，并根据文件的修改时间来删除过期的文件，同时记录剩下的文件的属性和总体积大小，如果设置了 `maxCacheAge` 属性的话，接下来就把剩下的文件按修改时间从小到大排序（最早的排最前面），最后再遍历这个文件数组，一个一个删，直到总体积小于 desiredCacheSize 为止，也就是 maxCacheSize 的一半。


**知识点**

1. `NSCache` 是什么？

	参考：
	[NSCache Class Refernce](https://developer.apple.com/reference/foundation/nscache)
	*Effective Objective-C 2.0*（Item 50: Use `NSCache` Instead of `NSDictionary` for Caches）
	[Foundation: NSCache](http://southpeak.github.io/2015/02/11/cocoa-foundation-nscache/)
	[NSCache 源码（Swift）分析](https://github.com/nixzhu/dev-blog/blob/master/2015-12-09-nscache.md)
	[YYCache 设计思路](http://blog.ibireme.com/2015/10/26/yycache/)

2. 文件操作和 `NSDirectoryEnumerator` 

3. 如何判断一个图片的格式是 PNG 还是 JPG？

### 3. 图片加载管理器——SDWebImageManager

**.h 文件中的属性：**

**.m 文件中的属性：**

**.h 文件中的方法：**

**.m 文件中的方法：**

**方法实现：**

**知识点**

### 4. 设置 UIImageView 的图片——UIImageView+WebCache

**.h 文件中的属性：**

**.m 文件中的属性：**

**.h 文件中的方法：**

**.m 文件中的方法：**

**方法实现：**

**知识点**


## 四、知识点

2. `TARGET_OS_IPHONE` 宏和 `__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0` 宏的使用
这两个宏都是用于**编译时**进行 SDK 版本适配的宏，主要用于模拟器上的调试，而针对真机上的 iOS 版本适配就需要采用**运行时**的判断方式了，比如使用 respondsToSelector: 方法来判断当前运行环境是否支持该方法的调用。       
   
   参考：http://stackoverflow.com/questions/3269344/what-is-difference-between-these-2-macros/3269562#3269562
http://stackoverflow.com/questions/7542480/what-are-the-common-use-cases-for-iphone-os-version-max-allowed

3. `typeof` 和 `__typeof`，`__typeof__` 的区别       
   
   参考：http://stackoverflow.com/questions/14877415/difference-between-typeof-typeof-and-typeof-objective-c

4. 使用 `-[UIApplication beginBackgroundTaskWithExpirationHandler:]` 方法使 app 退到后台时还能继续执行任务, 不再执行后台任务时，需要调用 `-[UIApplication endBackgroundTask:]` 方法标记后台任务结束。
    参考：https://developer.apple.com/reference/uikit/uiapplication/1623031-beginbackgroundtaskwithexpiratio
         [objective c - Proper use of beginBackgroundTaskWithExpirationHandler](http://stackoverflow.com/questions/10319643/objective-c-proper-use-of-beginbackgroundtaskwithexpirationhandler)
         [iOS Tips and Tricks: Working in the Background](https://www.infragistics.com/community/blogs/stevez/archive/2013/01/24/ios-tips-and-tricks-working-in-the-background.aspx)
         [Background Modes Tutorial: Getting Started](https://www.raywenderlich.com/143128/background-modes-tutorial-getting-started)


5. `NSFoundationVersionNumber` 的使用         
   
   参考：http://stackoverflow.com/questions/19990900/nsfoundationversionnumber-and-ios-versions


7. `SDWebImage` 文档中的两张 Architecture 图怎么看？什么是 UML 类图？



10. `SDWebImage` 的缓存路径？      
    格式：Libray/Cache/<#namespace#>/com.hackemist.SDWebImageCache.<#namespace#>/<#MD5_filename#>
    如果是默认的 namespace，那么路径就是 `Library/cache/default/com.hackemist.SDWebImageCache.default/<#MD5_filename#>`，详见 `-storeImage:recalculateFromImage:imageData:forKey:toDisk` 方法和 `-defaultDiskCachePath` 方法
     

11. 文件的缓存有效期及最大缓存空间大小
    
    - 默认有效期：```maxCacheAge = 60 * 60 * 24 * 7; // 1 week```
    - 默认最大缓存空间：```maxCacheSize = <#unlimited#>```
 
12. `MKAnnotationView` 是用来干嘛的？     
    `MKAnnotationView` 是属于 `MapKit` 框架的一个类，继承自 `UIView`，是用来展示地图上的 annotation 信息的，它有一个用来设置图片的属性 `image` 。    
    See [API Reference: MKAnnotationView](https://developer.apple.com/reference/mapkit/mkannotationview)

13. 图片下载完成后，为什么需要用 `SDWebImageDecoder` 进行解码？

14. `SDWebImage` 中图片缓存的 key 是按照什么规则取的？

15. `SDImageCache` 清除磁盘缓存的过程？

16. md5 是什么算法？是用来干什么的？除此之外，还有哪些类似的加密算法？


17. `SDImageCache` 读取磁盘缓存是不是就是指从沙盒中查找并读取文件？
 
## 五、收获与疑问
1. UIImageView 是如何通过 SDWebImage 加载图片的？
2. SDWebImage 在设计上有哪些巧妙之处？
3. 假如我自己来实现一个图片下载工具，我该怎么写？
4. SDWebImage 的进化史
    - [1.0](https://github.com/rs/SDWebImage/tree/1.0)
    - [2.0](https://github.com/rs/SDWebImage/tree/2.0)
    - [3.0](https://github.com/rs/SDWebImage/tree/3.0)
    - [4.0.0](https://github.com/rs/SDWebImage/tree/4.0.0)
5. SDWebImage 的性能怎么看？
6. SDWebImage 是如何处理 gif 图的？


## 六、延伸阅读
- [iOS 源代码分析 --- SDWebImage](https://github.com/Draveness/Analyze/blob/master/contents/SDWebImage/iOS%20源代码分析%20---%20SDWebImage.md)（Draveness）
- [SDWebImage实现分析](http://southpeak.github.io/2015/02/07/sourcecode-sdwebimage/)（南峰子老驴）
- [iOS image caching. Libraries benchmark (SDWebImage vs FastImageCache)](https://bpoplauschi.wordpress.com/2014/03/21/ios-image-caching-sdwebimage-vs-fastimage/)（SDWebImage 的主要维护者：bpoplauschi）
- [使用SDWebImage和YYImage下载高分辨率图，导致内存暴增的解决办法](http://www.jianshu.com/p/1c9de8dea3ea)
- [SDWebImage 源码阅读笔记](http://itangqi.me/2016/03/19/the-notes-of-learning-sdwebimage-one/)
- [SDWebImage源码阅读系列](http://www.cnblogs.com/polobymulberry/category/785704.html)
 

