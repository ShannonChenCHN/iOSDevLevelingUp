//
//  Test.m
//  ARCDemo
//
//  Created by ShannonChen on 2017/3/26.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "Test.h"



@implementation Test

- (void)setObject:(id)obj {
    obj_ = obj;
}

+ (void)testAutoreleaseQualifier {
    
    // 显式使用 __autoreleasing
    @autoreleasepool {
        id __autoreleasing obj = [[NSObject alloc] init];
    }
    
    // 以上代码相当于下面的 MRR 代码
    /**
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
     [obj autorelease];
     [pool drain];
     
     */
    
    // 非显式使用 __autoreleasing 情形一
    @autoreleasepool {
        id __strong obj = [NSMutableArray array];  // 取得非自己生成并持有的对象
        // 因为变量 obj 为强引用，所以自己持有该对象
        // 该对象由编译器判断其方法名后，自动注册到 autoreleasepool
        
    }
    
//    NSError *error = nil;
//    NSError **pError = &error;
    
    
}


+ (void)testArray {
    
   
    [self testStaticArray];
    
    [self testDynamicArray];
    
}

/// 静态数组
+ (void)testStaticArray {
    
    id array[10];
//    NSLog(@"%li", array.count);  // 报错：Member reference base type 'id__strong[10]'is not a structure or union
    array[0] = [[NSObject alloc] init];
}
/**
 数组超出其变量作用域， 数组中各个带有 __strong 的元素也随之被释放了，这些元素的强引用也随之失效。
 */

/// 动态数组
+ (void)testDynamicArray {
    id __strong *array = nil;
}


+ (void)testObjcRuntime {
    
}

@end
