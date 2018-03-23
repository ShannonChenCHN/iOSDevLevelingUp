
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};


int global_val = 60;
static int static_global_val = 10;


struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int *static_val;
  int val;
    
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_static_val, int _val, int flags=0) : static_val(_static_val), val(_val) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};


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

