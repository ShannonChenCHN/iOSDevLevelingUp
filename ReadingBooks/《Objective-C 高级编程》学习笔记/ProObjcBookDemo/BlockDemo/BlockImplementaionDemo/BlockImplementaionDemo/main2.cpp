
/**
 * 通过 "clang -rewrite-objc main2.c"命令将 main2.c 转换后的代码
 *
 * main2.c 中的代码：
 int main() {
 
     // 不截获自动变量的 block
     void (^block1)(void) = ^void(void) {
         printf("Block\n");
     };
     
     block1();
     
     // 截获 c 语言数组
     const char *text = "hello";
     void (^blockToCaptureCArray)(void) = ^void(void) {
         printf("The third letter is %c\n", text[2]);
     };
     
     blockToCaptureCArray();
     
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


//____________________________ 第 0 个 block ________________________________________


struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

        printf("Block\n");
    }

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};


//____________________________ 第 1 个 block ________________________________________

struct __main_block_impl_1 {
  struct __block_impl impl;
  struct __main_block_desc_1* Desc;
    
    // 捕获的变量是 const char * 类型
  const char *text;
    
  __main_block_impl_1(void *fp, struct __main_block_desc_1 *desc, const char *_text, int flags=0) : text(_text) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_1(struct __main_block_impl_1 *__cself) {
  const char *text = __cself->text; // bound by copy

        printf("The third letter is %c\n", text[2]);
    }

static struct __main_block_desc_1 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_1_DATA = { 0, sizeof(struct __main_block_impl_1)};


//____________________________ main函数 ________________________________________

int main() {

    void (*block1)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));

    ((void (*)(__block_impl *))((__block_impl *)block1)->FuncPtr)((__block_impl *)block1);


    const char *text = "hello";
    void (*blockToCaptureCArray)(void) = ((void (*)())&__main_block_impl_1((void *)__main_block_func_1, &__main_block_desc_1_DATA, text));

    ((void (*)(__block_impl *))((__block_impl *)blockToCaptureCArray)->FuncPtr)((__block_impl *)blockToCaptureCArray);

    return 0;
}

