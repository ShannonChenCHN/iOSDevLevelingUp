
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};



struct __Block_byref_block_val_0 {
  void *__isa;
__Block_byref_block_val_0 *__forwarding;
 int __flags;
 int __size;
 int block_val;
};

//________________________________ 第 0 个 block  ________________________________________

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __Block_byref_block_val_0 *block_val; // by ref
    
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_block_val_0 *_block_val, int flags=0) : block_val(_block_val->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_block_val_0 *block_val = __cself->block_val; // bound by ref

        (block_val->__forwarding->block_val) = 9;
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
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

//________________________________ 第 1 个 block  ________________________________________


struct __main_block_impl_1 {
  struct __block_impl impl;
  struct __main_block_desc_1* Desc;
  __Block_byref_block_val_0 *block_val; // by ref
    
  __main_block_impl_1(void *fp, struct __main_block_desc_1 *desc, __Block_byref_block_val_0 *_block_val, int flags=0) : block_val(_block_val->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_1(struct __main_block_impl_1 *__cself) {
  __Block_byref_block_val_0 *block_val = __cself->block_val; // bound by ref

        (block_val->__forwarding->block_val) = 10;
}


static void __main_block_copy_1(struct __main_block_impl_1*dst, struct __main_block_impl_1*src) {
    _Block_object_assign((void*)&dst->block_val, (void*)src->block_val, 8/*BLOCK_FIELD_IS_BYREF*/);
}

static void __main_block_dispose_1(struct __main_block_impl_1*src) {
    _Block_object_dispose((void*)src->block_val, 8/*BLOCK_FIELD_IS_BYREF*/);
}

static struct __main_block_desc_1 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_1*, struct __main_block_impl_1*);
  void (*dispose)(struct __main_block_impl_1*);
} __main_block_desc_1_DATA = { 0, sizeof(struct __main_block_impl_1), __main_block_copy_1, __main_block_dispose_1};

//________________________________ main 函数 ________________________________________

int main() {

    __attribute__((__blocks__(byref))) __Block_byref_block_val_0 block_val = {(void*)0,
                                                                            (__Block_byref_block_val_0 *)&block_val,
                                                                            0,
                                                                            sizeof(__Block_byref_block_val_0),
                                                                            8};

    // 两个 block 中都捕获了同一个 __block 变量，传入构造函数的是 __Block_byref_block_val_0 结构体指针
    void (*myBlock0)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_block_val_0 *)&block_val, 570425344));

    void (*myBlock1)(void) = ((void (*)())&__main_block_impl_1((void *)__main_block_func_1, &__main_block_desc_1_DATA, (__Block_byref_block_val_0 *)&block_val, 570425344));

    ((void (*)(__block_impl *))((__block_impl *)myBlock0)->FuncPtr)((__block_impl *)myBlock0);
    ((void (*)(__block_impl *))((__block_impl *)myBlock1)->FuncPtr)((__block_impl *)myBlock1);

}

