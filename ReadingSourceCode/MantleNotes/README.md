# [Mantle](https://github.com/Mantle/Mantle)(v2.1.0)源码解析
-------

## 基本介绍
### 使用注意点

1. 使用 Mantle 进行自动转换的自定义 model 类必须要遵循的两个条件：   
 - 继承 MTLModel 基类
 - 遵循 MTLJSONSerializing 协议，实现`-JSONKeyPathsByPropertyKey` 方法（该方法中没有声明的 propertyKey 在转换时会被忽略掉；而且只要有一个 propertyKey 写错就会解析失败）

2. 如果自定义 Mantle 子类中某些属性的类型跟 JSON Dictionary 中对应的值的类型不一致，有两种方式可以实现转换：
  - 实现 `+JSONTransformerForKey:` 方法
  - 实现 `属性名+JSONTransformer` 方法

3. 可以通过重写 `-initWithDictionary:error:` 方法，在转换完成后作进一步处理。

4. 重写自定义 model 的 `+classForParsingJSONDictionary:` 方法可以将当前 model 解析为一个不同的类的对象，这非常适用于使用了类簇的 model。

5. 当你的自定义 model 里的所有属性名和 JSON Dictionary 里的所有 key 的名字完全相同的时候，你就可以直接用 `NSDictionary+MTLMappingAdditions` 提供的 `-mtl_identityPropertyMapWithModel` 方法生成一个 NSDictionary，这样就不用自己写了：

```
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [NSDictionary mtl_identityPropertyMapWithModel:self];
}
```

## 二、实现原理
### 如何实现 JSON 转 Model


要求：
- 自动将 JSON Dictionary 中的 key-value 和 model 的属性对应起来


