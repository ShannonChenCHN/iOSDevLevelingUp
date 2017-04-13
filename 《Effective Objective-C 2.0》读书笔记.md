《Effective Objective-C 2.0》读书笔记
----------
**学习目标**：这本书主要讲的都是 iOS 开发的基本功，主要讲了 Objective-C 语言特性，以及 iOS 开发中内存管理、block 和 GCD 的相关知识，最后还介绍了系统框架。总的来说，重读这本书的目的主要在于进一步巩固基础，相比一年多前读这本书的时候的感受，肯定会有更多的收获，好书常读常新。

**要求**：笔记中要有自己的思考和理解；能结合自己的实践经历去学习；想想如何实践书中的知识，并应用到工作中去；每读完一节要有小结和问题；读的过程中最好要有相应的代码。

------------
###目录
前言
一、熟悉 Objective-C         
二、对象、发送消息和运行时        
三、接口与 API 设计        
四、协议与分类        
五、内存管理        
六、block 与 GCD        
七、系统框架        


-----------
###前言
- Objective-C 是动态的，很多其他语言在编译时干的事情，到 Objective-C 中放到了运行时来处理。所以很多问题在测试时不会出现，到了生产环境才出现。要想避免这些问题，最好是在一开始就把代码写好。（感想：Swift 之父 Chris Lattner 曾经在 ATP 访谈中就提到过为什么不优化现有的 Objective-C，而去发明一门新语言 Swift，安全性就是主要原因之一。）
- 这本书中所谈论的关于 Objective-C 的东西，大多与 Objective-C 本身没有太多关系，而跟一些 Apple 的框架有关联，因为我们现在使用 modern Objective-C 来开发软件基本上也就是指开发 Mac OS X 和 iOS 软件。
- 作者建议不管你是否之前做过什么语言的开发或者从没写过代码，都应该花点时间学习一下怎么发挥这门语言的最大作用，这样才能写出高执行效率的、易维护的、不易出 bug 的代码。（感想：很多同学写代码从来就不怎么考虑最佳实践/优化的事，实现功能就算完了，但结果在出现问题或者维护更新时感到痛苦不堪。）
- 作者写这本书之前已经研究 Objective-C 很长时间了，尤其是一些底层的知识，比如 blocks 和 ARC 的原理。（感想：1.做最早吃螃蟹的人；2.要有深入研究、追根究底的兴趣；3.机会总是留给有准备的人。）
- 作者的营养来源————优质博客（Mike Ash, Matt Gallagher, NSHipster），Apple 官方文档


###一、熟悉 Objective-C


###二、对象、消息、运行时        
###三、接口与 API 设计        
###四、协议与分类        
###五、内存管理    
#####第 29 条 理解引用计数

- OS X 10.8 以前，Mac OS 上使用垃圾回收机制（garbage collector）来进行内存管理，但是在 OS X 10.8 以后就被废弃了。
- 引用计数的概念：每个 Objective-C 对象都有一个计数值，被持有时引用计数加1，被释放时引用计数减1，当引用变为 0 时，该对象就被销毁掉了。
- 在 `NSObject` 协议中声明了几个跟引用计数相关的方法：
	- `retain`        引用计数加1
	- `release`       引用计数减1
	- `autorelease`   等到后面自动释放池被清理时，引用计数减1
	- `retainCount`   查看引用计数（并不是特别有用，Apple 官方不推荐使用）
- 通过对象图（Object Graph）来描述对象之间的引用关系，每一个对象图都会有一个根对象，比如，在 OS X 上，根对象是 NSApplication，在 iOS 上根对象是 UIApplication。
- 疑问：在调用 alloc、init 方法创建一个对象之后，这个对象的引用计数不一定就是 1，有可能比 1 要大，因为在 `alloc` 或者 `initWithInt:` 方法的实现中，有可能有其他对象也引用了该对象。
- 为了避免在对象被销毁后，因访问垂悬指针（dangling pointer）而导致的异常，我们一般需要在不再需要指向对象的引用后，将其置为 nil（清空指针），这就能保证不会出现可能指向无效对象的指针（也就是垂悬指针）。

