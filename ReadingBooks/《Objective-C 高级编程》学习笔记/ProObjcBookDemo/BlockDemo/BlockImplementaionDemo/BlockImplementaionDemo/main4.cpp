



struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

/// __block 变量结构体
struct __Block_byref_block_val_0 {
  void *__isa;
__Block_byref_block_val_0 *__forwarding; //  __forwarding ，存储 __block 结构体的地址
 int __flags;
 int __size;
 int block_val;
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