```
JSON Dictionary -> Model 
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

#### 1. runtime
- 获取属性列表：`class_copyPropertyList()`
- 判断属性类型：`property_getAttributes()`
- 注册选择器：`sel_registerName()`

#### 2. KVC

- `-setValue:forKeyPath:`
- `-setValue:forUndefinedKey:`
- `-setValuesForKeysWithDictionary:`
- `-dictionaryWithValuesForKeys:`

#### 3. NSValueTransformer

NSValueTransformer 是一个抽象类，用来将一个输入的类型值转换成另为一个类型值，主要被用于 AppKit 框架的 Cocoa binding 中。它指定了可以处理哪类输入，并且合适时甚至支持反向的转换。比如将 NSString 类型的对象转成 NSURL 类型的对象，将摄氏度转成华氏度等等。



参考：

- [NSValueTransformer - NSHipster](http://nshipster.cn/nsvaluetransformer/)
- [NSValueTransformer - Class Reference](https://developer.apple.com/documentation/foundation/nsvaluetransformer)
- [Value Transformer Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ValueTransformers/Concepts/CustomTransformer.html)
- [数据转换Transformer](http://www.macdev.io/ebook/transformer.html)

#### 4. NSSecureCoding

### 代码结构

#### 核心类

- MTLModel：是一个抽象类，遵循 MTLModel 协议，它主要实现了获取所有属性名以及将所有属性名和属性值以 key-value 形式保存到 NSDictionary 的逻辑，并且还提供了 `-copyWithZone:`、`-description`、`-hash`、`-isEqual:` 的默认实现。
- MTLModel+NSCoding：实现 NSCoding 协议，支持自动归档解档。
- MTLJSONAdapter：实现了 model 和 JSON dictionary 之间的相互转换逻辑，以及提供默认的 transformer。

#### 协议

- MTLModel：定义了 model 和 JSON 之间进行转换时所需要的基本接口，包括使用 NDDictionary 进行初始化的 initializer、存有属性名和属性值的 `dictionaryValue` 属性、获取所有属性名的 `-propertyKeys` 方法。需要与 JSON Dictionary 进行相互转换的自定义 model 类必须继承该类，才能被 Mantle 自动转换。
- MTLJSONSerializing：继承自 MTLModel 协议，定义了一些支持 JSON 和 MTLModel 之间互转的 API，主要包括定义属性名和 JSON key 之间的映射关系的方法 `+JSONKeyPathsByPropertyKey`、每个属性对应的转换器 `+JSONTransformerForKey`。需要与 JSON Dictionary 进行相互转换的 MTLModel 子类都需要实现该协议，才能被 Mantle 自动转换。


#### 辅助类

- MTLValueTransformer：继承自 NSValueTransformer 的转换器类，用于定义属性值的转换规则，比如将 `NSString` 类型的属性转成 `NSURL` 类型时，就需要用到。 
- EXTRuntimeExtensions：定义了读取 Objective-C 属性信息的函数，以及表示属性信息的结构体。

#### 其他工具类


### 主要逻辑

#### 1. JSON 转 model


方法调用栈：

```
+ [MTLJSONAdapter modelOfClass:fromJSONDictionary:error:]
	- [MTLJSONAdapter initWithModelClass:]              // 初始化 MTLJSONAdapter
  	   + [MTLModel JSONKeyPathsByPropertyKey]   // 获取属性-字段映射表
  	   + [MTLModel propertyKeys]   // 所有的属性名
  	   + [MTLJSONAdapter  valueTransformersForModelClass]
  	      + [MTLModel propertyKey##JSONTransformer]
  	      + [MTLModel JSONTransformerForKey:]
  	      + [MTLJSONAdapter transformerForModelPropertiesOfClass:]
  	      + [MTLJSONAdapter dictionaryTransformerWithModelClass:]
	- [MTLJSONAdapter modelFromJSONDictionary:error:]   // 返回 model 结果
	   + [MTLModel classForParsingJSONDictionary] 
	   - [JSONDictionary mtl_valueForJSONKeyPath]
	   - [MTLValueTransformer transformedValue:success:error:]
	   + [MTLModel modelWithDictionary:error:]
  	      - [MTLModel initWithDictionary:error:] 
  	         MTLValidateAndSetValue()
  	            - [MTLModel setValue:forKey:]  // 设置属性值
	   - [MTLModel validate:]
```

#### 2. model 转 JSON

### 细节
#### 1. NSParameterAssert()

#### 2. NSMapTable

#### 3. class_copyPropertyList、objc_property_t

#### 4. `@onExit`

Mantle 中引用了 [libextobjc](https://github.com/jspahrsummers/libextobjc) 这个库的几个文件，其中一个经典的宏就是 `@onExit`。


参考：

- [jspahrsummers/libextobjc](https://github.com/jspahrsummers/libextobjc)
- [如何在 Objective-C 的环境下实现 defer](https://draveness.me/defer)
- [黑魔法__attribute__((cleanup))](http://blog.sunnyxx.com/2014/09/15/objc-attribute-cleanup/)

#### 5. C 语言

- `memcpy`
- `int	 strcmp(const char *__s1, const char *__c);` 查找字符串s中首次出现字符c的位置
- `strncpy`
- `void *calloc(size_t n, size_t size);` 在内存的动态存储区中分配n个长度为size的连续空间，函数返回一个指向分配起始地址的指针；如果分配不成功，返回NULL。
- [利用指针计算字符串的长度](http://www.cnblogs.com/youxin/p/3232485.html)

#### 6. 有几种方式可以实现一个方法的调用？
（1）直接调用对象或者类的方法

（2）使用`-performSelector:`调用

（3）使用 `objc_msgSend()` 函数发消息


（4）NSInvocation

```
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
invocation.target = self;
invocation.selector = selector;
[invocation setArgument:&coder atIndex:2];
[invocation setArgument:&modelVersion atIndex:3];
[invocation invoke];

__unsafe_unretained id result = nil;
[invocation getReturnValue:&result];
```

（5）函数指针的调用比 Objective-C 的方法调用更快，因为中间少了消息发送、转发的流程。

```
// 这里为什么不用 performSelector: 方法？
IMP imp = [modelClass methodForSelector:selector];
NSValueTransformer * (*function)(id, SEL) = (__typeof__(function))imp;
NSValueTransformer *transformer = function(modelClass, selector);
	
if (transformer != nil) result[key] = transformer;
	
```

#### 6. `-arrayWithCapacity:` 和 `-array`方法

发现 Mantle 跟 AFNetworking 一样，很多地方在创建数组时用的是 `-arrayWithCapacity:` 方法

参考：

- [The Foundation Collection Classes - objc.io](https://www.objc.io/issues/7-foundation/collections/#should_i_use_arraywithcapacity)
- [Benchmarking - NSHipster](http://nshipster.cn/benchmarking/)
- [What is the advantage of using arrayWithCapacity](https://stackoverflow.com/a/24958401)
- [What is advantage of using arrayWithCapacity than using array?](https://stackoverflow.com/a/7141214)


### 性能

### 延伸阅读
- [Objective-C Runtime - 玉令天下](http://yulingtianxia.com/blog/2014/11/05/objective-c-runtime/)
- [Objective-C Runtime Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048)
- [ibireme ：iOS JSON 模型转换库评测](https://blog.ibireme.com/2015/10/23/ios_model_framework_benchmark/)（推荐）
- [叶孤城：《iOS进阶指南》试读之《Mantle解析》](http://ios.jobbole.com/86119/)（推荐）
- [iOS模型框架- Mantle 解读](http://www.jianshu.com/p/d9e66beedb8f)
- [Mantle实现分析 - 南峰子的技术博客](http://southpeak.github.io/2015/01/11/sourcecode-mantle/)
- [iOS开源库源码解析之Mantle](http://blog.csdn.net/hello_hwc/article/details/51548128)
- [Mantle源代码阅读笔记](http://blog.csdn.net/colorapp/article/details/50277317)
