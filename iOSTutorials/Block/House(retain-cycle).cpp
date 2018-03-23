

#ifndef BLOCK_IMPL
#define BLOCK_IMPL
struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};

#ifndef _REWRITER_typedef_House
#define _REWRITER_typedef_House
typedef struct objc_object House;
typedef struct {} _objc_exc_House;
#endif

extern "C" unsigned long OBJC_IVAR_$_House$_person;
struct House_IMPL {
	struct NSObject_IMPL NSObject_IVARS;
	Person *_person;
};


/* @end */


#ifndef _REWRITER_typedef_Person
#define _REWRITER_typedef_Person
typedef struct objc_object Person;
typedef struct {} _objc_exc_Person;
#endif

struct Person_IMPL {
	struct NSObject_IMPL NSObject_IVARS;
};


// @property (nonatomic, copy) NSString *name;

// - (void)setCallback:(void (^)(Person *))callback;

/* @end */


// @interface House ()

// @property (nonatomic, strong) Person *person;

/* @end */


// @implementation House


// block 数据结构的定义
struct __House__init_block_impl_0 {
  struct __block_impl impl;
  struct __House__init_block_desc_0* Desc;
  House *self; // 捕获的外部变量
    
    // 构造函数
    // 第一个参数是指向 block 实现函数的函数指针，第二个参数是指向 desc 结构体的指针
  __House__init_block_impl_0(void *fp, struct __House__init_block_desc_0 *desc, House *_self, int flags=0) : self(_self) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

// block 中的实现所对应的函数
static void __House__init_block_func_0(struct __House__init_block_impl_0 *__cself, Person *person) {
  House *self = __cself->self; // bound by copy


            ((void (*)(id, SEL, NSString *))(void *)objc_msgSend)((id)((Person *(*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("person")), sel_registerName("setName:"), (NSString *)&__NSConstantStringImpl__var_folders_yc_v6mdtm514xbb7b98_1t63yb00000gn_T_House_1d46d7_mi_0);
        }
static void __House__init_block_copy_0(struct __House__init_block_impl_0*dst, struct __House__init_block_impl_0*src) {_Block_object_assign((void*)&dst->self, (void*)src->self, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static void __House__init_block_dispose_0(struct __House__init_block_impl_0*src) {_Block_object_dispose((void*)src->self, 3/*BLOCK_FIELD_IS_OBJECT*/);}

static struct __House__init_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __House__init_block_impl_0*, struct __House__init_block_impl_0*);
  void (*dispose)(struct __House__init_block_impl_0*);
} __House__init_block_desc_0_DATA = { 0, sizeof(struct __House__init_block_impl_0), __House__init_block_copy_0, __House__init_block_dispose_0};

static instancetype _I_House_init(House * self, SEL _cmd) {
    self = ((House *(*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("House"))}, sel_registerName("init"));
    if (self) {


        (*(Person **)((char *)self + OBJC_IVAR_$_House$_person)) = ((Person *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("Person"), sel_registerName("new"));
        ((void (*)(id, SEL, void (*)(Person *)))(void *)objc_msgSend)((id)(*(Person **)((char *)self + OBJC_IVAR_$_House$_person)), sel_registerName("setCallback:"), ((void (*)(Person *))&__House__init_block_impl_0((void *)__House__init_block_func_0, &__House__init_block_desc_0_DATA, self, 570425344)));
        
        // 简化模型
        // objc_msgSend(_person, sel_registerName("setCallback:"), (void (*)(Person *))&__House__init_block_impl_0());
        //  其中的参数 block(结构体指针)的构造函数中的参数实际上是这样的 __House__init_block_impl_0((void *)__House__init_block_func_0, &__House__init_block_desc_0_DATA, self, 570425344)
        // 其中第一个参数是指向 block 实现函数的指针，第三个参数是捕获的 self

    }
    return self;
}


static Person * _I_House_person(House * self, SEL _cmd) { return (*(Person **)((char *)self + OBJC_IVAR_$_House$_person)); }
static void _I_House_setPerson_(House * self, SEL _cmd, Person *person) { (*(Person **)((char *)self + OBJC_IVAR_$_House$_person)) = person; }
// @end

struct _prop_t {
	const char *name;
	const char *attributes;
};

struct _protocol_t;

struct _objc_method {
	struct objc_selector * _cmd;
	const char *method_type;
	void  *_imp;
};

struct _protocol_t {
	void * isa;  // NULL
	const char *protocol_name;
	const struct _protocol_list_t * protocol_list; // super protocols
	const struct method_list_t *instance_methods;
	const struct method_list_t *class_methods;
	const struct method_list_t *optionalInstanceMethods;
	const struct method_list_t *optionalClassMethods;
	const struct _prop_list_t * properties;
	const unsigned int size;  // sizeof(struct _protocol_t)
	const unsigned int flags;  // = 0
	const char ** extendedMethodTypes;
};

struct _ivar_t {
	unsigned long int *offset;  // pointer to ivar offset location
	const char *name;
	const char *type;
	unsigned int alignment;
	unsigned int  size;
};

struct _class_ro_t {
	unsigned int flags;
	unsigned int instanceStart;
	unsigned int instanceSize;
	unsigned int reserved;
	const unsigned char *ivarLayout;
	const char *name;
	const struct _method_list_t *baseMethods;
	const struct _objc_protocol_list *baseProtocols;
	const struct _ivar_list_t *ivars;
	const unsigned char *weakIvarLayout;
	const struct _prop_list_t *properties;
};

struct _class_t {
	struct _class_t *isa;
	struct _class_t *superclass;
	void *cache;
	void *vtable;
	struct _class_ro_t *ro;
};

struct _category_t {
	const char *name;
	struct _class_t *cls;
	const struct _method_list_t *instance_methods;
	const struct _method_list_t *class_methods;
	const struct _protocol_list_t *protocols;
	const struct _prop_list_t *properties;
};
extern "C" __declspec(dllimport) struct objc_cache _objc_empty_cache;
#pragma warning(disable:4273)

extern "C" unsigned long int OBJC_IVAR_$_House$_person __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct House, _person);

static struct /*_ivar_list_t*/ {
	unsigned int entsize;  // sizeof(struct _prop_t)
	unsigned int count;
	struct _ivar_t ivar_list[1];
} _OBJC_$_INSTANCE_VARIABLES_House __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_ivar_t),
	1,
	{{(unsigned long int *)&OBJC_IVAR_$_House$_person, "_person", "@\"Person\"", 3, 8}}
};

static struct /*_method_list_t*/ {
	unsigned int entsize;  // sizeof(struct _objc_method)
	unsigned int method_count;
	struct _objc_method method_list[3];
} _OBJC_$_INSTANCE_METHODS_House __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_objc_method),
	3,
	{{(struct objc_selector *)"init", "@16@0:8", (void *)_I_House_init},
	{(struct objc_selector *)"person", "@16@0:8", (void *)_I_House_person},
	{(struct objc_selector *)"setPerson:", "v24@0:8@16", (void *)_I_House_setPerson_}}
};

