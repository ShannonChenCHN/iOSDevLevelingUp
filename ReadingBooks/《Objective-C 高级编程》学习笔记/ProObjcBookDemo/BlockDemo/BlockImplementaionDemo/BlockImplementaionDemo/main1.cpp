/**
 * 通过 "clang -rewrite-objc main1.c"命令将 main1.c 转换后的代码
 *
 * main1.c 中的代码：
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
 
 *
 *
 */





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
    
    // 构造函数中也多了两个参数，用来传入捕获的自动变量（函数后面部分的 “ : fmt(_fmt), val2(_val2）” 是什么意思？）
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

