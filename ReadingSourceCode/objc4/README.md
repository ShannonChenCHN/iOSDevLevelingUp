关于 objc4 源码的一些说明：     

- objc4 的源码不能直接编译，需要配置相关环境才能运行。可以在[这里](https://github.com/RetVal/objc-runtime)下载可调式的源码。
- objc 运行时源码的入口在 `void _objc_init(void)` 函数。


### 1. Objective-C 对象是什么？Class 是什么？id 又是什么？

所有的类都继承 NSObject 或者 NSProxy，先来看看这两个类在各自的公开头文件中的定义：

```
@interface NSObject <NSObject> {
    Class isa  OBJC_ISA_AVAILABILITY;
}
```

```
@interface NSProxy <NSObject> {
    Class	isa;
}
```

在 objc.h 文件中，对于 Class，id 以及 objc_object 的定义：

```
/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;

/// Represents an instance of a class.
struct objc_object {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
};

/// A pointer to an instance of a class.
typedef struct objc_object *id;

```

runtime.h 文件中对 objc_class 的定义：

```
struct objc_class {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class _Nullable super_class                              OBJC2_UNAVAILABLE;
    const char * _Nonnull name                               OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
    struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
    struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;
```

在 Objective-C 中，每一个对象是一个结构体，每个对象都有一个 isa 指针，类对象 Class 也是一个对象。所以，我们说，凡是包含 isa 指针的，都可以被认为是 Objective-C 中的对象。运行时可以通过 isa 指针，查找到该对象是属于什么类(Class)。



### 2. isa 是什么？为什么要有 isa？

![](http://7ni3rk.com1.z0.glb.clouddn.com/Runtime/class-diagram.jpg)


- [Non-pointer isa](http://www.sealiesoftware.com/blog/archive/2013/09/24/objc_explain_Non-pointer_isa.html)

### 为什么在 Objective-C 中，所以的对象都用一个指针来追踪？

内存中的数据类型分为两种：值类型和引用类型。指针就是引用类型，struct 类型就是值类型。


值类型在传值时需要拷贝内容本身，而引用类型在传递时，拷贝的是对象的地址。所以，一方面，值类型的传递占用更多的内存空间，使用引用类型更节省内存开销；另一方面，也是最主要的原因，很多时候，我们需要把一个对象交给另一个函数或者方法去修改其中的内容（比如说一个 Person 对象的 age 属性），显然如果我们想让修改方获取到这个对象，我们需要的传递的是地址，而不是复制一份。

对于像 `int` 这样的基本数据类型，拷贝起来更快，而且数据简单，方便修改，所以就不用指针了。

参考：

- [Understanding pointers?](https://stackoverflow.com/questions/9746683/understanding-pointers)
- [need of pointer objects in objective c](https://stackoverflow.com/questions/17992127/need-of-pointer-objects-in-objective-c)
- [Why "Everything" in Objective C is pointers. I mean why I should declare NSArray instance variables in pointers.](https://teamtreehouse.com/community/why-everything-in-objective-c-is-pointers-i-mean-why-i-should-declare-nsarray-instance-variables-in-pointers)
- [Why do all objects in Objective-C have to use pointers?](https://www.quora.com/Why-do-all-objects-in-Objective-C-have-to-use-pointers#)

### 3. Objective-C 对象是如何初始化的？


### 4. Objective-C 对象的实例变量是什么？为什么不能给 Objective-C 对象动态添加实例变量？



> extension在**编译期决议**，它就是类的一部分，在编译期和头文件里的@interface以及实现文件里的@implement一起形成一个完整的类，它伴随类的产生而产生，亦随之一起消亡。extension一般用来隐藏类的私有信息，你必须有一个类的源码才能为一个类添加extension，所以你无法为系统的类比如NSString添加extension。
>
> 但是category则完全不一样，它是在**运行期决议的**。
就category和extension的区别来看，我们可以推导出一个明显的事实，extension可以添加实例变量，而category是无法添加实例变量的（**因为在运行期，对象的内存布局已经确定，如果添加实例变量就会破坏类的内部布局，这对编译型语言来说是灾难性的**）。

参考：

- [Objective-C类成员变量深度剖析](http://quotation.github.io/objc/2015/05/21/objc-runtime-ivar-access.html)
- [深入理解Objective-C：Category](https://tech.meituan.com/DiveIntoCategory.html)
- [Non-fragile ivars ](http://www.sealiesoftware.com/blog/archive/2009/01/27/objc_explain_Non-fragile_ivars.html)

### 5. Objective-C 对象的属性是什么？属性跟实例变量的区别？


### 6. Objective-C 对象的方法是什么？Objective-C 对象的方法在内存中的存储结构是什么样的？

objc_class 有一个 class_data_bits_t 类型的变量 bits，Objective-C 类中的属性、方法还有遵循的协议等信息都保存在 class_rw_t 中，通过调用 objc_class 的 class_rw_t *data() 方法，可以获取这个 class_rw_t 类型的变量。



```
// Objective-C 类是一个结构体，继承于 objc_object
struct objc_class : objc_object {
    // 这里没写 isa，其实继承了 objc_object 的 isa , 在这里 isa 是一个指向元类的指针
    // Class ISA;
    Class superclass;           // 指向当前类的父类
    cache_t cache;              // formerly cache pointer and vtable
                                // 用于缓存指针和 vtable，加速方法的调用
    class_data_bits_t bits;     // class_rw_t * plus custom rr/alloc flags
                                // 相当于 class_rw_t 指针加上 rr/alloc 的标志
                                // bits 用于存储类的方法、属性、遵循的协议等信息的地方
                                

    // 针对 class_data_bits_t 的 data() 函数的封装，最终返回一个 class_rw_t 类型的结构体变量
    // Objective-C 类中的属性、方法还有遵循的协议等信息都保存在 class_rw_t 中
    class_rw_t *data() { 
        return bits.data();
    }

	 ...
}
```

class_rw_t 中还有一个指向常量的指针 ro，其中存储了当前类在编译期就已经确定的属性、方法以及遵循的协议。

```
/ Objective-C 类中的属性、方法还有遵循的协议等信息都保存在 class_rw_t 中
struct class_rw_t {
    // Be warned that Symbolication knows the layout of this structure.
    uint32_t flags;
    uint32_t version;

    const class_ro_t *ro;               // 一个指向常量的指针，其中存储了当前类在编译期就已经确定的属性、方法以及遵循的协议

    method_array_t methods;             // 方法列表
    property_array_t properties;        // 属性列表
    protocol_array_t protocols;         // 所遵循的协议的列表

	...

}
```

```
// 用于存储一个 Objective-C 类在编译期就已经确定的属性、方法以及遵循的协议
struct class_ro_t {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
#ifdef __LP64__
    uint32_t reserved;
#endif

    const uint8_t * ivarLayout;
    
    const char * name;
    method_list_t * baseMethodList;   // （编译时确定的）方法列表
    protocol_list_t * baseProtocols;  // （编译时确定的）所属协议列表
    const ivar_list_t * ivars;        // （编译时确定的）实例变量列表

    const uint8_t * weakIvarLayout;
    property_list_t *baseProperties;  // （编译时确定的）属性列表

    method_list_t *baseMethods() const {
        return baseMethodList;
    }
};

```

加载 ObjC 运行时的过程中在 `realizeClass()` 方法中：

1. 从 class_data_bits_t 调用 data 方法，将结果强制转换为 class_ro_t 指针；
2. 初始化一个 class_rw_t 结构体；
3. 设置结构体 ro 的值以及 flag。
4. 最后重新将这个 class_rw_t 设置给 class_data_bits_t 的 data。

```
...
const class_ro_t *ro = (const class_ro_t *)cls->data();
class_rw_t *rw = (class_rw_t *)calloc(sizeof(class_rw_t), 1);
rw->ro = ro;
rw->flags = RW_REALIZED|RW_REALIZING;
cls->setData(rw);
...
```

在上面这段代码运行之后 `class_rw_t` 中的方法，属性以及协议列表均为空。这时需要 `realizeClass` 调用 `methodizeClass` 方法来将类自己实现的方法（包括分类）、属性和遵循的协议加载到 methods、 properties 和 protocols 列表中。

方法的结构，与类和对象一样，方法在内存中也是一个结构体。

```
struct method_t {
    SEL name;
    const char *types;
    IMP imp;
};
```

结论：

1. 在 runtime 初始化之后，realizeClass 之前，从 class_data_bits_t 结构体中获取的 class_rw_t 一直都不是 class_rw_t 结构体，而是class_ro_t。因为类的一些方法、属性和协议都是在编译期决定的（baseMethods 等成员以及类在内存中的位置都是编译期决定的）。

2. 类在内存中的位置是在编译期间决定的，在之后修改代码，也不会改变内存中的位置。
类的方法、属性以及协议在编译期间存放到了“错误”的位置，直到 realizeClass 执行之后，才放到了 class_rw_t 指向的只读区域 class_ro_t，这样我们即可以在运行时为 class_rw_t 添加方法，也不会影响类的只读结构。

3. 在 class_ro_t 中的属性在运行期间就不能改变了，再添加方法时，会修改 class_rw_t 中的 methods 列表，而不是 class_ro_t 中的 baseMethods。
    
### 7. 什么是选择器 selector ？什么是 IMP？
1. 向不同的类发送相同的消息时，其生成的选择子是完全相同的
2. 通过 @selector(方法名) 就可以返回一个选择子，通过 (void *)@selector(方法名)， 就可以读取选择器的地址
3. 推断 selector 的特性：
   - Objective-C 为我们维护了一个巨大的选择子表
   - 在使用 @selector() 时会从这个选择子表中根据选择子的名字查找对应的 SEL。如果没有找到，则会生成一个 SEL 并添加到表中
   - 在编译期间会扫描全部的头文件和实现文件将其中的方法以及使用 @selector() 生成的选择子加入到选择子表中
   
### 8. 关于消息发送和消息转发
> 具体过程查看源码中 `lookUpImpOrForward()` 函数部分的注释

1. 发送 hello 消息后，编译器会将上面这行 [obj hello]; 代码转成 objc_msgSend()（注：objc_msgSend 是一个私有方法，而且是用汇编实现的，我们没有办法进入它的实现，但是我们可以通过 lookUpImpOrForward 函数断点拦截）
2. 到当前类的缓存中去查找方法实现，如果找到了直接 done
3. 如果没找到，就到当前类的方法列表中去查找，如果找到了直接 done
4. 如果还没找到，就到父类的缓存中去查找方法实现，如果找到了直接 done
5. 如果没找到，就到父类的方法列表中去查找，如果找到了直接 done
6. 如果还没找到，就进行方法决议
7. 最后还没找到的话，就走消息转发

### 9. Method Swizzling 的原理是什么？

### 10. Objective-C 中的 Category 是什么？

### 11.  Associated Objects 的原理是什么？到底能不能给 Objective-C 类添加属性和实例变量？

### 12. Objective-C 中的 Protocol 是什么？


### 13. self 和 super 的本质

- [Objc Runtime](http://iostangtang.com/2017/05/20/Runtime/)


### 延伸

1. clang 命令的使用（比如 `clang -rewrite-objc test.m`），`clang -rewrite-objc` 的作用是什么？clang rewrite 出来的文件跟 objc runtime 源码的实现有什么区别吗？


### 参考：

  - [Objective-C 中的类和对象](https://blog.ibireme.com/2013/11/25/objc-object/)
  - Draveness 出品的 runtime 源码阅读系列文章（强烈推荐）
     - [对象是如何初始化的（iOS）](https://draveness.me/object-init)：介绍了 Objective-C 对象初始化的过程
     - [从 NSObject 的初始化了解 isa](https://draveness.me/isa)：深入剖析了 isa 的结构和作用
     - [深入解析 ObjC 中方法的结构](https://draveness.me/method-struct)：介绍了在 ObjC 中是如何存储方法的
     - [从源代码看 ObjC 中消息的发送](https://draveness.me/message) ：通过逐步断点调试 objc 源码的方式，从 Objc 源代码中分析并合理地推测一些关于消息传递的过程
  - [从 ObjC Runtime 源码分析一个对象创建的过程](https://www.jianshu.com/p/8e4887a43bd7)
  - [Objective-C 对象模型](http://blog.leichunfeng.com/blog/2015/04/25/objective-c-object-model/)
  - [Objc 对象的今生今世](https://www.jianshu.com/p/f725d2828a2f)
  - [Runtime源码 —— 概述和调试环境准备](https://www.jianshu.com/u/43bb8b1a9d39)：作者写了一个系列的文章，内容很详细
  - [Objective-C runtime - 系列开始](http://vanney9.com/2017/06/03/objective-c-runtime-summarize/)：简单介绍了学习 objc 源代码的方法
