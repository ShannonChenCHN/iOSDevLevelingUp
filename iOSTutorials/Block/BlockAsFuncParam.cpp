

/*
 

 typedef void(^BlockType)(void);
 
 int main(int argc, const char * argv[]) {
 
     NSString *string = @"This is a string!";
     void (^myBlock)(void) = ^ {
 
         NSLog(@"myBlock: %@", string);
     };
 
     void(^anotherBlock)(BlockType aBlock) = ^(BlockType aBlock){
         NSLog(@"AnotherBlock");
 
         aBlock();
     };
 
     anotherBlock(myBlock);
 
     return 0;
 }

 
 */

#ifndef BLOCK_IMPL
#define BLOCK_IMPL
struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};
#endif

// block 类型变成了 函数指针类型
typedef void(*BlockType)(void);

// 第一个 block 的结构
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  NSString *string; // 捕获进来的 string 对象
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, NSString *_string, int flags=0) : string(_string) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};


// 第一个 block 的实现
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  NSString *string = __cself->string; // bound by copy


            NSLog((NSString *)&__NSConstantStringImpl__var_folders_yc_v6mdtm514xbb7b98_1t63yb00000gn_T_main_17ff9d_mi_1, string);
        }



static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->string, (void*)src->string, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->string, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

// 第二个 block 的结构
struct __main_block_impl_1 {
  struct __block_impl impl;
  struct __main_block_desc_1* Desc;
  __main_block_impl_1(void *fp, struct __main_block_desc_1 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};


// 第二个 block 的实现
static void __main_block_func_1(struct __main_block_impl_1 *__cself, BlockType aBlock) {

            NSLog((NSString *)&__NSConstantStringImpl__var_folders_yc_v6mdtm514xbb7b98_1t63yb00000gn_T_main_17ff9d_mi_2);

    // 调用传进来的 aBlock 结构的函数指针所指向的函数，然后将 aBlock 自己作为参数传递进去
            ((void (*)(__block_impl *))((__block_impl *)aBlock)->FuncPtr)((__block_impl *)aBlock);
        }



static struct __main_block_desc_1 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_1_DATA = { 0, sizeof(struct __main_block_impl_1)};



int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        NSString *string = (NSString *)&__NSConstantStringImpl__var_folders_yc_v6mdtm514xbb7b98_1t63yb00000gn_T_main_17ff9d_mi_0;
        void (*myBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, string, 570425344)); // 第一个 block 捕获了 string

        void(*AnotherBlock)(BlockType aBlock) = ((void (*)(BlockType))&__main_block_impl_1((void *)__main_block_func_1, &__main_block_desc_1_DATA));

        ((void (*)(__block_impl *, BlockType))((__block_impl *)AnotherBlock)->FuncPtr)((__block_impl *)AnotherBlock, myBlock);  // 调用第二个 block 时，实际上是调用第二个 block 的 函数指针所指向的函数，然后把第一个 block 作为参数传递进去

    }
    return 0;
}


static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
