# [YYWebImage](https://github.com/ibireme/YYWebImage)(v 1.0.4)学习笔记

## 目录
- [简介]()
  - [设计目的]()
  - [特性]()
  - [用法]()
- [实现原理]()
  - [流程图]()
  - [目录结构]()
- [实现细节]()
- [知识点]()
- [收获与疑问]()
- [延伸阅读]()

### 一、简介
#### 1. 设计目的
#### 2. 特性
#### 3. 用法
### 二、实现思路
#### 1. 流程图
#### 2. 目录结构
#### 3. 主要逻辑

UIImageView+YYWebImage
```
- (void)yy_setImageWithURL:(NSURL *)imageURL
placeholder:(UIImage *)placeholder
options:(YYWebImageOptions)options
progress:(YYWebImageProgressBlock)progress
transform:(YYWebImageTransformBlock)transform
completion:(YYWebImageCompletionBlock)completion
```

_YYWebImageSetter
```
- (int32_t)setOperationWithSentinel:(int32_t)sentinel
url:(NSURL *)imageURL
options:(YYWebImageOptions)options
manager:(YYWebImageManager *)manager
progress:(YYWebImageProgressBlock)progress
transform:(YYWebImageTransformBlock)transform
completion:(YYWebImageCompletionBlock)completion
```

YYWebImageManager
```
- (YYWebImageOperation *)requestImageWithURL:(NSURL *)url
options:(YYWebImageOptions)options
progress:(YYWebImageProgressBlock)progress
transform:(YYWebImageTransformBlock)transform
completion:(YYWebImageCompletionBlock)completion
```

YYWebImageOperation
```
- (instancetype)initWithRequest:(NSURLRequest *)request
options:(YYWebImageOptions)options
cache:(YYImageCache *)cache
cacheKey:(NSString *)cacheKey
progress:(YYWebImageProgressBlock)progress
transform:(YYWebImageTransformBlock)transform
completion:(YYWebImageCompletionBlock)completion
```


### 三、实现细节

### 四、知识点

### 五、收获与疑问

### 六、延伸阅读

- [YYWebImage 源码解析](http://www.jianshu.com/p/d318af67ce1e)


 












 
