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


void class_printAllProtertyNames(Class class) {
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
    
    for (unsigned i = 0; i < propertyCount; i++) {
        NSString *propertyName = @(property_getName(properties[i]));
        NSLog(@"%@", propertyName);
    }
    
    free(properties);
}

void class_getMethodNames(Class class) {
    
    uint count;
    Method *methods = class_copyMethodList(class, &count);
    
    for (NSUInteger i = 0; i < count; ++i) {
        Method method = methods[i];
        
        SEL methodSelector = method_getName(method);
        NSString *methodName = NSStringFromSelector(methodSelector);
        NSLog(@"%@", methodName);
    }
    
    free(methods);
    
}

void printClassesAfterAllocatedOrInitilized() {
    id obj1 = [NSMutableArray alloc];
    id obj2 = [[NSMutableArray alloc] init];
    
    id obj3 = [NSArray alloc];
    id obj4 = [[NSArray alloc] initWithObjects:@"Hello",nil];
    
    NSLog(@"obj1 class is %@",NSStringFromClass([obj1 class]));
    NSLog(@"obj2 class is %@",NSStringFromClass([obj2 class]));
    
    NSLog(@"obj3 class is %@",NSStringFromClass([obj3 class]));
    NSLog(@"obj4 class is %@",NSStringFromClass([obj4 class]));
    
    id obj5 = [Person alloc];
    id obj6 = [[Person alloc] init];
    
    NSLog(@"obj5 class is %@",NSStringFromClass([obj5 class]));
    NSLog(@"obj6 class is %@",NSStringFromClass([obj6 class]));
}

void callMethodThroughFuntionPointer() {
    Person *person = [[Person alloc] init];
    
    SEL selector = @selector(driveWithCar:);
    IMP imp = [person methodForSelector:selector];
    
    BOOL (*drive)(id, SEL, id) = (__typeof__(drive))imp;
    drive(person, selector, @"car");
    //        objc_msgSend(person, selector, @"car");
}


@interface A : NSObject { @public int a; } @end
@implementation A @end
@interface B : A { @public int b; } @end
@implementation B @end
@interface C : B { @public int c; } @end
@implementation C @end

void printObjectInHexRepresentation() {
    
    C *obj = [[C alloc] init];
    obj->a = 0xaaaaaaaa;
    obj->b = 0xbbbbbbbb;
    obj->c = 0xcccccccc;
    
    NSData *objData = [NSData dataWithBytes:(__bridge const void * _Nullable)(obj) length:malloc_size(CFBridgingRetain(obj))];
    NSLog(@"Object contains %@", objData);
}


void printAllLoadedLibraryNames() {
    unsigned int count = 0;
    const char **imageNames = objc_copyImageNames(&count);
    
    for (int i = 0; i < count; i++) {
        const char *imageName = imageNames[i];
        
        NSLog(@"%s", imageName);
    }
}

void run() {
    NSLog(@"%s", __FUNCTION__);
}


union {
    int i;
    char x[2];
}a;


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//        class_printAllProtertyNames(Person.class);
//
//        class_getMethodNames(NSString.class);
//
//        printClassesAfterAllocatedOrInitilized();
//
//        callMethodThroughFuntionPointer();
//
//        printObjectInHexRepresentation();
//
//        printAllLoadedLibraryNames();
        
        a.x[0] = 10;
        a.x[1] = 1;
        printf("%d\n",a.i);
    }
    return 0;
}



