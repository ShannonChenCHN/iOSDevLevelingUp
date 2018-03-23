//
//  ViewController.m
//  ARCDemo
//
//  Created by ShannonChen on 2017/3/26.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "Test.h"

@interface ViewController () {
    __weak id memeberObj_;
//    __unsafe_unretained id memeberObj_;  // __weak 声明的变量会在所指向的对象销毁后，将变量值置为 nil，而 __unsafe_unretained 不会
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // __strong 修饰符
    [self testStrongOwnershipQualifier];
    
    // 带有 __strong 修饰符的变量之间可以相互赋值
    [self demonstrateAssignableStrongVariable];
    
    // 在类成员变量上和方法参数上使用 __strong
    [self useStrongQualifierAsAMemeberVariableOfClassAndMethodArguments];
    
    // 循环引用
    [self testRetainCycle];
    
    NSLog(@"memeberObj2: %@", memeberObj_);
    
    [Test testAutoreleaseQualifier];
    
    id __unsafe_unretained object1;
    id __strong object2;
    NSLog(@"__unsafe_unretained object: %@", object1);
    NSLog(@"__strong object: %@", object2);
}

uintptr_t _objc_rootRetainCount(id obj);

- (void)testStrongOwnershipQualifier {
    // 自己生成的对象自己持有
    id __strong obj = [[NSObject alloc] init];  // 相当于 id obj = [[NSObject alloc] init];
    
    // 非自己生成的对象，也可以持有
    __strong NSArray *array = [NSArray array];
    
    @autoreleasepool {
        id __strong obj = [[NSObject alloc] init];
        id __autoreleasing o = obj;
        NSLog(@"retain count = %lu", _objc_rootRetainCount(obj));
    }
    
    
}
// 变量 obj 和 array 超出作用域，强引用失效
// obj 会被 release 掉，引用计数变为 0，最终被销毁了
// array 会被 autoreleasepool 给 release 掉，引用计数变为 0，最终也被销毁了
/**
 上面的代码相当于 MRR 中：（不确定这里猜想的对不对？？？）
 - (void)testStrongOwnershipQualifier {
    // 自己生成的对象自己持有
    id obj = [[NSObject alloc] init];
 
    // 非自己生成的对象，也可以持有
    NSArray *array = [NSArray array];
    [array retain];
 
    [obj release];
    [array release];
 }
 */


- (void)demonstrateAssignableStrongVariable {
    
    id __strong kobe = [[NSObject alloc] init];  // 创建并持有 “对象 A”，kobe 持有“对象A”的强引用
    id __strong lbj = [[NSObject alloc] init];  // 创建并持有 “对象 B”，lbj 持有“对象B”的强引用
    id __strong durant = nil; // durant 不持有任何对象
    
    id __weak trackObjA = kobe; // 用来跟踪 “对象 A” 的生命周期，但不对其产生影响
    NSLog(@"trackObjA_1 %@", trackObjA);
    
    id __weak trackObjB = lbj; // 用来跟踪 “对象 B” 的生命周期，但不对其产生影响
    NSLog(@"trackObjB_1 %@", trackObjB);
    
    kobe = lbj;    // lbj 把“对象B”的地址传给 kobe，kobe 也持有了“对象B”的强引用，同时 kobe 失去原来对“对象A”的强引用，“对象A”没有了持有者，因此马上就被销毁了
    NSLog(@"trackObjA_2 %@", trackObjA);
    
    durant = kobe;    // kobe 把“对象B”的地址又传给了 durant，durant 也持有了“对象B”的强引用。此时“对象B”同时被 kobe、lbj 和 durant 强引用
    
    lbj = nil;   // 因为 lbj 被赋值 nil，所以失去了对“对象B”的强引用。此时“对象B”同时被 kobe 和 durant 强引用
    
    kobe = nil;  // 因为 kobe 被赋值 nil，所以失去了对“对象B”的强引用。此时“对象B”只被 durant 强引用
    
    NSLog(@"trackObjB_2 %@", trackObjB);
    
    durant = nil; // 因为 durant 被赋值 nil，所以也失去了对“对象B”的强引用。此时“对象B”不再被任何变量强引用，也就是说没有人用它了，所以”对象B“也被马上销毁了
    NSLog(@"trackObjB_3 %@", trackObjB);
}


- (void)useStrongQualifierAsAMemeberVariableOfClassAndMethodArguments {
    
    id __strong test = [[Test alloc] init];   // test 变量持有 Test 对象的强引用
    [test setObject:[[NSObject alloc] init]]; // Test 对象的成员变量 obj_ 持有 NSObject 对象的强引用
}
// 因为 test 变量超出其作用域，强引用失效，所以立即释放了 Test 对象，由于 Test 对象不再被持有，因此被销毁了
// Test 对象被销毁时，其 dealloc 方法会被调用，因此 Test 对象的成员变量 obj_ 强引用的对象也被释放了，因为 obj_ 所持有的对象不再被其他对象持有，所以也被销毁了


- (void)testRetainCycle {
    id test0 = [[Test alloc] init];
    id test1 = [[Test alloc] init];
    
    // 发生在两个对象之间的循环引用
    [test0 setObject:test1];
    [test1 setObject:test0];
    memeberObj_ = test0;
    NSLog(@"memeberObj1: %@", memeberObj_);
    
    // 发生在一个对象自身的循环引用
//    [test0 setObject:test0];
}

@end
