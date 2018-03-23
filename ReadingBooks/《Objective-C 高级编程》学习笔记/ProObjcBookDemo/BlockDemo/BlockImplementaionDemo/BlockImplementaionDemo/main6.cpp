
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

//_______________________________ 作为全局变量的 block _______________________________________________

struct __globalBlcok_block_impl_0 {
  struct __block_impl impl;
  struct __globalBlcok_block_desc_0* Desc;
    
  __globalBlcok_block_impl_0(void *fp, struct __globalBlcok_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteGlobalBlock; //  全局变量的 block 属于_NSConcreteGlobalBlock 类
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};


static void __globalBlcok_block_func_0(struct __globalBlcok_block_impl_0 *__cself) {


}

static struct __globalBlcok_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __globalBlcok_block_desc_0_DATA = { 0, sizeof(struct __globalBlcok_block_impl_0)};

static __globalBlcok_block_impl_0 __global_globalBlcok_block_impl_0((void *)__globalBlcok_block_func_0, &__globalBlcok_block_desc_0_DATA);

// 全局变量 block 的转换
void(*globalBlcok)() = ((void (*)())&__global_globalBlcok_block_impl_0);

//_______________________________ 作为局部变量的 block ，但是不捕获自动变量_______________________________________________

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


static int __main_block_func_0(struct __main_block_impl_0 *__cself, int a) {

        return a;
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};


int main() {

    int (*stackBlock)(int) = ((int (*)(int))&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));

    ((int (*)(__block_impl *, int))((__block_impl *)stackBlock)->FuncPtr)((__block_impl *)stackBlock, 1);

    return 0;
}
