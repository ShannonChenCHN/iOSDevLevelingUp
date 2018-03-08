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
- 动态语言：所有的方法派发和类型绑定都是在运行时由 Objective-C runtime 库确定的。通过 runtime 库，我们可以自己控制方法派发和类型绑定。

Objective-C 的动态特性包括：

- 动态类型（Dynamic typing）：指对象的具体类型在运行时才能确定。
- 动态绑定（Dynamic binding）：是指把消息映射到方法实现的这一过程是在运行时，而不是在编译时完成的。因为 Objective-C 中的方法调用实际上是在发消息（比如，调用 `[receiver message]`，实际上会被编译器转化为：`objc_msgSend(receiver, selector)`），而 Objective-C 有一个消息转发的机制，所以一个方法被调用时是不可能在编译时就确定如何执行的，而是在运行时才决定怎么执行。
- 动态加载（Dynamic loading）：在运行时可以动态加载和链接新的 class 和 category。
- 动态方法决议（Dynamic Method Resolution）：动态提供方法的实现。Objective-C 的 `@dynamic` 关键字就属于动态方法决议，这个关键字告诉编译器其所指定的属性的 setter 和 getter 方法是在运行时动态提供的。
- 内省（Introspection）：在运行时检查对象自身信息。比如 NSObject 提供了 `-isKindOfClass:` 方法来检查一个对象的类型。


### 二、什么是 Objective-C Runtime？

