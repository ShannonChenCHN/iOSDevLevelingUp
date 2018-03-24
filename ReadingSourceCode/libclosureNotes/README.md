# libclosure-67


1. block 究竟是什么？
2. block 有几种类型？
3. 为什么不能在 block 中直接修改捕获到的变量？
4. 如何才能做到在 block 中修改捕获到的变量？为什么经过 `_block` 的变量就可以在 block 中被修改？
5. 什么情况下会在使用 block 时导致循环引用？如何解决？

### 1. block 究竟是什么？

在 Block_private.h 中，可以看到 block 的数据结构的定义：

```
// block 的数据结构
struct Block_layout {
    void *isa;          
    volatile int32_t flags; // contains ref count
    int32_t reserved; 
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 *descriptor;
    // imported variables
};

#define BLOCK_DESCRIPTOR_1 1
struct Block_descriptor_1 {
    uintptr_t reserved;
    uintptr_t size;
};
```

![](http://www.galloway.me.uk/media/images/2013-05-26-a-look-inside-blocks-episode-3-block-copy/block_layout.png)
<div align='center'>图 1 block 的数据结构定义</div>

在 Objective-C 中，根据对象的定义，凡是首地址是 *isa 的结构体指针，都可以认为是对象(id)。这样在 Objective-C 中，block 实际上就相当于是对象。

一个 block 实例实际上由 6 部分构成：

- isa 指针，所有对象都有该指针，用于实现对象相关的功能。
- flags，用于按 bit 位表示一些 block 的附加信息，本文后面介绍 block copy 的实现代码可以看到对该变量的使用。
- reserved，保留变量。
- invoke，函数指针，指向具体的 block 实现的函数调用地址。
- descriptor， 表示该 block 的附加描述信息，主要是 size 大小，以及 copy 和 dispose 函数的指针。
- imported variables，捕获到的变量，block 能够访问它外部的局部变量，就是因为将这些变量（或变量的地址）复制到了结构体中。

### 2. block 有几种类型？
block中的 isa 指向的是该block的Class。在 block runtime 中，也就是 data.c 文件中，定义了 6 种类型：

```
_NSConcreteStackBlock    // 栈上创建的block
_NSConcreteMallocBlock   // 堆上创建的block
_NSConcreteGlobalBlock   // 作为全局变量的block
_NSConcreteWeakBlockVariable
_NSConcreteAutoBlock
_NSConcreteFinalizingBlock
```

其中我们能接触到的主要是前3种，后三种用于 GC。

当 block 在函数中第一次被创建时，它是存在于该函数的栈帧上的，其Class是固定的_NSConcreteStackBlock。其捕获的变量是会赋值到结构体的成员上，所以当block初始化完成后，捕获到的变量不能更改。

当函数返回时，函数的栈帧被销毁，这个block的内存也会被清除。所以在函数结束后仍然需要这个block时，就必须用Block_copy()方法将它拷贝到堆上。这个方法的核心动作很简单：申请内存，将栈数据复制过去，将Class改一下，最后向捕获到的对象发送retain，增加block的引用计数。

runtime.c 中 _Block_copy 函数的实现：

```
void *_Block_copy(const void *arg) {
    struct Block_layout *aBlock;  // block 对象

    if (!arg) return NULL;
    
    // The following would be better done as a switch statement
    aBlock = (struct Block_layout *)arg;
    if (aBlock->flags & BLOCK_NEEDS_FREE) {
        // latches on high
        latching_incr_int(&aBlock->flags);
        return aBlock;
    }
    else if (aBlock->flags & BLOCK_IS_GLOBAL) {
        return aBlock;
    }
    else {
        // 如果是栈上的 block，就进行 copy
        
        // 1. 申请内存
        struct Block_layout *result = malloc(aBlock->descriptor->size);
        if (!result) return NULL;
        
        // 2. 将栈上的 block 数据复制给 result
        memmove(result, aBlock, aBlock->descriptor->size); // bitcopy first
        
        
        // reset refcount
        result->flags &= ~(BLOCK_REFCOUNT_MASK|BLOCK_DEALLOCATING);    // XXX not needed
        result->flags |= BLOCK_NEEDS_FREE | 2;  // logical refcount 1 增加block的引用计数
        _Block_call_copy_helper(result, aBlock);
        
        
        // Set isa last so memory analysis tools see a fully-initialized object.
        // 将 isa 指针改为指向堆 block 的类型
        result->isa = _NSConcreteMallocBlock;
        return result;
    }
}
```

在开启ARC后，block的内存会比较微妙。ARC会自动处理block的内存，不用手动copy/release。

```
int main(int argc, const char * argv[])
{
    @autoreleasepool {
        int i = 1024;
        void (^block1)(void) = ^{
            printf("%d\n", i);
        };
        block1();
        NSLog(@"%@", block1); // 打印结果：<__NSMallocBlock__: 0x10042c7b0>
    }
    return 0;
}
```
block 是对象，所以这个 block1 变量默认是有 __strong 修饰符的，即block1 对该 block 有 strong references。即 block1 在被赋值的那一刻，这个 block 会被 copy（从打印结果中也能看出来）。所以，在 ARC 开启的情况下，将只会有 NSConcreteGlobalBlock 和 NSConcreteMallocBlock 类型的 block。



### 3. 为什么不能在 block 中直接修改捕获到的变量？

```
int main () {
    
    int val1 = 256;
    int val2 = 10;
    const char *fmt = "val2 = %d\n";
    
    void (^myBlock)(void) = ^void(void) {
        printf(fmt, val2);
    };
    
    val2 = 2;
    fmt = "These values were changed. val2 = %d\n";
    
    myBlock();
    
    return 0;
}

```

通过 clang 将上面的代码改写成 C++ 的代码：

```
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

static struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};


// block 对应的结构体
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
    
    // block 中捕获的自动变量被声明成了成员变量
  const char *fmt;
  int val2;
    
    // 构造函数中也多了两个参数，用来传入捕获的自动变量
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, const char *_fmt, int _val2, int flags=0) : fmt(_fmt), val2(_val2) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};


static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  const char *fmt = __cself->fmt; // bound by copy，获取捕获到的自动变量（保存在成员变量中）
  int val2 = __cself->val2; // bound by copy，获取捕获到的自动变量（保存在成员变量中）

        printf(fmt, val2);
    }



int main () {

    int val1 = 256;  // block 中没用到，也就不会截获
    int val2 = 10;
    const char *fmt = "val2 = %d\n";

    // 捕获到的自动变量传入构造函数的参数
    void (*myBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, fmt, val2));

    val2 = 2;
    fmt = "These values were changed. val2 = %d\n";

    ((void (*)(__block_impl *))((__block_impl *)myBlock)->FuncPtr)((__block_impl *)myBlock);

    return 0;
}

```

> clang 分析出来的结构跟该数据结构和上面 Block_private.h 中定义的结构实际是一样的，不过仅是结构体的嵌套方式不一样。

从上面的代码中可以看到：
- isa 指向 _NSConcreteStackBlock，说明这是一个分配在栈上的实例。也就是说当 struct 第一次被创建时，它是存在于该函数的栈帧上的，其Class是固定的_NSConcreteStackBlock。
- main_block_impl_0 中增加了两个变量 val2 和 fmt，在 block 中引用的变量 val2 实际是在申明 block 时，被复制到 main_block_impl_0 结构体中的那个变量 val2。因为这样，我们就能理解，**在 block 内部修改变量 val2 的内容，不会影响外部的实际变量 val2**。
- main_block_impl_0 中由于增加了两个变量 val2 和 fmt，所以结构体的大小变大了，该结构体大小被写在了 main_block_desc_0 中。


### 4. 如何才能做到在 block 中修改捕获到的变量？为什么经过 `_block` 的变量就可以在 block 中被修改？

通过在变量前添加 `_block` 修饰符，以实现修改捕获到的变量：

```
int main() {
    
    __block int block_val = 8;
    
    void (^myBlock)(void) = ^void(void) {
        block_val = 9;
        printf("myBlock: block_val(8) = %d\n", block_val); // 输出结果为 9
    };
    
    
    myBlock();
    
    NSLog(@"%@", @(block_val)); // 输出 9
    
}
```


经过 clang 重写后得到的 C++ 代码：

```
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

/// 捕获的 __block 变量转为了结构体
struct __Block_byref_block_val_0 {
  void *__isa;
__Block_byref_block_val_0 *__forwarding; //  __forwarding ，存储 __block 结构体的地址
 int __flags;
 int __size;
 int block_val; // 捕获的参数值
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __Block_byref_block_val_0 *block_val; // by ref，存储 __block 结构体变量的成员变量
    
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_block_val_0 *_block_val, int flags=0) : block_val(_block_val->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};


static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_block_val_0 *block_val = __cself->block_val; // bound by ref

        (block_val->__forwarding->block_val) = 9;  // 通过 __forwarding 成员变量来获取捕获的 __block 变量
        printf("myBlock: block_val(8) = %d\n", (block_val->__forwarding->block_val));
    
}


static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
    _Block_object_assign((void*)&dst->block_val, (void*)src->block_val, 8/*BLOCK_FIELD_IS_BYREF*/);
}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {
    _Block_object_dispose((void*)src->block_val, 8/*BLOCK_FIELD_IS_BYREF*/);
}


static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
    
    // 我们需要负责 __Block_byref_block_val_0 结构体相关的内存管理，
    // 所以 main_block_desc_0 中增加了 copy 和 dispose 函数指针，对于在调用前后修改相应变量的引用计数。
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};



int main() {

    // __block 变量被转成了结构体变量，其中第二个参数是把 block_val 的地址传给了成员变量 __forwarding
    __attribute__((__blocks__(byref))) __Block_byref_block_val_0 block_val = {(void*)0,
                                                                              (__Block_byref_block_val_0 *)&block_val,
                                                                              0,
                                                                              sizeof(__Block_byref_block_val_0),
                                                                              8};
    // __block 的结构体变量的地址被传进了 block 结构体构造函数
    void (*myBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_block_val_0 *)&block_val, 570425344));

    ((void (*)(__block_impl *))((__block_impl *)myBlock)->FuncPtr)((__block_impl *)myBlock);

}
```

从代码中我们可以看到：

- 源码中增加一个名为 `__Block_byref_ block_val_0` 的结构体，用来保存我们要 capture 并且修改的变量 `block_val`。
- **`main_block_impl_0` 中引用的是 `Block_byref_ block_val_0` 的结构体指针，这样就可以达到修改外部变量的作用。**而且这个值可以不受栈帧生命周期的限制、在 block 被 copy 后，能够随着 block 复制到堆上。
- **`__Block_byref_ block_val_0` 结构体中带有 isa，说明它也是一个对象**。
- **我们需要负责 `Block_byref_ block_val_0` 结构体相关的内存管理，所以 `main_block_desc_0` 中增加了 `copy` 和 `dispose` 函数指针，对于在调用前后修改相应变量的引用计数。**

### 5. 什么情况下会在使用 block 时导致循环引用？如何解决？

当 block 被 copy 之后(如开启了 ARC、或把 block 放入 dispatch queue)，该 block 对它捕获的对象产生 strong references (非ARC下是retain)，
所以有时需要避免 block copy 后产生的循环引用。

如果用 self 引用了 block，block 又捕获了 self，这样就会有循环引用。
因此，需要用__weak来声明self。

```
- (void)configureBlock {
    XYZBlockKeeper * __weak weakSelf = self;
    self.block = ^{
        [weakSelf doSomething]; //捕获到的是弱引用
    }
}
```

### 6. 静态变量和全局变量


```
#include <stdio.h>

int global_val = 60;
static int static_global_val = 10;

int main() {
    
    int val = 10;
    static int static_val = 4;
    
    void (^myBlock)(void) = ^void(void) {
//        val = 20;
        static_val = 30;
        global_val = 6;
        static_global_val = 50;
        printf("myBlock:val(10) = %d,\n static_val(4) = %d,\n global_val(60) = %d,\n static_global_val(10) = %d\n", val, static_val, global_val, static_global_val);
    };
    
    myBlock();
    
}

```

通过 clang 翻译成 C++ 之后的代码：

```

struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};


int global_val = 60;
static int static_global_val = 10;


// blcok 的数据结构
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int *static_val;  // 捕获进来的 static 变量的地址
  int val;
    
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_static_val, int _val, int flags=0) : static_val(_static_val), val(_val) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};


// block 的实现对应的函数
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  int *static_val = __cself->static_val; // bound by copy，
  int val = __cself->val; // bound by copy

        // 通过访问静态局部变量的地址来改变变量值
        (*static_val) = 30;
    
        // 全局变量和静态变量可以直接访问
        global_val = 6;
        static_global_val = 50;
    
        // 自动变量无法访问，只能读取变量值
        printf("myBlock:val(10) = %d,\n static_val(4) = %d,\n global_val(60) = %d,\n static_global_val(10) = %d\n", val, (*static_val), global_val, static_global_val);
    }

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};


int main() {

    int val = 10;
    static int static_val = 4;
    
    // 这里把静态变量的地址传入了 __main_block_impl_0 结构体的构造函数并保存
    void (*myBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, &static_val, val));

    ((void (*)(__block_impl *))((__block_impl *)myBlock)->FuncPtr)((__block_impl *)myBlock);

}


```

结论：

- 通过访问静态局部变量的地址来改变变量值
- 全局变量和静态变量可以直接访问


### 7. block 对变量的捕获规则

（1） 静态存储区的变量：例如全局变量、方法中的static变量
捕获的是对变量的引用，可修改。

（2）block接受的参数
只是传值，不会引用，因为 block 只有截获外部变量时，才会引用它。可修改，和一般函数的参数相同。

（3）栈变量 (被捕获的上下文变量)
const，不可修改。 当block被copy后，block会对 id类型的变量产生强引用。
每次执行block时,捕获到的变量都是最初的值。

（4）栈变量 (有__block前缀)
引用，可以修改。如果时id类型则不会被block retain,必须手动处理其内存管理。
如果该类型是C类型变量，block被copy到heap后,该值也会被挪动到heap

### 7. Strong-Weak Dance

可以直接阅读 bs 的[这篇文章](https://bestswifter.com/strong-weak-dance/)。

#### 延伸阅读
- [objc 中的 block - ibireme 的博客](https://blog.ibireme.com/2013/11/27/objc-block/)
- [谈Objective-C block的实现 - 唐巧](https://blog.devtang.com/2013/07/28/a-look-inside-blocks/)
- [对 Strong-Weak Dance 的思考](https://bestswifter.com/strong-weak-dance/)
- [iOS 中的 block 是如何持有对象的](https://draveness.me/block-retain-object)
- 《Objective-C 高级编程》
- [Block技巧与底层解析](https://www.jianshu.com/p/51d04b7639f1#)
- [Block Implementation Specification - Clang 7 documentation](http://clang.llvm.org/docs/Block-ABI-Apple.html)
- Matt Galloway: A look inside blocks[(Episode 1)](http://www.galloway.me.uk/2012/10/a-look-inside-blocks-episode-1/)[(Episode 2)](http://www.galloway.me.uk/2012/10/a-look-inside-blocks-episode-2)[(Episode 3)](http://www.galloway.me.uk/2013/05/a-look-inside-blocks-episode-3-block-copy/)
- [深入理解Block之Block的类型](http://ios.jobbole.com/88191/)
- [霜神：深入研究Block用weakSelf、strongSelf、@weakify、@strongify解决循环引用](https://www.jianshu.com/p/701da54bd78c)
- [霜神：深入研究Block捕获外部变量和__block实现原理](https://www.jianshu.com/p/ee9756f3d5f6)
