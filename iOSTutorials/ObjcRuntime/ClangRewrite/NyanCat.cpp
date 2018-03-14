#ifndef __OBJC2__
#define __OBJC2__
#endif

#ifndef _REWRITER_typedef_NyanCat
#define _REWRITER_typedef_NyanCat
typedef struct objc_object NyanCat; // NyanCat 类实际上就是一个 objc_object 结构体
typedef struct {} _objc_exc_NyanCat;
#endif

extern "C" unsigned long OBJC_IVAR_$_NyanCat$_cost;
struct NyanCat_IMPL {
	struct NSObject_IMPL NSObject_IVARS;
	int age;
	NSString *name;
	NSString *_cost;
};


// @property (nonatomic, copy) NSString *cost;

// - (void)nyan;
// + (void)nyan;
/* @end */


// @implementation NyanCat

static void _I_NyanCat_nyan1(NyanCat * self, SEL _cmd) {  // instance 方法被转成了静态函数
    printf("instance nyan~");
}

static void _C_NyanCat_nyan2(Class self, SEL _cmd) {  // class 方法也被转成了静态函数
    printf("class nyan~");
}

// 属性 cost 的 setter 和 getter 函数
static NSString * _I_NyanCat_cost(NyanCat * self, SEL _cmd) { return (*(NSString **)((char *)self + OBJC_IVAR_$_NyanCat$_cost)); }
extern "C" __declspec(dllimport) void objc_setProperty (id, SEL, long, id, bool, bool);

static void _I_NyanCat_setCost_(NyanCat * self, SEL _cmd, NSString *cost) { objc_setProperty (self, _cmd, __OFFSETOFIVAR__(struct NyanCat, _cost), (id)cost, 0, 1); }
// @end


// main 函数
int main() {

    // 方法调用转成了 runtime 函数调用
    NyanCat *cat = ((NyanCat *(*)(id, SEL))(void *)objc_msgSend)((id)((NyanCat *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NyanCat"), sel_registerName("alloc")), sel_registerName("init"));
    ((void (*)(id, SEL))(void *)objc_msgSend)((id)cat, sel_registerName("nyan1"));

    ((void (*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NyanCat"), sel_registerName("nyan2"));

    return 0;
}

// 属性的数据结构
struct _prop_t {
	const char *name;
	const char *attributes;
};

struct _protocol_t;

// 方法的实际结构
struct _objc_method {
	struct objc_selector * _cmd;
	const char *method_type;
	void  *_imp;
};

// 协议的实际结构
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

// 实例变量的结构
struct _ivar_t {
	unsigned long int *offset;  // pointer to ivar offset location
	const char *name;
	const char *type;
	unsigned int alignment;
	unsigned int  size;
};

// Class 相关的信息
struct _class_ro_t {
	unsigned int flags;
	unsigned int instanceStart;
	unsigned int instanceSize;
	unsigned int reserved;
	const unsigned char *ivarLayout;
    const char *name;                           // 类名
    const struct _method_list_t *baseMethods;   // 方法列表
    const struct _objc_protocol_list *baseProtocols;  // 协议列表
    const struct _ivar_list_t *ivars;           // 实例变量列表
    const unsigned char *weakIvarLayout;
    const struct _prop_list_t *properties;      // 属性列表
};

// Class 的实际结构
struct _class_t {
	struct _class_t *isa;
	struct _class_t *superclass;
	void *cache;
	void *vtable;
	struct _class_ro_t *ro;
};

// 分类的结构
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

extern "C" unsigned long int OBJC_IVAR_$_NyanCat$age __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct NyanCat, age);
extern "C" unsigned long int OBJC_IVAR_$_NyanCat$name __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct NyanCat, name);
extern "C" unsigned long int OBJC_IVAR_$_NyanCat$_cost __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct NyanCat, _cost);


// 实例变量列表
static struct /*_ivar_list_t*/ {
	unsigned int entsize;  // sizeof(struct _prop_t)
	unsigned int count;
	struct _ivar_t ivar_list[3];
} _OBJC_$_INSTANCE_VARIABLES_NyanCat __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_ivar_t),
	3,
	{{(unsigned long int *)&OBJC_IVAR_$_NyanCat$age, "age", "i", 2, 4},
	 {(unsigned long int *)&OBJC_IVAR_$_NyanCat$name, "name", "@\"NSString\"", 3, 8},
	 {(unsigned long int *)&OBJC_IVAR_$_NyanCat$_cost, "_cost", "@\"NSString\"", 3, 8}}
};


// 实例方法列表
static struct /*_method_list_t*/ {
	unsigned int entsize;  // sizeof(struct _objc_method)
	unsigned int method_count;
	struct _objc_method method_list[3];
} _OBJC_$_INSTANCE_METHODS_NyanCat __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_objc_method),
	3,
	{{(struct objc_selector *)"nyan1", "v16@0:8", (void *)_I_NyanCat_nyan1},
	{(struct objc_selector *)"cost", "@16@0:8", (void *)_I_NyanCat_cost},
	{(struct objc_selector *)"setCost:", "v24@0:8@16", (void *)_I_NyanCat_setCost_}}
};


