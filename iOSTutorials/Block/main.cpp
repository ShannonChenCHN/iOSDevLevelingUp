/*
#import <Foundation/Foundation.h>


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        static NSString *staticText = @"originalText";
        void (^myBlock)(void) = ^ {
            
            staticText = @"modified";
        };
        
    }
    return 0;
}

*/

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
    
  NSString **staticText; // 捕获到的静态变量的地址
    
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, NSString **_staticText, int flags=0) : staticText(_staticText) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    
    // 通过访问捕获到的静态变量的地址的方式来修改静态变量
  NSString **staticText = __cself->staticText; // bound by copy




            (*staticText) = (NSString *)&__NSConstantStringImpl__var_folders_nt_bkkycgbs2hv63tthr5dbd2g40000gn_T_main_93a859_mi_1;
        }
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->staticText, (void*)src->staticText, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->staticText, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};


int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 



        static NSString *staticText = (NSString *)&__NSConstantStringImpl__var_folders_nt_bkkycgbs2hv63tthr5dbd2g40000gn_T_main_93a859_mi_0;
        void (*myBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, &staticText, 570425344));


    }
    return 0;
}

