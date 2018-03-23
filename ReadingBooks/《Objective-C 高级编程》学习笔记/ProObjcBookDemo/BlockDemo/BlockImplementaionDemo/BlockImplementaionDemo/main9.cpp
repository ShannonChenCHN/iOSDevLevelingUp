





struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};



struct __Block_byref_array_0 {
  void *__isa;
__Block_byref_array_0 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*);
 void (*__Block_byref_id_object_dispose)(void*);
 id array;
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __Block_byref_array_0 *array; // by ref
    
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_array_0 *_array, int flags=0) : array(_array->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself, id obj) {
  __Block_byref_array_0 *array = __cself->array; // bound by ref

            ((void (*)(id, SEL, ObjectType))(void *)objc_msgSend)((id)(array->__forwarding->array), sel_registerName("addObject:"), (id)obj);

            NSLog((NSString *)&__NSConstantStringImpl__var_folders_nt_bkkycgbs2hv63tthr5dbd2g40000gn_T_main8_cb5b3d_mi_0, ((NSUInteger (*)(id, SEL))(void *)objc_msgSend)((id)(array->__forwarding->array), sel_registerName("count")));
}


static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
    _Block_object_assign((void*)&dst->array, (void*)src->array, 8/*BLOCK_FIELD_IS_BYREF*/);
}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {
    _Block_object_dispose((void*)src->array, 8/*BLOCK_FIELD_IS_BYREF*/);
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};



int main() {

    typedef void(*blk_t) (id obj);

    blk_t blk;

    {
        __attribute__((__blocks__(byref))) __Block_byref_array_0 array = {(void*)0,(__Block_byref_array_0 *)&array, 33554432, sizeof(__Block_byref_array_0), __Block_byref_id_object_copy_131, __Block_byref_id_object_dispose_131, ((NSMutableArray *(*)(id, SEL))(void *)objc_msgSend)((id)((NSMutableArray *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSMutableArray"), sel_registerName("alloc")), sel_registerName("init"))};

        blk = ((void (*)(id))&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_array_0 *)&array, 570425344));
    }


    ((void (*)(__block_impl *, id))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk, ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("alloc")), sel_registerName("init")));
    ((void (*)(__block_impl *, id))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk, ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("alloc")), sel_registerName("init")));
    ((void (*)(__block_impl *, id))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk, ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("alloc")), sel_registerName("init")));



    return 0;
}

