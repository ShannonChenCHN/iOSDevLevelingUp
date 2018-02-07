# STWebPURLProtocol


这个框架的主要功能是为 UIWebView 提供了加载 WebP 图片的机制。


### 实现原理

通过自定义 NSURLProtocol 子类拦截加载 webp 图片的网路请求，然后在获取到图片数据后使用 webp 图片解码器进行解码，最终转成 NSData 数据回调给 client。

第一步，在 `+ canInitWithRequest:` 方法中，根据  URL 的 scheme 和扩展名来判断是否要处理拦截到的请求。

```
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	// 先判断是不是内部的请求，防止出现递归死循坏
	if ([self propertyForKey:STWebPURLRequestHandledKey inRequest:request] == STWebPURLRequestHandledValue) {
		return NO;
	}

	NSString * const requestURLScheme = request.URL.scheme.lowercaseString;

	// scheme 是否有 stwebp- 前缀，是否是 HTTP 请求
	BOOL canProbablyInit = NO;
	if ([requestURLScheme hasPrefix:STWebPURLProtocolSchemePrefix]) {
		NSString * const deprefixedScheme = [requestURLScheme substringFromIndex:STWebPURLProtocolSchemePrefixLength];
		canProbablyInit = [deprefixedScheme hasPrefix:@"http"];
	}
	// 是不是 webp 图片，是否是 HTTP 请求
	if (!canProbablyInit && [gSTWebPURLProtocolOptions[STWebPURLProtocolOptionClaimWebPExtension] boolValue]) {
		NSString * const requestURLPathExtension = request.URL.pathExtension.lowercaseString;
		if ([@"webp" isEqualToString:requestURLPathExtension]) {
			canProbablyInit = [requestURLScheme hasPrefix:@"http"];
		}
	}
	if (!canProbablyInit) {
		return NO;
	}
	request = [self st_canonicalRequestForRequest:request];
	return [NSURLConnection canHandleRequest:request];
}
```

第二步，在 `+ canonicalRequestForRequest:` 中将加工后的请求返回，做了三件事情：
- 去掉 URL 中的标记前缀 `twebp-`；
- 设置 HTTP header 的 Accept 类型为 `image/webp`；
- 设置内部请求标记 `STWebPURLRequestHandledKey`，防止内部请求出现递归死循环。

```
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return [self st_canonicalRequestForRequest:request];
}


+ (NSURLRequest *)st_canonicalRequestForRequest:(NSURLRequest *)request {
	NSURL *url = request.URL;
	NSString * const absoluteURLString = [url absoluteString];
	if ([absoluteURLString hasPrefix:STWebPURLProtocolSchemePrefix]) {
		url = [NSURL URLWithString:[absoluteURLString substringFromIndex:STWebPURLProtocolSchemePrefixLength]];
	}
	NSMutableURLRequest * const modifiedRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:request.cachePolicy timeoutInterval:request.timeoutInterval];
	[modifiedRequest addValue:@"image/webp" forHTTPHeaderField:@"Accept"];
	[self setProperty:STWebPURLRequestHandledValue forKey:STWebPURLRequestHandledKey inRequest:modifiedRequest];
	return modifiedRequest;
}
```

第三步，在 `- initWithRequest:cachedResponse:client:` 方法中创建 `NSURLConnection` 对象。

```
- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
	if ((self = [super initWithRequest:request cachedResponse:cachedResponse client:client])) {
		request = [self.class canonicalRequestForRequest:request];
		_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
		[_connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes]; // 确保 NSURLConnection 在 mainRunLoop 中 的NSRunLoopCommonModes 模式下回调
	}
	return self;
}
```

第四步，启动请求连接。
```
- (void)startLoading {
	[_connection start];
}
```
第五步，接收到服务器返回的 response 后，初始化 decoder 对象，回调 `client`。

```
- (void)connection:(NSURLConnection * __unused)connection didReceiveResponse:(NSURLResponse *)response {
	NSHTTPURLResponse * const httpResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;

	if (httpResponse.statusCode != 200) {
		[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
		return;
	}

	NSDictionary * const responseHeaderFields = @{
		@"Content-Type": @"image/png",
		@"X-STWebP": @"YES",
	};

	NSURLRequest * const request = self.request;
	NSHTTPURLResponse * const modifiedResponse = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"1.0" headerFields:responseHeaderFields];

	_decoder = [[STWebPStreamingDecoder alloc] init];
	[self.client URLProtocol:self didReceiveResponse:modifiedResponse cacheStoragePolicy:NSURLCacheStorageAllowed];
}
```

第六步，接收到服务器返回的图片数据后，更新 decoder 中的数据。

```
- (void)connection:(NSURLConnection * __unused)connection didReceiveData:(NSData *)data {
	[_decoder updateWithData:data];
}
```

最后，请求完成后，对图片数据进行编码，并转成 PNG 格式的二进制数据，并将这个 NSData 对象回传给 client。

```
- (void)connectionDidFinishLoading:(NSURLConnection * __unused)connection {
	NSError *error = nil;
	UIImage *image = [_decoder imageWithScale:1 error:&error];
	if (!image) {
		[self.client URLProtocol:self didFailWithError:error];
		return;
	}

	NSData *imagePNGData = UIImagePNGRepresentation(image);
	[self.client URLProtocol:self didLoadData:imagePNGData];
	[self.client URLProtocolDidFinishLoading:self];
}

```

### 几点小细节：

- 发起请求时，设置了 HTTP header 中 `Accept` 的值为 `image/webp`。
- 收到请求响应时，针对 status code 为 200 的情况，单独做了处理，在 header field 中新增了 2 个字段。

### 使用方法

直接在应用启动时，也就是 `application:didFinishLaunchingWithOptions:` 方法中注册该类即可：

```
[NSURLProtocol registerClass:[STWebPURLProtocol class]];
```


### 问题

- UIWebView 的请求本身是有缓存的，但是我在使用该库时发现每次打开 UIWebView 会比较慢，后来自己使用 RNCachingURLProtocol 进行离线缓存才有所改善。具体原因是什么呢？

- 直接采用 SDWebImage 进行图片下载、解码和缓存，是否更简单？

### 参考：
- [cysp/STWebPDecoder](https://github.com/cysp/STWebPDecoder)