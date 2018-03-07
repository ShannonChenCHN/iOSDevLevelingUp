# Objective-C Runtime


一、为什么说 Objective-C 是一门动态语言？
二、什么是 Runtime？
三、如何与 Runtime 打交道
四、Runtime 相关的基础数据结构
五、消息发送
六、动态方法解析
七、消息转发
八、健壮的实例变量 (Non Fragile ivars)
九、Objective-C Associated Objects
十、Method Swizzling
十一、Runtime 的实践应用
十二、使用 Runtime 技术时的注意点
十三、相关开源项目

### 一、为什么说 Objective-C 是一门动态语言？

Objective-C 语言是一门动态语言，它会尽可能将一些决定从编译、链接的时候推迟到运行时。然后在任何可能的时候动态做一些事情。这就意味着这门语言不仅仅需要一个编译器，而且还需要一个运行时系统（runtime system）来执行编译好的代码。这个运行时系统就像一个操作系统一样为 Objective-C 语言服务，正是因为它这门语言才能正常工作。

Objective-C 的动态特性决定了 Objective-C 是一门动态语言，说 Objective-C 是静态语言是相对于动态语言而言的， 常用的静态语言有 Swift、Java、C++ 等等。

那么决定一门语言是动态的还是静态的主要因素是什么呢？主要因素有两点：

- 方法派发（method dispatching）：当一个方法被调用时，何时以及由谁执行哪一段代码。
- 类型绑定（type binding）：何时确定一个变量是什么类型。

按照以上两个标准，可以这么区分静态语言和动态语言：

- 静态语言：使用静态的方法派发和早期类型绑定，也即是说方法和对象类型在编译器编译时就确定了。这就意味着，当程序运行时，你能够确定是哪一段代码在执行。
- 动态语言：所有的方法派发和类型绑定都是在运行时由 Objective-C Runtime 库确定的。通过 Runtime 库，我们可以自己控制方法派发和类型绑定。

Objective-C 的动态特性包括：

- 动态类型（Dynamic typing）：指对象的具体类型在运行时才能确定。
- 动态绑定（Dynamic binding）：是指把消息映射到方法实现的这一过程是在运行时，而不是在编译时完成的。因为 Objective-C 中的方法调用实际上是在发消息（比如，调用 `[receiver message]`，实际上会被编译器转化为：`objc_msgSend(receiver, selector)`），而 Objective-C 有一个消息转发的机制，所以一个方法被调用时是不可能在编译时就确定如何执行的，而是在运行时才决定怎么执行。
- 动态加载（Dynamic loading）：在运行时可以动态加载和链接新的 class 和 category。
- 动态方法决议（Dynamic Method Resolution）：动态提供方法的实现。Objective-C 的 `@dynamic` 关键字就属于动态方法决议，这个关键字告诉编译器其所指定的属性的 setter 和 getter 方法是在运行时动态提供的。
- 内省（Introspection）：在运行时检查对象自身信息。比如 NSObject 提供了 `-isKindOfClass:` 方法来检查一个对象的类型。


### 二、什么是 Objective-C Runtime？

