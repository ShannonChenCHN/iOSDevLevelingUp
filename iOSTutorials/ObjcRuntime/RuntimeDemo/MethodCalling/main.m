//
//  main.m
//  MethodCalling
//
//  Created by ShannonChen on 2018/5/4.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

// 通过调用函数指针的方式调用方法
void callMethodThroughFuntionPointer() {
    Person *person = [[Person alloc] init];
    
    SEL selector = @selector(driveWithCar:);
    IMP imp = [person methodForSelector:selector];
    
    BOOL (*drive)(id, SEL, id) = (__typeof__(drive))imp; // 前两个参数为隐藏参数：第一个参数为 receiver，第二个参数为选择器
    drive(person, selector, @"car");
    //        objc_msgSend(person, selector, @"car");
}


void callMethodThroughInvocation() {
    
    SEL selector = @selector(person);
    NSMethodSignature *sign = [Person methodSignatureForSelector:selector];
    NSInvocation *invokation = [NSInvocation invocationWithMethodSignature:sign];
//        [invocation getArgument:<#(nonnull void *)#> atIndex:<#(NSInteger)#>];
    [invokation setTarget:[Person class]];
    [invokation setSelector:selector];
    [invokation invoke];
    
   
// 涉及到内存管理方面的问题：void *和 Objective-C 对象
// https://github.com/bang590/JSPatch/wiki/JSPatch-%E5%AE%9E%E7%8E%B0%E5%8E%9F%E7%90%86%E8%AF%A6%E8%A7%A3#2%E5%86%85%E5%AD%98%E9%97%AE%E9%A2%98
// https://www.jianshu.com/p/11c3bc21f56e
// https://developer.apple.com/library/content/documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html
#define MEMORY_LEAK   0
#define OVER_RELEASE   0
#if MEMORY_LEAK
    
    // If we call method `new`, we will get memory leak here.
    // 这里使用的是 __weak 弱引用，所以在变量超出作用域时，不会 release 对象，但是在调用 alloc/new/copy/mutableCopy 时，返回的对象的 retainCount 已经是 1 了，这样就导致了没有释放，造成内存泄漏
    __weak Person *person;
    [invokation getReturnValue:&person];
#elif OVER_RELEASE
    // If we call method `person`, we will get over released here.
    // 这里的 `Person *person;` 相当于 `__strong Person *person;` 根据 ARC 的机制，会自动插入一条 retain 语句，然后在退出作用域时插入 release 语句。
    // 但我们这里不是显式对 person 进行赋值，而是传入 `-getReturnValue:` 方法，在这里面赋值后 ARC 没有自动给这个变量插入 retain 语句，但退出作用域时还是自动插入了 release 语句，导致这个变量多释放了一次，导致 crash。
    Person *person;
    [invokation getReturnValue:&person];
    
#else
    Person *person;
    void *returnValue;
    [invokation getReturnValue:&returnValue];
    if (selector == @selector(new) ||
        selector == @selector(alloc)) {
        person = (__bridge_transfer Person *)returnValue; // 将所有权转交过来，引用计数不变，但是强引用的所有权变了，相当于先 retain 新值，后释放旧值
    } else { // 此时编译器本应该在执行方法得到非自己声称并持有的对象后，进行 retain 操作，但是这里却没有，所以
        person = (__bridge Person *)returnValue; // 只涉及到对象类型，没有涉及到对象所有权的转化，也不会产生新的引用关系，不会改变引用计数，所以当 person 超出作用域时，也不会 release 对象
    }
#endif

    NSLog(@"%@", person);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//        callMethodThroughFuntionPointer();
        callMethodThroughInvocation();
    }
    return 0;
}
