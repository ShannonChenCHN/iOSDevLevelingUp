关于 objc4 源码的一些说明：     

- objc4 的源码不能直接编译，需要配置相关环境才能运行。可以在[这里](https://github.com/RetVal/objc-runtime)下载可调式的源码。
- objc 运行时源码的入口在 `void _objc_init(void)` 函数。

### 方法在内存中的存储结构

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
    
### 关于选择器 selector
1. 向不同的类发送相同的消息时，其生成的选择子是完全相同的
2. 通过 @selector(方法名) 就可以返回一个选择子，通过 (void *)@selector(方法名)， 就可以读取选择器的地址
3. 推断 selector 的特性：
   - Objective-C 为我们维护了一个巨大的选择子表
   - 在使用 @selector() 时会从这个选择子表中根据选择子的名字查找对应的 SEL。如果没有找到，则会生成一个 SEL 并添加到表中
   - 在编译期间会扫描全部的头文件和实现文件将其中的方法以及使用 @selector() 生成的选择子加入到选择子表中
   
### 关于发消息 
> 具体过程查看源码中 `lookUpImpOrForward()` 函数部分的注释

1. 发送 hello 消息后，编译器会将上面这行 [obj hello]; 代码转成 objc_msgSend()（注：objc_msgSend 是一个私有方法，而且是用汇编实现的，我们没有办法进入它的实现，但是我们可以通过 lookUpImpOrForward 函数断点拦截）
2. 到当前类的缓存中去查找方法实现，如果找到了直接 done
3. 如果没找到，就到当前类的方法列表中去查找，如果找到了直接 done
4. 如果还没找到，就到父类的缓存中去查找方法实现，如果找到了直接 done
5. 如果没找到，就到父类的方法列表中去查找，如果找到了直接 done
6. 如果还没找到，就进行方法决议
7. 最后还没找到的话，就走消息转发


### 参考：
- [对象是如何初始化的（iOS）](https://draveness.me/object-init)：介绍了 Objective-C 对象初始化的过程
- [从 NSObject 的初始化了解 isa](https://draveness.me/isa)：深入剖析了 isa 的结构和作用
- [深入解析 ObjC 中方法的结构](https://draveness.me/method-struct)：介绍了在 ObjC 中是如何存储方法的
- [从源代码看 ObjC 中消息的发送](https://draveness.me/message) ：通过逐步断点调试 objc 源码的方式，从 Objc 源代码中分析并合理地推测一些关于消息传递的过程
- [从 ObjC Runtime 源码分析一个对象创建的过程](https://www.jianshu.com/p/8e4887a43bd7)
- [Runtime源码 —— 概述和调试环境准备](https://www.jianshu.com/u/43bb8b1a9d39)：作者写了一个系列的文章，内容很详细
- [Objective-C runtime - 系列开始](http://vanney9.com/2017/06/03/objective-c-runtime-summarize/)：简单介绍了学习 objc 源代码的方法