![](http://lh6.ggpht.com/_bMMRN3vt0x0/S1CV5xGmTPI/AAAAAAAAAxI/1KfUF6SmfTw/Screen%20shot%202010-01-15%20at%2010.18.04%20AM.png?imgmax=800)


我们通常所说的 Objective-C Runtime，是指苹果官方提供的一套 runtime 开源库，它是用 C 和汇编所写的。这套 runtime 系统在 C 的基础上增加了面向对象的能力来实现 Objective-C。这意味着它能够加载类信息、执行方法派发（method dispatching）、方法转发等等。Objective-C Runtime 库构建了许多基础的数据结构，来支持 Objective-C 面向对象的能力。（在苹果[官网](https://opensource.apple.com/tarballs/objc4/)上可以下载 runtime 源代码，目前最新的版本是[objc4-723](https://opensource.apple.com/tarballs/objc4/objc4-723.tar.gz)）

> 注：runtime 其实有两个版本: “modern” 和 “legacy”。我们现在用的 Objective-C 2.0 采用的是现行 (Modern) 版的 runtime 系统，只能运行在 iOS 和 macOS 10.5 之后的 64 位程序中。

从广义上来讲，Objective-C Runtime 是一种特性、一种能力，它允许我们在运行时能够创建、修改和移除下面任何一项:

- Class
- Method
- Implementation
- Properties
- Instance variables

虽然我们在实际开发中几乎不需要知道 runtime 相关的知识，但是我们可以通过学习 Runtime 更好地理解 Objective-C Runtime 系统是如何工作的，以及可以怎样利用好它。除此之外，理解了 Runtime，我们还可以对 Objective-C 语言本身以及 app 是怎么运行的有更深的理解。


### 三、如何与 Runtime 打交道
1. Objective-C 源代码
2. NSObject 的方法
3. Runtime 的函数

### 四、Runtime 相关的基础数据结构

1. SEL
`SEL`，本质上是一个结构体指针，它是 selector 在 Objc 中的表示类型（Swift中是 Selector 类）。selector 是方法选择器，可以理解为区分方法的 ID，而这个 ID 的数据结构是SEL:

```
typedef struct objc_selector *SEL;
```

其实它就是个映射到方法的 C 字符串，你可以用 Objc 编译器命令 `@selector()` 或者 `Runtime` 系统的 `sel_registerName` 函数来获得一个 `SEL` 类型的方法选择器。

2. id
3. Class
3.1. cache_t
3.2. class_data_bits_t
3.3. class_ro_t
3.4. class_rw_t
3.5. realizeClass
4. Category
5. Method
6. Ivar
7. objc_property_t
8. protocol_t
9. IMP

### 五、消息发送

1. objc_msgSend 函数
2. 方法中的隐藏参数
3. 获取方法地址

### 六、动态方法解析
### 七、消息转发
1. 重定向
2. 转发
3. 转发和多继承
4. 替代者对象(Surrogate Objects)
5. 转发与继承

### 八、健壮的实例变量 (Non Fragile ivars)
### 九、Objective-C Associated Objects
### 十、Method Swizzling
### 十一、Runtime 的实践应用

- 查看闭源的或者苹果官方私有类的一些信息用于学习
- 给分类添加属性
- 调试闭源的代码
- JSON 转 Model（Mantle、YYModel）

### 十二、使用 Runtime 技术时的注意点
Runtime 是一把双刃剑，应该谨慎使用：

- 尽可能避免使用 runtime 来解决问题，如果能使用其他办法解决最好就用其他办法解决掉
- 使用 runtime 时，一定要清楚地知道自己在干什么，以免出现一些难以追踪的 bug
- 不要用 runtime 去修改系统框架的私有方法，以免应用提交审核时被拒
- 如果对系统的方法使用了 Method Swizzling 技术，一定要记得调用原来的实现。

### 十三、相关开源项目
- Aspects
- JSPatch


### 参考

- Runtime
  - [sunnyxx：重识 Objective-C Runtime - Smalltalk 与 C 的融合](http://blog.sunnyxx.com/2016/08/13/reunderstanding-runtime-0/)（推荐）
  - [sunnyxx：重识 Objective-C Runtime - 看透 Type 与 Value](http://blog.sunnyxx.com/2016/08/13/reunderstanding-runtime-1/)
  - [玉令天下：Objective-C Runtime](http://yulingtianxia.com/blog/2014/11/05/objective-c-runtime/)（推荐）
  - [喵神：深入Objective-C的动态特性](https://onevcat.com/2012/04/objective-c-runtime/)
  - [Understanding the Objective-C Runtime](http://cocoasamurai.blogspot.co.uk/2010/01/understanding-objective-c-runtime.html)（推荐）
  - [THE DOWN LOW ON OBJECTIVE-C RUNTIME](https://novemberfive.co/blog/objective-c-runtime/)
  - [Video Tutorial: Objective-C Runtime](https://www.raywenderlich.com/61318/video-tutorial-objective-c-runtime)
  - [Friday Q&A 2009-03-13: Intro to the Objective-C Runtime by Mike Ash](https://www.mikeash.com/pyblog/friday-qa-2009-03-13-intro-to-the-objective-c-runtime.html)
  - [Objective-C Runtime（二）：动态类型，动态绑定，动态方法决议，内省](http://liuduo.me/2018/02/01/objective-c-runtime-2-dynamic-typing-and-dynamic-binding/)
- Method Swizzling
  - [Method Swizzling - NSHipster](http://nshipster.cn/method-swizzling/)（推荐）
- Associated Objects
  - [Associated Objects - NSHipster](http://nshipster.cn/associated-objects/)

### 官方文档
- [Objective-C Runtime Programming Guide: Interacting with the Runtime](//link.zhihu.com/?target=https%3A//developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtInteracting.html)：这份文档主要介绍了 NSObject 类，以及 Objective-C 程序是如何跟 runtime 系统打交道的。另外，还介绍了运行时动态加载类和消息转发，以及当程序在运行时如何获取对象的信息。
- [Objective-C Runtime Reference](//link.zhihu.com/?target=https%3A//developer.apple.com/reference/objectivec/1657527-objective_c_runtime)
- [About Key-Value Coding](//link.zhihu.com/?target=https%3A//developer.apple.com/library/content/documentation/Cocoa/Conceptual/KeyValueCoding/)
- [Introduction to Key-Value Observing Programming Guide](//link.zhihu.com/?target=https%3A//developer.apple.com/library/content/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html)
- [Introspection - Concepts in Objective-C Programming](https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaEncyclopedia/Introspection/Introspection.html)

### 延伸阅读

- Category
  - [结合 category 工作原理分析 OC2.0 中的 runtime](https://bestswifter.com/runtime-category/)
  - [深入理解Objective-C：Category](https://tech.meituan.com/DiveIntoCategory.html)
- 应用与实践
  - [Runtime在实际开发中的应用](http://www.jianshu.com/p/851b21870d91)
  - [利用Runtime 实现自动化归档](http://www.jianshu.com/p/bd24c3f3cd0a)
  - [MLeaksFinder：精准 iOS 内存泄露检测工具](http://wereadteam.github.io/2016/02/22/MLeaksFinder/?from=singlemessage&isappinstalled=0)
  - [[iOS]利用runtime,解决多次点击相同button,导致重复跳转的问题](http://www.jianshu.com/p/65ce6471cd0f)
  - [iOS runtime实用篇--和常见崩溃say good-bye！](https://www.jianshu.com/p/5d625f86bd02)
- load 和 initialize
  - [Objective-C +load vs +initialize](http://blog.leichunfeng.com/blog/2015/05/02/objective-c-plus-load-vs-plus-initialize/)
  - [细说OC中的load和initialize方法](https://bestswifter.com/load-and-initialize/)
  - [你真的了解 load 方法么？](https://draveness.me/load)
  - [懒惰的 initialize 方法](https://draveness.me/initialize)
- Method Swizzling
  - [Method Swizzling 和 AOP 实践](http://tech.glowing.com/cn/method-swizzling-aop/)
- 关联对象
  - [关联对象 AssociatedObject 完全解析](https://draveness.me/ao) 
  - [如何实现 iOS 中的 Associated Object](https://draveness.me/retain-cycle3)
  
- 理论
  - [从源代码看 ObjC 中消息的发送](https://draveness.me/message) 
  - [深入解析 ObjC 中方法的结构](https://draveness.me/method-struct)
  - [深入理解Objective-C：方法缓存](https://tech.meituan.com/DiveIntoMethodCache.html)
  - [从 NSObject 的初始化了解 isa](https://draveness.me/isa)
  - [The Right Way to Swizzle in Objective-C](https://blog.newrelic.com/2014/04/16/right-way-to-swizzle/)
  - [Objective-C Runtime 运行时之一：类与对象](http://www.cocoachina.com/ios/20141031/10105.html)
  - [从AOP框架学习iOS Runtime](https://yq.aliyun.com/articles/3063)
  - [OC最实用的runtime总结，面试、工作你看我就足够了！](http://www.jianshu.com/p/ab966e8a82e2)
  - [让你快速上手Runtime](http://www.jianshu.com/p/e071206103a4)
  - [Glowing : Objective-C Runtime](http://tech.glowing.com/cn/objective-c-runtime/)  - [Objc Runtime](https://github.com/ming1016/study/wiki/Objc-Runtime)
  - [iOS 模块详解—「Runtime面试、工作」看我就 🐒 了 ^_^.](http://www.jianshu.com/p/19f280afcb24)
  - [iOS~runtime理解](http://www.jianshu.com/p/927c8384855a)
  - [神经病院objc runtime入院考试](http://blog.sunnyxx.com/2014/11/06/runtime-nuts/)
  - [神经病院Objective-C Runtime入院第一天——isa和Class](http://www.jianshu.com/p/9d649ce6d0b8)
  - [runtime 完整总结](http://www.jianshu.com/p/6b905584f536)
  - [Objective-C Runtime 基本使用](http://qiubaiying.top/2017/02/04/Objective-C-Runtime-基本使用/)
  - [Runtime 10种用法（没有比这更全的了）](http://www.jianshu.com/p/3182646001d1)
-   [Runtime全方位装逼指南](http://www.jianshu.com/p/efeb33712445)
  - [Objective-C特性：Runtime](http://www.jianshu.com/p/25a319aee33d)
  - [Runtime深度解析以及实用技巧（不扯淡，不套路）](http://www.jianshu.com/p/88d11bb12ba1)
  - [Objective-C Runtime 1小时入门教程](https://www.ianisme.com/ios/2019.html)
  - [Objective-C 的运行时以及 Swift 的动态性 - Realm Academy](https://academy.realm.io/cn/posts/mobilization-roy-marmelstein-objective-c-runtime-swift-dynamic/)
- 相关源码  
  - [Apple 官方开源的 objc4 源码](https://opensource.apple.com/tarballs/objc4/)
- 相关问题
  - [Using dispatch_once in method swizzling](https://stackoverflow.com/questions/29435788/using-dispatch-once-in-method-swizzling)