```
        NSObject *obj = [[NSObject alloc] init]; // 创建并持有对象 A
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:obj];  // 数组 array 也持有对象 A    
        [obj release]; // 发送 release 消息，obj 指针不再持有对象 A
        obj = nil;  // 将不再需要的 obj 指针置为 nil，防止出现访问垂悬指针导致异常的问题
        
        NSLog(@"==== %@, %@", obj, array);
        
        [array release];
        

```

- 属性(property)中的内存管理：
	- 非ARC 中如何重写 setter 方法（可参考：http://stackoverflow.com/a/12370073/7088321）
	- setter 方法中 retain 和 release 方法的调用顺序（疑问：无法重现书中所说的错误——当旧值和新值指向同一对象时，如果先 release 旧值，再 retain 新值，会导致垂悬指针）

```
- (void)setFoo:(id)foo {
    [foo retain];
    [_foo release];
    _foo = foo;
}
```

- Autorelease Pools
	- 什么是 Autorelease Pool：自动释放池是为了延长一些对象的寿命，使其在失去持有者时仍然可以存活。
	- 什么时候用到 autorelease 方法：比如，在方法中创建一个新对象并返回值的时候，编译器会帮我们在返回前加上 autorelease。
    - 什么时候用到 Autorelease Pool：系统（Application Kit）会在程序每一个 event loop 循环的开始在主线程上创建一个 autorelease pool，然后在结束时清理掉 pool，所以我们一般不需要自己创建 pool。但是，如果你的应用中需要创建很多临时的 autoreleased 对象，这个时候，我们可以通过创建局部的 autorelease pool 来减低内存峰值，
	- 为什么要用 autorelease 方法：为了在某些场景下延长对象的生命期，使其在被持有的变量超出变量作用域时还能存活。
	- 被 autorelease 的对象什么时候会被释放：加入了该对象的自动释放池被清理时，就会给该对象发送 release 消息，从而被释放。一个对象可能会被加入到同一个池中很多次，在释放池被清理时，该对象会收到相对应次数的 release 消息。（具体什么时候清空释放池呢？）
- 循环引用
	- 什么是循环引用：多个对象成环形相互引用，导致引用计数都不能降为0，这就是循环引用，这会引起内存泄漏。
	- 垃圾回收环境（garbage-collected environment）是怎么处理“循环引用”的：在垃圾回收环境中，循环引用会被当成“孤岛”来处理，垃圾回收器会将环中的对象都销毁掉。
	- 引用计数环境下怎么避免“循环引用”：① 使用“弱引用”，② 通过外界影响使得其中一个对象不再持有另一个对象。

#####第 30 条 以 ARC 简化引用计数

#####第 31 条 在 `dealloc` 方法中只释放引用和解除监听

#####第 32 条 编写异常处理代码时需要留意内存管理问题

#####第 33 条 使用弱引用避免循环引用

#####第 34 条 使用 autorelease pool 块来减低内存峰值

#####第 35 条 使用“僵尸对象”（zombies）来调试内存管理问题

#####第 36 条 避免使用 `retainCount` 方法

    
###六、block 与 GCD   
#####第 37 条 理解 blocks 概念
#####第 38 条 为常用的 block 类型创建 typedef
#####第 39 条 使用 handler blocks 减低代码的分散程度
#####第 40 条 避免因为 block 引用其所属对象而导致的循环引用
#####第 41 条 多线程同步时推荐使用 Dispatch Queue 代替 Locks
#####第 42 条 推荐使用 GCD 代替 `performSelector` 系列方法
#####第 43 条 了解选择使用 GCD 和 Operation Queue 的场景
#####第 44 条 Dispatch Group 的使用
#####第 45 条 使用 `dispatch_once` 来实现线程安全的、只需执行一次的代码
#####第 46 条 避免使用 `dispatch_get_current_queue`

     
###七、系统框架

----------
[随书实例代码](https://github.com/effectiveobjc/code)