![](http://lh6.ggpht.com/_bMMRN3vt0x0/S1CV5xGmTPI/AAAAAAAAAxI/1KfUF6SmfTw/Screen%20shot%202010-01-15%20at%2010.18.04%20AM.png?imgmax=800)


我们通常所说的 Objective-C runtime，是指苹果官方提供的一套 runtime 开源库（`/usr/lib/libobjc.A.dylib`），它是用 C 和汇编所写的。这套 runtime 系统在 C 的基础上增加了面向对象的能力来实现 Objective-C。这意味着它能够加载类信息、执行方法派发（method dispatching）、方法转发等等。Objective-C runtime 库构建了许多基础的数据结构，来支持 Objective-C 面向对象的能力。（在苹果[官网](https://opensource.apple.com/tarballs/objc4/)上可以下载 runtime 源代码，目前最新的版本是[objc4-723](https://opensource.apple.com/tarballs/objc4/objc4-723.tar.gz)）

> 注：runtime 其实有两个版本: “modern” 和 “legacy”。我们现在用的 Objective-C 2.0 采用的是现行 (Modern) 版的 runtime 系统，只能运行在 iOS 和 macOS 10.5 之后的 64 位程序中。

从广义上来讲，Objective-C runtime 是一种特性、一种能力，它允许我们在运行时能够创建、修改和移除下面任何一项:

- Class
- Method
- Implementation
- Properties
- Instance variables

虽然我们在实际开发中几乎不需要知道 runtime 相关的知识，但是我们可以通过学习 runtime 更好地理解 Objective-C runtime 系统是如何工作的，以及可以怎样利用好它。除此之外，理解了 runtime，我们还可以对 Objective-C 语言本身以及 app 是怎么运行的有更深的理解。

#### Objective-C 对象是什么？

1. 一个 Objective-C 对象实际上是一个 C 语言结构体。

为什么说是结构体，而不是结构体指针呢？

根据维基百科中对[指针](https://zh.wikipedia.org/wiki/%E6%8C%87%E6%A8%99_(%E9%9B%BB%E8%85%A6%E7%A7%91%E5%AD%B8))的定义：

> 指针是编程语言中的一类数据类型及其对象或变量，用来表示或存储一个内存地址，这个地址的值直接指向（points to）存在该地址的对象的值。

简而言之，指针是一个存储地址（地址是一个数字）的数据类型。接下来看看维基百科中对[结构体](https://zh.wikipedia.org/wiki/%E7%BB%93%E6%9E%84%E4%BD%93_(C%E8%AF%AD%E8%A8%80))的定义：

> 结构体(struct)指的是一种数据结构，是C语言中复合数据类型(aggregate data type)的一类。结构体可以被声明为变量、指针或数组等，用以实现较复杂的数据结构。结构体同时也是一些元素的集合，这些元素称为结构体的成员(member)，且这些成员可以为不同的类型，成员一般用名字访问。

也就是说，结构体是一种复合数据结构，可以存储多个元素。

作为一个对象，要存储的显然不止是一个数字或者字符串。所以，从指针和结构体的特点来看，一个 Objective-C 对象不可能是指针，只能是结构体。

既然是这样，那为什么我们平时看到的 Objective-C 代码是下面这样的呢：

```
NSString *myString = // get a string from somewhere...
```

在苹果的官方文档 [Programming with Objective-C](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithObjects/WorkingwithObjects.html) 中，有这样一段话：

> C and Objective-C use variables to keep track of values, just like most other programming languages.
>
> There are a number of basic scalar variable types defined in standard C, including integers, floating-point numbers and characters.
> 
> ...
>
> Objective-C objects, by contrast, are allocated slightly differently. Objects normally have a longer life than the simple scope of a method call. In particular, an object often needs to stay alive longer than the original variable that was created to keep track of it, so an object’s memory is allocated and deallocated dynamically.
> 
> This requires you to use C pointers (which hold memory addresses) to keep track of their location in memory

简单概括一下，意思就是说，因为 Objective-C 对象是分配在堆上的，而 C 基础数据类型的变量是分配到栈上的，所以前者的生命周期通常比后者要长。对象的创建和销毁都是动态的，所以要想追踪对象，就要用一个指针来记录对象的地址。


> 参考：
> 
> - [指针究竟是什么？是地址？还是类型？ - fan wang的回答 - 知乎](https://www.zhihu.com/question/31022750/answer/50629732)
> - [指针 - 维基百科](https://zh.wikipedia.org/wiki/%E6%8C%87%E6%A8%99_(%E9%9B%BB%E8%85%A6%E7%A7%91%E5%AD%B8))
> [结构体 - 维基百科](https://zh.wikipedia.org/wiki/%E7%BB%93%E6%9E%84%E4%BD%93_(C%E8%AF%AD%E8%A8%80))
> - [Programming with Objective-C](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithObjects/WorkingwithObjects.html)


2. 我们通过调用 `-alloc` 方法创建一个 Objective-C 对象，其内部会调用 `-allocWithZone:` 方法，最终会调用 `malloc` 函数分配内存.


3. 每一个 Objective-C 对象都有一个 Class 类型的 `isa` 变量，而 Class 又有一个 `isa` 指针指向另一个 Class（Class 其实是一个类对象）。这个 `isa` 变量用来标识这个对象是什么类，不然 runtime 系统就不知道这个对象能干什么。


（1）每一个 NSObject 对象都有一个 Class 类型的 `isa` 变量

```
@interface NSObject  {
   Class	isa;
}
```

（2）每一个 NSProxy 对象也有一个 Class 类型的 `isa` 变量

```
@interface NSProxy  {
    Class	isa;
}
```

（3）每一个 *id* 类型的对象也有一个 Class 类型的 `isa` 变量

```
typedef struct objc_object {
    Class isa;
} *id;
```
  
#### Objective-C Class 是什么？

Class 本身是一个指向结构体的指针，这个结构体也有一个 Class 类型的成员变量。
 
```
typedef struct objc_class *Class;
struct objc_class {
        Class isa;
    
    #if !__OBJC2__
        Class super_class                                        OBJC2_UNAVAILABLE;
        const char *name                                         OBJC2_UNAVAILABLE;
        long version                                             OBJC2_UNAVAILABLE;
        long info                                                OBJC2_UNAVAILABLE;
        long instance_size                                       OBJC2_UNAVAILABLE;
        struct objc_ivar_list *ivars                             OBJC2_UNAVAILABLE;
        struct objc_method_list **methodLists                    OBJC2_UNAVAILABLE;
        struct objc_cache *cache                                 OBJC2_UNAVAILABLE;
        struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;
    #endif
    
} OBJC2_UNAVAILABLE;

```

除了 `isa` 变量之外，Class 还有一些保存 `super_class` 和 `name` 等基本信息的变量，和实例列表、方法列表、协议列表等附加信息（我们可以在运行时借助 `objc_` 和 `class_` 开头的一些函数获取甚至修改这些信息），以及用于缓存方法信息的 `cache` 变量（这个 cache 实际上是一个映射 selectors 和方法实现的 hash table）。


#### 为什么几乎所有的类都要继承 NSObject 类或者 NSProxy 类？

简单来讲，就是因为通过继承 NSObject 类，我们可以为我们的自定义类与 Objective-C runtime 打交道做好配置。


> 程序 = 算法 + 数据结构

一个 iOS 应用程序往往是由多个类组成的，所以我们想想看，一个 Objective-C 对象需要具备哪些基本要素？首先一个对象需要内存空间来存储数据，其次就是调用方法处理逻辑、操作数据。除此之外，还有一个需要描述对象所属类的信息的数据结构——`isa`。

而 NSObject 的作用就在于以下几点：

- 当我们调用 `+alloc` 方法时，就像文档中所说的(runtime 源码中的实现也是如此)，创建一个对象的主要逻辑包括两部分，一个是申请内存给对象本身，还有就是初始化 `isa` 实例变量。NSObject 提供的 `-alloc` 方法的默认实现就帮我们初始化了这个 `isa` 实例变量。
- 实现了默认的消息发送和消息转发的逻辑来支持 runtime，NSObject 就提供了 `-respondsToSelector:` 等方法的默认实现。 
- 提供了内存管理、引用计数相关的实现，比如调用 `-retain` 方法使引用计数加 1。
- 提供内省（Introspection）能力，比如判断一个类是什么类 `-isKindOfClass:`。

> 注：关于以上几点，NSProxy 类跟 NSObject 类做的事情大抵类似。

### 三、如何与 Runtime 打交道
1. Objective-C 源代码
2. NSObject 的方法
3. runtime 的函数

### 四、Runtime 相关的基础数据结构

1. SEL
`SEL`，本质上是一个结构体指针，它是 selector 在 Objc 中的表示类型（Swift中是 Selector 类）。selector 是方法选择器，可以理解为区分方法的 ID，而这个 ID 的数据结构是SEL:

```
typedef struct objc_selector *SEL;
```

其实它就是个映射到方法的 C 字符串，你可以用 Objc 编译器命令 `@selector()` 或者 `runtime` 系统的 `sel_registerName` 函数来获得一个 `SEL` 类型的方法选择器。

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

#### 1. 相关 API（[文档](https://developer.apple.com/documentation/objectivec/objective_c_runtime?language=objc)）

#### 1.1 数据结构

- `Class`
- `Method`
- `Ivar`
- `Category`
- `objc_property_t`
- `IMP` 
- `SEL`
- `objc_method_description`
- `objc_cache`
- `objc_protocol_list`
- `objc_property_attribute_t`


#### 1.2 函数
- Working with Classes：跟类打交道，比如使用`class_addMethod`函数 给类添加一个方法、使用 `class_getMethodImplementation`函数获取某个类的实例方法的实现。
- Adding Classes：动态添加、注册和移除一个类，比如通过 `objc_allocateClassPair` 函数来动态创建一个类。
- Instantiating Classes：实例化一个类，比如使用 `class_createInstance` 函数创建某个类的实例。
- Working with Instances：跟对象打交道，比如使用 `object_getClassName` 函数获取对象所属的类名。
- Obtaining Class Definitions：获取类定义信息，比如使用 `objc_copyClassList` 函数获取当前环境所有注册过的类。
- Working with Instance Variables：跟实例变量打交道，比如使用 `ivar_getName` 函数获取实例变量的名字。
- Associative References：设置、获取和移除关联引用，比如使用 `objc_setAssociatedObject` 函数可以添加关联对象。
- Sending Messages：发送消息，比如使用 `objc_msgSend` 函数给一个类的实例发送消息，并且获取返回值。
- Working with Methods：跟方法打交道，比如使用 `method_getImplementation` 函数获取一个方法的实现。
- Working with Libraries：跟加载到内存中的库打交道，比如使用 `objc_copyImageNames` 函数获取所有已经加载进内存的 Objective-C framework 和 动态库的名字。
- Working with Selectors：跟 selector 打交道，比如使用 `sel_getName` 获取指定选择器对应的方法名。
- Working with Protocols：跟 protocol 打交道，比如使用 `protocol_copyPropertyList` 函数获取指定协议的属性列表。
- Working with Properties：跟 property 打交道，比如使用 `protocol_copyPropertyList` 函数获取一个包含 property 的属性信息的字符串。
- Using Objective-C Language Features：跟 Objective-C 语言相关的特性，比如使用 `imp_implementationWithBlock` 使用 block 创建一个 IMP 函数指针，当该 IMP 对应的方法被调用时，这个函数指针所指的函数会调用传入的 block。


#### 2. 应用案例
- 查看闭源的或者苹果官方私有类的一些信息，比如一个类的所有方法
- 给分类添加属性
- 调试闭源的代码
- JSON 转 Model（Mantle、YYModel）
- 通过 Method Swizzling 重写闭源的代码
- 实现与其他语言的桥接，开源项目 JSPatch 和 React Native 就是很好的例子
- [给 Protocol 添加默认实现（Protocol Extension）](https://draveness.me/protocol-extension#reference)，具体实现可参考开源项目 ProtocolKit 和 libextobjc

### 十二、使用 Runtime 技术时的注意点
runtime 是一把双刃剑，应该谨慎使用：

- 尽可能避免使用 runtime 来解决问题，如果能使用其他办法解决最好就用其他办法解决掉
- 使用 runtime 时，一定要清楚地知道自己在干什么，以免出现一些难以追踪的 bug
- 不要用 runtime 去修改系统框架的私有方法，以免应用提交审核时被拒
- 如果对系统的方法使用了 Method Swizzling 技术，一定要记得调用原来的实现。

### 十三、相关开源项目
- Aspects
- JSPatch


### 参考

- runtime
  - [sunnyxx：重识 Objective-C Runtime - Smalltalk 与 C 的融合](http://blog.sunnyxx.com/2016/08/13/reunderstanding-runtime-0/)（推荐）
  - [sunnyxx：重识 Objective-C Runtime - 看透 Type 与 Value](http://blog.sunnyxx.com/2016/08/13/reunderstanding-runtime-1/)
  - [玉令天下：Objective-C Runtime](http://yulingtianxia.com/blog/2014/11/05/objective-c-runtime/)（推荐）
  - [喵神：深入Objective-C的动态特性](https://onevcat.com/2012/04/objective-c-runtime/)
  - [Understanding the Objective-C Runtime](http://cocoasamurai.blogspot.co.uk/2010/01/understanding-objective-c-runtime.html)（推荐）
  - [THE DOWN LOW ON OBJECTIVE-C RUNTIME](https://novemberfive.co/blog/objective-c-runtime/)
  - [Video Tutorial: Objective-C Runtime](https://www.raywenderlich.com/61318/video-tutorial-objective-c-runtime)
  - [Friday Q&A 2009-03-13: Intro to the Objective-C Runtime by Mike Ash](https://www.mikeash.com/pyblog/friday-qa-2009-03-13-intro-to-the-objective-c-runtime.html)
  - [从 ObjC Runtime 源码分析一个对象创建的过程](https://www.jianshu.com/p/8e4887a43bd7)（推荐）
  - [Objective-C Runtime（二）：动态类型，动态绑定，动态方法决议，内省](http://liuduo.me/2018/02/01/objective-c-runtime-2-dynamic-typing-and-dynamic-binding/)
  - [从源代码看 ObjC 中消息的发送](https://draveness.me/message) 
  - [深入解析 ObjC 中方法的结构](https://draveness.me/method-struct)
  - [从 NSObject 的初始化了解 isa](https://draveness.me/isa)
  - [深入理解Objective-C：方法缓存](https://tech.meituan.com/DiveIntoMethodCache.html)
- Method Swizzling
  - [Method Swizzling - NSHipster](http://nshipster.cn/method-swizzling/)（推荐）
  - [Method Swizzling 和 AOP 实践](http://tech.glowing.com/cn/method-swizzling-aop/)
  - [The Right Way to Swizzle in Objective-C](https://blog.newrelic.com/2014/04/16/right-way-to-swizzle/)
  - [Using dispatch_once in method swizzling](https://stackoverflow.com/questions/29435788/using-dispatch-once-in-method-swizzling)
- Associated Objects
  - [Associated Objects - NSHipster](http://nshipster.cn/associated-objects/)
  - [关联对象 AssociatedObject 完全解析](https://draveness.me/ao) 
  - [如何实现 iOS 中的 Associated Object](https://draveness.me/retain-cycle3)
- load 和 initialize
  - [NSObject +load and +initialize - What do they do?](https://stackoverflow.com/questions/13326435/nsobject-load-and-initialize-what-do-they-do?rq=1)
  - [Objective-C +load vs +initialize](http://blog.leichunfeng.com/blog/2015/05/02/objective-c-plus-load-vs-plus-initialize/)
  - [细说OC中的load和initialize方法](https://bestswifter.com/load-and-initialize/)
  - [你真的了解 load 方法么？](https://draveness.me/load)
  - [懒惰的 initialize 方法](https://draveness.me/initialize)
- Category
  - [结合 category 工作原理分析 OC2.0 中的 runtime](https://bestswifter.com/runtime-category/)
  - [深入理解Objective-C：Category](https://tech.meituan.com/DiveIntoCategory.html)

### 官方文档
- [Objective-C Runtime Programming Guide: Interacting with the Runtime](//link.zhihu.com/?target=https%3A//developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtInteracting.html)：这份文档主要介绍了 NSObject 类，以及 Objective-C 程序是如何跟 runtime 系统打交道的。另外，还介绍了运行时动态加载类和消息转发，以及当程序在运行时如何获取对象的信息。
- [Objective-C Runtime Reference](//link.zhihu.com/?target=https%3A//developer.apple.com/reference/objectivec/1657527-objective_c_runtime)
- [About Key-Value Coding](//link.zhihu.com/?target=https%3A//developer.apple.com/library/content/documentation/Cocoa/Conceptual/KeyValueCoding/)
- [Introduction to Key-Value Observing Programming Guide](//link.zhihu.com/?target=https%3A//developer.apple.com/library/content/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html)
- [Introspection - Concepts in Objective-C Programming](https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaEncyclopedia/Introspection/Introspection.html)

### 延伸阅读


- 应用与实践
  - [Runtime在实际开发中的应用](http://www.jianshu.com/p/851b21870d91)
  - [利用Runtime 实现自动化归档](http://www.jianshu.com/p/bd24c3f3cd0a)
  - [MLeaksFinder：精准 iOS 内存泄露检测工具](http://wereadteam.github.io/2016/02/22/MLeaksFinder/?from=singlemessage&isappinstalled=0)
  - [[iOS]利用runtime,解决多次点击相同button,导致重复跳转的问题](http://www.jianshu.com/p/65ce6471cd0f)
  - [iOS runtime实用篇--和常见崩溃say good-bye！](https://www.jianshu.com/p/5d625f86bd02)
  
- 理论
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
  