// 类方法列表
static struct /*_method_list_t*/ {
	unsigned int entsize;  // sizeof(struct _objc_method)
	unsigned int method_count;
	struct _objc_method method_list[1];
} _OBJC_$_CLASS_METHODS_NyanCat __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_objc_method),
	1,
	{{(struct objc_selector *)"nyan2", "v16@0:8", (void *)_C_NyanCat_nyan2}}
};

// 属性列表
static struct /*_prop_list_t*/ {
	unsigned int entsize;  // sizeof(struct _prop_t)
	unsigned int count_of_properties;
	struct _prop_t prop_list[1];
} _OBJC_$_PROP_LIST_NyanCat __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_prop_t),
	1,
	{{"cost","T@\"NSString\",C,N,V_cost"}}
};


// 存储元类信息的结构
static struct _class_ro_t _OBJC_METACLASS_RO_$_NyanCat __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	1, sizeof(struct _class_t), sizeof(struct _class_t), 
	(unsigned int)0, 
	0, 
	"NyanCat",
	(const struct _method_list_t *)&_OBJC_$_CLASS_METHODS_NyanCat,  // 类方法
	0, 
	0, 
	0, 
	0, 
};


// 存储类信息的结构
static struct _class_ro_t _OBJC_CLASS_RO_$_NyanCat __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	0, __OFFSETOFIVAR__(struct NyanCat, age), sizeof(struct NyanCat_IMPL), 
	(unsigned int)0, 
	0, 
	"NyanCat", // 类名
	(const struct _method_list_t *)&_OBJC_$_INSTANCE_METHODS_NyanCat,  // 实例方法
	0, 
	(const struct _ivar_list_t *)&_OBJC_$_INSTANCE_VARIABLES_NyanCat,  // 实例变量列表
	0, 
	(const struct _prop_list_t *)&_OBJC_$_PROP_LIST_NyanCat,          // 属性列表
};

extern "C" __declspec(dllimport) struct _class_t OBJC_METACLASS_$_NSObject;

// NyanCat 元类
extern "C" __declspec(dllexport) struct _class_t OBJC_METACLASS_$_NyanCat __attribute__ ((used, section ("__DATA,__objc_data"))) = {
	0, // &OBJC_METACLASS_$_NSObject,
	0, // &OBJC_METACLASS_$_NSObject,
	0, // (void *)&_objc_empty_cache,
	0, // unused, was (void *)&_objc_empty_vtable,
	&_OBJC_METACLASS_RO_$_NyanCat,   // 存储元类信息，包含了类方法等，是一个 _class_ro_t 类型
};

extern "C" __declspec(dllimport) struct _class_t OBJC_CLASS_$_NSObject;

// NyanCat 类
extern "C" __declspec(dllexport) struct _class_t OBJC_CLASS_$_NyanCat __attribute__ ((used, section ("__DATA,__objc_data"))) = {
	0, // &OBJC_METACLASS_$_NyanCat,
	0, // &OBJC_CLASS_$_NSObject,
	0, // (void *)&_objc_empty_cache,
	0, // unused, was (void *)&_objc_empty_vtable,
	&_OBJC_CLASS_RO_$_NyanCat,    // 存储类信息，包含了实例方法 ivar 信息等，是一个 _class_ro_t 类型
};

// 类的初始化设置
static void OBJC_CLASS_SETUP_$_NyanCat(void ) {
	OBJC_METACLASS_$_NyanCat.isa = &OBJC_METACLASS_$_NSObject;          // isa 指向元类 NSObject
	OBJC_METACLASS_$_NyanCat.superclass = &OBJC_METACLASS_$_NSObject;   // 父类是元类 NSObject
	OBJC_METACLASS_$_NyanCat.cache = &_objc_empty_cache;
	OBJC_CLASS_$_NyanCat.isa = &OBJC_METACLASS_$_NyanCat;       // isa 指向元类 NyanCat
	OBJC_CLASS_$_NyanCat.superclass = &OBJC_CLASS_$_NSObject;   // 父类是类 NSObject
	OBJC_CLASS_$_NyanCat.cache = &_objc_empty_cache;
}
#pragma section(".objc_inithooks$B", long, read, write)
__declspec(allocate(".objc_inithooks$B")) static void *OBJC_CLASS_SETUP[] = {
	(void *)&OBJC_CLASS_SETUP_$_NyanCat,
};
static struct _class_t *L_OBJC_LABEL_CLASS_$ [1] __attribute__((used, section ("__DATA, __objc_classlist,regular,no_dead_strip")))= {
	&OBJC_CLASS_$_NyanCat,
};
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
