# [Mantle](https://github.com/Mantle/Mantle)(v2.1.0)源码解析
-------

### 主要逻辑

```
+ [MTLJSONAdapter modelOfClass:fromJSONDictionary:error:]
	- [MTLJSONAdapter initWithModelClass:]              // 初始化 MTLJSONAdapter
	- [MTLJSONAdapter modelFromJSONDictionary:error:]   // 返回 model 结果
```

### 设计思路

- 从 JSON 映射到 Model 的原理
- 主要逻辑
  - 获取所有需要设置值的属性名
  - 获取 transformer（非核心逻辑）
  - 从 JSON Dictionary 中取出各属性名对应的值
  - 按照 transformer 的规则转换属性值（非核心逻辑）
  - 使用 KVC 设置属性的值

### 相关知识点

- 获取属性列表
- 判断属性类型


### 代码结构

### 细节
#### 1. NSParameterAssert()

#### 2. NSMapTable

#### 3. class_copyPropertyList、objc_property_t

#### 4. @onExit

#### 5. C 函数

- `memcpy`
- 函数指针

	```
	// 这里为什么不用 performSelector: 方法？
	IMP imp = [modelClass methodForSelector:selector];
	NSValueTransformer * (*function)(id, SEL) = (__typeof__(function))imp;
	NSValueTransformer *transformer = function(modelClass, selector);
	
	if (transformer != nil) result[key] = transformer;
	
	```
	
- `NSValueTransformer`

### 性能

### 延伸阅读
- [Objective-C Runtime - 玉令天下](http://yulingtianxia.com/blog/2014/11/05/objective-c-runtime/)
- [Objective-C Runtime Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048)
- [Mantle实现分析 - 南峰子的技术博客](http://southpeak.github.io/2015/01/11/sourcecode-mantle/)
- [iOS模型框架- Mantle 解读](http://www.jianshu.com/p/d9e66beedb8f)
- [iOS JSON 模型转换库评测 - ibireme](https://blog.ibireme.com/2015/10/23/ios_model_framework_benchmark/)
- [Mantle 源码分析](https://zhuanlan.zhihu.com/p/27381020)
- [《iOS进阶指南》试读之《Mantle解析》](http://ios.jobbole.com/86119/)
- [iOS开源库源码解析之Mantle](http://blog.csdn.net/hello_hwc/article/details/51548128)
- [Mantle源代码阅读笔记](http://blog.csdn.net/colorapp/article/details/50277317)
