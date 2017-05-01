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

### 3. [SDWebImage 与其他框架的对比]
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
 
下载 [Source code(3.7.3)](https://github.com/rs/SDWebImage/archive/3.7.3.zip)，打开 `SDWebImage Demo.xcodeproj`，从 `MasterViewController` 中的 `[cell.imageView sd_setImageWithURL:url placeholderImage:placeholderImage];` 开始看。

经过层层调用，直到 `UIImageView+WebCache` 中最核心的方法 `sd_setImageWithURL: placeholderImage: options: progress: completed:`。该方法中，主要做了以下几件事：
   - 取消当前正在进行的加载任务 operation
   - 设置 placeholder
   - 如果 URL 不为 `nil`，就通过 `SDWebImageManager` 单例开启图片加载任务 operation，`SDWebImageManager` 的图片加载方法中会返回一个 `SDWebImageCombinedOperation` 对象，这个对象包含一个 cacheOperation 和一个 cancelBlock。

`SDWebImageManager` 的图片加载方法 `downloadImageWithURL:options:progress:completed:` 中会先拿图片缓存的 key （这个 key 默认是图片 URL）去 `SDImageCache` 单例中读取内存缓存，如果有，就返回给 `SDWebImageManager`；如果内存缓存没有，就开启异步线程，拿经过 MD5 处理的 key 去读取磁盘缓存，如果找到磁盘缓存了，就同步到内存缓存中去，然后再返回给 `SDWebImageManager`。

如果内存缓存和磁盘缓存中都没有，`SDWebImageManager` 就会调用 `SDWebImageDownloader` 单例的 `downloadImageWithURL: options: progress: completed:` 方法去下载，该会先将传入的 `progressBlock` 和 `completedBlock` 保存起来，并在第一次下载该 URL 的图片时，创建一个 `NSMutableURLRequest` 对象和一个 `SDWebImageDownloaderOperation` 对象，并将该 `SDWebImageDownloaderOperation` 对象添加到 `SDWebImageDownloader` 的`downloadQueue` 来启动异步下载任务。

`SDWebImageDownloaderOperation` 中包装了一个 `NSURLConnection` 的网络请求，并通过 runloop 来保持 `NSURLConnection` 在 start 后、收到响应前不被干掉，下载图片时，监听 `NSURLConnection` 回调的 `-connection:didReceiveData:` 方法中会负责 progress 相关的处理和回调，`- connectionDidFinishLoading:` 方法中会负责将 data 转为 image，以及图片解码操作，并最终回调 completedBlock。

`SDWebImageDownloaderOperation` 中的图片下载请求完成后，会回调给 `SDWebImageDownloader`，然后 `SDWebImageDownloader` 再回调给 `SDWebImageManager`，`SDWebImageManager` 中再将图片分别缓存到内存和磁盘上（可选），并回调给 `UIImageView`，`UIImageView` 中再回到主线程设置 `image` 属性。至此，图片的下载和缓存操作就圆满结束了。


## 三、实现细节

### 1. 设置 UIImageView 的图片——UIImageView+WebCache

### 2. 图片加载管理器——SDWebImageManager

### 3. 图片缓存——SDImageCache

### 4. 图片下载
### 4.1 SDWebImageDownloader

**公开属性：**

**内部属性：**

**方法的调用：**
- 调用 `+ [SDWebImageDownloader sharedDownloader]` 方法获取单例
- 调用 `- [SDWebImageDownloader downloadImageWithURL: options: progress: completed:]` 方法开启下载
     - 调用 `- [SDWebImageDownloader addProgressCallback: andCompletedBlock: forURL: createCallback: ]` 方法
		- 调用 `- [SDWebImageDownloaderOperation initWithRequest: options: progress:]` 方法



```
- (id)init {
	#设置下载 operation 的默认执行顺序（先进先出还是先进后出）
	#初始化 _downloadQueue（下载队列），_URLCallbacks（下载回调 block 的容器），_barrierQueue（GCD 队列）
	#设置 _downloadQueue 的最大并发数
	#设置 _HTTPHeaders 初始值 Accept : image/webp,image/*;q=0.8
	#设置默认下载超时时长 15s 
}

```



```

- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url options:(SDWebImageDownloaderOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageDownloaderCompletedBlock)completedBlock {
	 #1. 调用 - [SDWebImageDownloader addProgressCallback: andCompletedBlock: forURL: createCallback: ] 方法，直接把入参 url、progressBlock 和 completedBlock 传进该方法，并在回调 block 中
		## createCallback 的回调处理：{
		  1.1 计算超时时长 downloadTimeout（默认 15s）
	   		  1.2 创建下载 request ，设置 request 的 cachePolicy、HTTPShouldHandleCookies、HTTPShouldUsePipelining，以及 allHTTPHeaderFields（这个属性交由外面处理，设计的比较巧妙）
		  1.3 创建 SDWebImageDownloaderOperation（继承自 NSOperation）
		      ### SDWebImageDownloaderOperation 的 progressBlock 回调处理 {
		      		  （这个 block 有两个回调参数：接收到的数据大小和预计数据大小）
		      	 	  这里用了 weak-strong dance
		      	 	  首先使用 strongSelf 强引用 weakSelf，目的是为了保住 self 不被释放  
		      	 	  然后检查 self 是否已经被释放（这里为什么先“保活”后“判空”呢？因为如果先判空的话，有可能判空后 self 就被释放了）
		      	 	  取出 url 对应的回调 block 数组（这里取的时候有些讲究，考虑了多线程问题，而且取的是 copy 的内容）
		      	 	  遍历数组，从每个元素（字典）中取出 progressBlock 进行回调 	  
		      	   }
		      ### SDWebImageDownloaderOperation 的 completedBlock 回调处理 {
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
		  1.4 如果设置了 username 和 password，就给 operation 的下载请求设置一个 NSURLCredential  
		  1.5 设置 operation 的队列优先级
		  1.6 将 operation 加入到队列 downloadQueue 中，队列（NSOperationQueue）会自动管理 operation 的执行
		  1.7 如果 operation 执行顺序是先进后出，就设置 operation 依赖关系（先加入的依赖于后加入的），并记录最后一个 operation（lastAddedOperation）
		}

	 #2. 返回 createCallback 中创建的 operation（SDWebImageDownloaderOperation）
}



```

``` 
- (void)addProgressCallback:(SDWebImageDownloaderProgressBlock)progressBlock andCompletedBlock:(SDWebImageDownloaderCompletedBlock)completedBlock forURL:(NSURL *)url createCallback:(SDWebImageNoParamsBlock)createCallback {
	#1. 判断 url 是否为 nil，如果为 nil 则直接回调 completedBlock，返回失败的结果，然后 return，因为 url 会作为存储 callbacks 的 key
	
	#2. 处理同一个 URL 的多次下载请求（MARK: 这里为什么用了 dispatch_barrier_sync 函数)：
	  ## 从属性 URLCallbacks(一个字典) 中取出对应 url 的 callBacksForURL(这是一个数组，因为可能一个 url 不止在一个地方下载)
	  ## 如果没有取到，也就意味着这个 url 是第一次下载，那就初始化一个 callBacksForURL 放到属性 URLCallbacks 中
	  ## 往数组 callBacksForURL 中添加 包装有 callbacks（progressBlock 和 completedBlock）的字典
	  ## 更新 URLCallbacks 存储的对应 url 的 callBacksForURL
	  
	#3. 如果这个 url 是第一次请求下载，就回调 createCallback

}


```


问题：
1. SDWebImageDownloaderOptions 枚举使用了位运算
   应用：通过“与”运算符，可以判断是否设置了某个枚举选项，因为每个枚举选择项中只有一位是1，其余位都是 0，所以只有参与运算的另一个二进制值在同样的位置上也为 1，与 运算的结果才不会为 0.
   ```
     0101 (相当于 SDWebImageDownloaderLowPriority | SDWebImageDownloaderUseNSURLCache)
   & 0100 (= 1 << 2，也就是 SDWebImageDownloaderUseNSURLCache)
   = 0100 (> 0，也就意味着 option 参数中设置了 SDWebImageDownloaderUseNSURLCache)
   ```
2. dispatch_barrier_sync 函数的使用
3. weak-strong dance 的使用
4. HTTP header 的理解
5. NSOperationQueue 的使用
6. NSURLRequest 的 cachePolicy、HTTPShouldHandleCookies、HTTPShouldUsePipelining
7. NSURLCredential 


### 4.2 SDWebImageDownloaderOperation

`SDWebImageDownloaderOperation` 继承 `NSOperation`，遵守 `SDWebImageOperation`、`NSURLConnectionDataDelegate` 协议。

**公开属性：**

```
@property (strong, nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, assign) BOOL shouldUseCredentialStorage;
@property (nonatomic, strong) NSURLCredential *credential;
@property (assign, nonatomic, readonly) SDWebImageDownloaderOptions options;
```

**内部属性：**

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
------------------
// 成员变量
size_t width, height;
UIImageOrientation orientation;
BOOL responseFromCached;
```

**公开方法：**

```
- (id)initWithRequest:(NSURLRequest *)request
              options:(SDWebImageDownloaderOptions)options
             progress:(SDWebImageDownloaderProgressBlock)progressBlock
            completed:(SDWebImageDownloaderCompletedBlock)completedBlock
            cancelled:(SDWebImageNoParamsBlock)cancelBlock;    
- (void)start; // 继承自 NSOperation
- (void)cancel; // 继承自 NSOperation
```
         
**非公开方法：**        
    
```
- (void)cancelInternalAndStop;
- (void)cancelInternal;
- (void)done;
- (void)reset;
- (void)setFinished:(BOOL)finished; // 重写 setter 方法
- (void)setExecuting:(BOOL)executing; // 重写 setter 方法
- (BOOL)isConcurrent; // 重写 getter 方法
-----------
+ (UIImageOrientation)orientationFromPropertyValue:(NSInteger)value;
- (UIImage *)scaledImageForKey:(NSString *)key image:(UIImage *)image;
- (BOOL)shouldContinueWhenAppEntersBackground;
-------------
// NSURLConnectionDataDelegate 方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection __unused *)connection;
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
```        

**方法实现：**

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


```
- (void)start {
	# 给 `self` 加锁（MARK：为什么？） {
		## 如果 `self` 被 cancell 掉的话，finished 属性变为 YES，reset 下载数据和回调 block，然后直接 return。

		## 如果允许程序退到后台后继续下载，就开启一个后台任务，在后台任务过期的回调 block 中 {
			首先来一个 weak-strong dance
			调用 cancel 方法（这个方法里面又做了一些处理，反正就是 cancel 掉当前的 operation）
			调用UIApplication 的 endBackgroundTask： 方法结束任务
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
	# 下载完成后，结束后台任务
}
```

### 5. 图片解码——SDWebImageDecoder

## 四、知识点
1. `NSOperation` 的 `start` 方法和 `cancel` 方法

2. `TARGET_OS_IPHONE` 宏和 `__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0` 宏的使用
这两个宏都是用于**编译时**进行 SDK 版本适配的宏，主要用于模拟器上的调试，而针对真机上的 iOS 版本适配就需要采用**运行时**的判断方式了，比如使用 respondsToSelector: 方法来判断当前运行环境是否支持该方法的调用。
参考：http://stackoverflow.com/questions/3269344/what-is-difference-between-these-2-macros/3269562#3269562
http://stackoverflow.com/questions/7542480/what-are-the-common-use-cases-for-iphone-os-version-max-allowed

3.`typeof` 和 `__typeof`，`__typeof__` 的区别
http://stackoverflow.com/questions/14877415/difference-between-typeof-typeof-and-typeof-objective-c

4.使用 -[UIApplication beginBackgroundTaskWithExpirationHandler:] 方法在 app 后台执行任务

5.`NSFoundationVersionNumber` 的使用
http://stackoverflow.com/questions/19990900/nsfoundationversionnumber-and-ios-versions

6. `-start` 方法中为什么要调用 `CFRunLoopRun()` 或者 `CFRunLoopRunInMode()`函数？
参考：
- http://stanoz-io.top/2016/05/17/NSRunLoop_Note/
- http://tom555cat.com/2016/08/01/SdWebImage之RunLoop/
- http://blog.ibireme.com/2015/05/18/runloop/
- https://github.com/rs/SDWebImage/issues/497
- https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html

7.SDWebImage 文档中的两张 Architecture 图怎么看？什么是 UML 类图？


8.SDWebImageDownloaderOperation 中是什么时候开启异步线程的？

9.NSURLConnection 的几个代理方法分别在什么时候调用？

10.SDWebImage 的缓存路径？
从 `-storeImage:recalculateFromImage:imageData:forKey:toDisk` 方法中可以看出：
defaultDiskCachePath: /cache/fullNamespace/MD5_filename

11.文件的缓存有效期及最大缓存空间大小
默认有效期：maxCacheAge = 60 * 60 * 24 * 7; // 1 week
默认最大缓存空间：maxCacheSize = unlimited
 
12.`MKAnnotationView` 是用来干嘛的？
`MKAnnotationView` 是属于 `MapKit` 框架的一个类，继承自 `UIView`，是用来展示地图上的 annotation 信息的，它有一个用来设置图片的属性 `image` 。See [API Reference: MKAnnotationView](https://developer.apple.com/reference/mapkit/mkannotationview)

13.图片下载完成后，为什么需要用 `SDWebImageDecoder` 进行解码？
 
## 五、收获与疑问
1. UIImageView 是如何通过 SDWebImage 加载图片的？
2. SDWebImage 在设计上有哪些巧妙之处？


## 六、延伸阅读
- [iOS 源代码分析 --- SDWebImage](https://github.com/Draveness/Analyze/blob/master/contents/SDWebImage/iOS%20源代码分析%20---%20SDWebImage.md)（Draveness）
- [SDWebImage实现分析](http://southpeak.github.io/2015/02/07/sourcecode-sdwebimage/)（南峰子老驴）
- [iOS image caching. Libraries benchmark (SDWebImage vs FastImageCache)](https://bpoplauschi.wordpress.com/2014/03/21/ios-image-caching-sdwebimage-vs-fastimage/)
- [使用SDWebImage和YYImage下载高分辨率图，导致内存暴增的解决办法](http://www.jianshu.com/p/1c9de8dea3ea)
 