static struct _class_ro_t _OBJC_METACLASS_RO_$_House __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	1, sizeof(struct _class_t), sizeof(struct _class_t), 
	(unsigned int)0, 
	0, 
	"House",
	0, 
	0, 
	0, 
	0, 
	0, 
};

static struct _class_ro_t _OBJC_CLASS_RO_$_House __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	0, __OFFSETOFIVAR__(struct House, _person), sizeof(struct House_IMPL), 
	(unsigned int)0, 
	0, 
	"House",
	(const struct _method_list_t *)&_OBJC_$_INSTANCE_METHODS_House,
	0, 
	(const struct _ivar_list_t *)&_OBJC_$_INSTANCE_VARIABLES_House,
	0, 
	0, 
};

extern "C" __declspec(dllimport) struct _class_t OBJC_METACLASS_$_NSObject;

extern "C" __declspec(dllexport) struct _class_t OBJC_METACLASS_$_House __attribute__ ((used, section ("__DATA,__objc_data"))) = {
	0, // &OBJC_METACLASS_$_NSObject,
	0, // &OBJC_METACLASS_$_NSObject,
	0, // (void *)&_objc_empty_cache,
	0, // unused, was (void *)&_objc_empty_vtable,
	&_OBJC_METACLASS_RO_$_House,
};

extern "C" __declspec(dllimport) struct _class_t OBJC_CLASS_$_NSObject;

extern "C" __declspec(dllexport) struct _class_t OBJC_CLASS_$_House __attribute__ ((used, section ("__DATA,__objc_data"))) = {
	0, // &OBJC_METACLASS_$_House,
	0, // &OBJC_CLASS_$_NSObject,
	0, // (void *)&_objc_empty_cache,
	0, // unused, was (void *)&_objc_empty_vtable,
	&_OBJC_CLASS_RO_$_House,
};
static void OBJC_CLASS_SETUP_$_House(void ) {
	OBJC_METACLASS_$_House.isa = &OBJC_METACLASS_$_NSObject;
	OBJC_METACLASS_$_House.superclass = &OBJC_METACLASS_$_NSObject;
	OBJC_METACLASS_$_House.cache = &_objc_empty_cache;
	OBJC_CLASS_$_House.isa = &OBJC_METACLASS_$_House;
	OBJC_CLASS_$_House.superclass = &OBJC_CLASS_$_NSObject;
	OBJC_CLASS_$_House.cache = &_objc_empty_cache;
}
#pragma section(".objc_inithooks$B", long, read, write)
__declspec(allocate(".objc_inithooks$B")) static void *OBJC_CLASS_SETUP[] = {
	(void *)&OBJC_CLASS_SETUP_$_House,
};
static struct _class_t *L_OBJC_LABEL_CLASS_$ [1] __attribute__((used, section ("__DATA, __objc_classlist,regular,no_dead_strip")))= {
	&OBJC_CLASS_$_House,
};
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
