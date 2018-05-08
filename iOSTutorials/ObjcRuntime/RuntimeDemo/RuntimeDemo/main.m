//
//  main.m
//  RuntimeDemo
//
//  Created by ShannonChen on 2018/3/7.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <malloc/malloc.h>

#import "Person.h"


// 打印所有属性名
void class_printAllProtertyNames(Class class) {
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
    
    for (unsigned i = 0; i < propertyCount; i++) {
        NSString *propertyName = @(property_getName(properties[i]));
        NSLog(@"%@", propertyName);
    }
    
    free(properties);
}


// 打印所有示例方法名
void class_printAllInstanceMethodNames(Class class) {
    
    unsigned int count;
    Method *methods = class_copyMethodList(class, &count); // 不过只能获取到当前类的方法列表中的**实现**的所有方法，继承链上的父类实现的方法拿不到
    
    for (NSInteger i = 0; i < count; ++i) {
        Method method = methods[i];
        
        SEL methodSelector = method_getName(method);
        NSString *methodName = NSStringFromSelector(methodSelector);
        NSLog(@"%@", methodName);
    }
    
    free(methods);
    
}

// 打印所有类方法名
void class_printAllClassMethodNames(Class class) {
    class_printAllInstanceMethodNames(object_getClass(class));
}

// 打印所有加载的库名
void printAllLoadedLibraryNames() {
    unsigned int count = 0;
    const char **imageNames = objc_copyImageNames(&count);
    
    for (int i = 0; i < count; i++) {
        const char *imageName = imageNames[i];
        
        NSLog(@"%s", imageName);
    }
}

void printClassInfo(const char *clsName, BOOL isMetaCls) {
    
    NSLog(@"clsName: %s, isMetaCls: %@", clsName, isMetaCls ? @"YES" : @"NO");
}

void getClassHierachy() {
    Person *person = [[Person alloc] init];
    
    Class cls = object_getClass(person);     // Person(Class)
    printClassInfo(class_getName(cls),       // Person
                   class_isMetaClass(cls));  // NO
    
    Class meta = object_getClass(cls);       // Person(meta-class)
    printClassInfo(class_getName(meta),      // Person
                   class_isMetaClass(meta)); // YES
    
    Class meta_meta = object_getClass(meta);      // NSObject(meta-class)
    printClassInfo(class_getName(meta_meta),      // NSObject
                   class_isMetaClass(meta_meta)); // YES
}

static BOOL driveWithCarIMP(id self, SEL sel, id car) {
    NSLog(@"新的实现：%@ %s%@", self, __func__, car);
    
    return (car != nil);
}

void exchangeMethods() {
    
    // 拿到 Method
    Class cls = NSClassFromString(@"Person");
    SEL originalSelector = @selector(driveWithCar:);
    Method method = class_getInstanceMethod(cls, originalSelector);
    
    // 获得方法的函数指针
    IMP imp = method_getImplementation(method);
    
    // 获得方法的参数类型
    char *typeDescription = (char *)method_getTypeEncoding(method);
    
    // 新增一个 selector，指向原来的 driveWithCar: 的方法实现
    class_addMethod(cls, @selector(orig_driveWithCar:), imp, typeDescription);
    
    // 将原来的 driveWithCar: 方法选择器的实现替换成新的实现
    class_replaceMethod(cls, originalSelector, driveWithCarIMP, typeDescription);
    
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//        class_printAllProtertyNames(Person.class);
//
//        printAllLoadedLibraryNames();
//
//        class_printAllClassMethodNames(Person.class);
//        class_printAllInstanceMethodNames(Person.class);
//
//        getClassHierachy();

        exchangeMethods();
        Person *person = [[Person alloc] init];
        [person driveWithCar:@"car"];
        BOOL result = [person run];
        
    }
    return 0;
}



