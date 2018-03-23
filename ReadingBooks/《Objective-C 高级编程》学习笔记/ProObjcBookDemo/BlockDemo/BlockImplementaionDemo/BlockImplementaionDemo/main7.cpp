
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};



typedef int (*returnedBlock)(int a);


struct __func_block_impl_0 {
  struct __block_impl impl;
  struct __func_block_desc_0* Desc;
  __func_block_impl_0(void *fp, struct __func_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static int __func_block_func_0(struct __func_block_impl_0 *__cself, int a) {

        return 5;
    }

static struct __func_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __func_block_desc_0_DATA = { 0, sizeof(struct __func_block_impl_0)};


returnedBlock func() {
    return ((int (*)(int))&__func_block_impl_0((void *)__func_block_func_0, &__func_block_desc_0_DATA));
}

