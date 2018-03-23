/**
 * 通过 "clang -rewrite-objc main.m"命令将 main.m 转换后的代码
 * 
 * main.m 中的代码：
  int main() {
     
     void (^block)(void) = ^void(void) {
         printf("Block\n");
     };
     
     block();
     
     return 0;
  }

 *
 *
 */


/// 存储 block 关键信息的结构体
struct __block_impl {
  void *isa; // 像 Objective-C 对象一样，存储对象地址的指针变量
  int Flags;
  int Reserved;
  void *FuncPtr; // 存储 block 执行函数的指针变量
};

/// 存储 block 描述信息的结构体
static struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)}; // 静态全局变量

/// block 转成的结构体
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
    
    /// 构造函数
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;  // _NSConcreteStackBlock ？？？
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

/// block 的执行内容转成的静态函数
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

        printf("Block\n");
    }



int main() {

    void (*block)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
    // 1.左边实际上就是一个函数指针变量
    // 2.右边拆开来看：
    //      2.1 调用 __main_block_impl_0 结构体的构造函数，生成一个 __main_block_impl_0 结构体（第一个参数前为什么是(void *)，而不是 & 符号？）：
    //       struct __main_block_impl_0 blockImpl = __main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA);
    //      2.2 获取 __main_block_impl_0 结构体的指针：（这里有疑问？？？）
    //       struct __main_block_impl_0 *structPtr = &blockImpl;
    //      2.3 转换成一个函数指针，传给左边的函数指针变量：
    //      void (*block)(void) = structPtr;
    
    ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);
    // 1.首先取 block 变量： __block_impl *blockPtr = ((__block_impl *)block);
    // 2.然后取出 FuncPtr 指针：void *funcPtr = blockPtr->FuncPtr;
    // 3.再获取函数变量值：void blockFun() = (void (*)(__block_impl *))funcPtr; // 这里是模拟的，实际上不能直接这么转的
    // 4.最后调用函数，将函数指针变量（指向 block 值的指针）作为参数：blockFun((__block_impl *)block);

    return 0;
}

