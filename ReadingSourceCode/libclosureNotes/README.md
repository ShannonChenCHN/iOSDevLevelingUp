# libclosure



1. block 的数据结构

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

在 Objective-C 中，根据对象的定义，凡是首地址是 *isa 的结构体指针，都可以认为是对象(id)。这样在 Objective-C 中，block 实际上就相当于是对象。



#### 延伸阅读
- [objc 中的 block - ibireme 的博客](https://blog.ibireme.com/2013/11/27/objc-block/)
- [对 Strong-Weak Dance 的思考](https://bestswifter.com/strong-weak-dance/)
- [iOS 中的 block 是如何持有对象的](https://draveness.me/block-retain-object)
- 《Objective-C 高级编程》