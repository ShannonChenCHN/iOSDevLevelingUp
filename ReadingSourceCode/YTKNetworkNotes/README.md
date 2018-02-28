# [YTKNetwork](https://github.com/yuantiku/YTKNetwork)（2.0.4） 源码解析

## 目录

### 一、简介
#### 1. 设计目的
#### 2. 特性
#### 3. 用法
### 二、实现原理
#### 1. 架构图、流程图
#### 2. 目录结构
#### 3. 主要逻辑

- YTKBaseRequest：请求管理的抽象基类
- YTKRequest：继承 YTKRequest，封装了缓存处理的逻辑
- YTKNetworkAgent：YTKNetwork 的“心脏”，负责发
- YTKRequestAccessory：请求时处理弱逻辑的小插件，比如显示加载 loading、Toast 弹窗。这里设计的比较巧妙，真正达到了解耦的目的。体现了 POP 和 AOP 的思想。
- YTKNetworkUtils：工具类
- YTKNetworkConfig：全局配置类


YTKRequest 的 `- startWithCompletionBlockWithSuccess:failure:` 方法调用栈：

```
- [YTKRequest startWithCompletionBlockWithSuccess:failure:]
   - [YTKRequest setCompletionBlockWithSuccess: failure:]
   - [YTKRequest start]
      - [YTKRequest loadCacheWithError:]
      - [YTKRequest startWithoutCache:]
         - [YTKRequest clearCacheVariables]
         - [YTKBaseRequest start]
            - [YTKBaseRequest toggleAccessoriesWillStartCallBack]
            - [YTKNetworkAgent addRequest:]
               - [YTKNetworkAgent sessionTaskForRequest:error:]
                  - [YTKNetworkAgent requestSerializerForRequest:]  // 创建并返回 AFHTTPRequestSerializer
                  - [YTKNetworkAgent dataTaskWithHTTPMethod:requestSerializer:URLString:parameters:constructingBodyWithBlock:error:] 
                     - [AFHTTPRequestSerializer requestWithMethod:URLString:parameters:error:]  // 创建并返回 NSURLRequest
                     - [AFHTTPSessionManager dataTaskWithRequest:completionHandler:]  // 创建并返回 data task
               - [YTKNetworkAgent addRequestToRecord:]
               - [NSURLSessionTask resume]
```

请求回调时的方法调用栈：

```
- [AFHTTPSessionManager dataTaskWithRequest:completionHandler:] _block_invoke
   - [YTKNetworkAgent handleRequestResult:responseObject:error:] 
      - [AFJSONResponseSerializer responseObjectForResponse:data:error:]
      - [YTKNetworkAgent requestDidSucceedWithRequest:]
         - [YTKRequest requestCompletePreprocessor]
         - [YTKRequest toggleAccessoriesWillStopCallBack]
         - [YTKRequest requestCompleteFilter]
         - [id<YTKRequestDelegate> requestFinished]   // 代理回调
         - [YTKRequest successCompletionBlock](YTKRequest)  // block 回调
         - [YTKRequest  toggleAccessoriesDidStopCallBack]
      - [YTKNetworkAgent removeRequestFromRecord:]
      - [YTKRequest clearCompletionBlock]

```

#### 从设计的角度看 YTKNetwork：

1. YTKRequestAccessory 是一个协议，用来添加请求时处理弱逻辑的小插件，比如显示加载 loading、Toast 弹窗。这里设计的比较巧妙，真正达到了解耦的目的。体现了 POP 和 AOP 的思想。

2. 缓存的设计

- 缓存验证
  - 时效性
  - 版本校验
  - 其他校验

- 缓存数据包括元数据和接口内容数据（NSData），这种设计跟 NSURLSession 请求数据返回 NSURLResponse 和 NSData 的设计有点类似，而且元数据和接口内容数据是分开保存的，如果元数据验证失败后，就不读取内容数据了。

- 逻辑分离
  - 缓存跟网络请求是分离的，如果需要在首次打开页面时展示上次请求缓存下来的数据，可以先直接调用 `-loadCacheWithError` 直接读取数据，解析后并显示，然后再调用 `-startWith...` 方法正常发起请求。而不是一次请求做两件事，杂糅在一起。
  - `cacheTimeInSeconds` 控制是否缓存接口数据，以及缓存的有效性，`ignoreCache` 决定是否读取缓存。

- 数据存储
  - Archive
  - NSData

3. 线程

4. 内存管理

- 回调 block 置为 nil

5. 设计模式

- 命令模式

6. 网络层的设计

- 统一配置
- 翻页
- 缓存

7. 数据结构和算法

- 拓扑排序

8. 网络

- CDN


### 参考资料

- [YTKNetwork源码解析](https://www.jianshu.com/p/89dd444399ce)
- [源码解析之--YTKNetwork网络层](https://www.jianshu.com/p/521a6437a0b6)
- [YTKNetwork 网络框架详细分析与使用说明](https://github.com/3rdPartyLibraryAnalysis/YTKNetwork)
- [YTKNetwork集成教程以及相关问题思考](http://aes.jypc.org/?p=11408)