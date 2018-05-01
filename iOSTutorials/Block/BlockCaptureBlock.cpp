
/*
NSString *string = @"This is a string!";
void (^myBlock)(void) = ^ {
    
    NSLog(@"myBlock: %@", string);
};

void(^anotherBlock)(BlockType aBlock) = ^(BlockType aBlock){
    NSLog(@"AnotherBlock");
    
    aBlock();
    myBlock();
    
};

anotherBlock(myBlock);

*/


typedef void(*BlockType)(void);

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  NSString *string;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, NSString *_string, int flags=0) : string(_string) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  NSString *string = __cself->string; // bound by copy


            NSLog((NSString *)&__NSConstantStringImpl__var_folders_yc_v6mdtm514xbb7b98_1t63yb00000gn_T_main_78850a_mi_1, string);
        }
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->string, (void*)src->string, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->string, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

struct __main_block_impl_1 {
  struct __block_impl impl;
  struct __main_block_desc_1* Desc;
  struct __block_impl *myBlock;  // 捕获进来的 myBlock，跟捕获一般的 ObjC 对象一样
  __main_block_impl_1(void *fp, struct __main_block_desc_1 *desc, void *_myBlock, int flags=0) : myBlock((struct __block_impl *)_myBlock) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_1(struct __main_block_impl_1 *__cself, BlockType aBlock) {
    // 先从第二个 block 的结构体中取出 myBlock 的引用
  void (*myBlock)() = (void (*)())__cself->myBlock; // bound by copy

            NSLog((NSString *)&__NSConstantStringImpl__var_folders_yc_v6mdtm514xbb7b98_1t63yb00000gn_T_main_78850a_mi_2);

            ((void (*)(__block_impl *))((__block_impl *)aBlock)->FuncPtr)((__block_impl *)aBlock);
            ((void (*)(__block_impl *))((__block_impl *)myBlock)->FuncPtr)((__block_impl *)myBlock); // 调用 myBlock 的函数来执行

        }
static void __main_block_copy_1(struct __main_block_impl_1*dst, struct __main_block_impl_1*src) {_Block_object_assign((void*)&dst->myBlock, (void*)src->myBlock, 7/*BLOCK_FIELD_IS_BLOCK*/);}

static void __main_block_dispose_1(struct __main_block_impl_1*src) {_Block_object_dispose((void*)src->myBlock, 7/*BLOCK_FIELD_IS_BLOCK*/);}

static struct __main_block_desc_1 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_1*, struct __main_block_impl_1*);
  void (*dispose)(struct __main_block_impl_1*);
} __main_block_desc_1_DATA = { 0, sizeof(struct __main_block_impl_1), __main_block_copy_1, __main_block_dispose_1};



int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool;


        NSString *string = (NSString *)&__NSConstantStringImpl__var_folders_yc_v6mdtm514xbb7b98_1t63yb00000gn_T_main_78850a_mi_0;
        void (*myBlock)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, string, 570425344));

        void(*anotherBlock)(BlockType aBlock) = ((void (*)(BlockType))&__main_block_impl_1((void *)__main_block_func_1, &__main_block_desc_1_DATA, (void *)myBlock, 570425344)); // 这里将捕获到的 myBlock 的引用传进 anotherBlock 的构造函数了

        ((void (*)(__block_impl *, BlockType))((__block_impl *)anotherBlock)->FuncPtr)((__block_impl *)anotherBlock, myBlock);
    }
    return 0;
}
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
