//
//  main.m
//  BlockTest
//
//  Created by ShannonChen on 2018/3/23.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "House.h"


typedef void(^BlockType)(void);


// 全局的 block
void (^globalBlock)(void) = ^ { };
void PrintGlobalBlock() {
    NSLog(@"%@", globalBlock); // __NSGlobalBlock__
}

// 在 block 中不能直接修改外部的 OC 对象
void ModifyAObjCObjectInBlock() {
    House *house = [[House alloc] init];
    
    void (^myBlock)(void) = ^ {
        
//            house = [[House alloc] init]; // 编译失败
        house.name = @"大房子"; // 可以编译通过，可以修改属性值
    };
    
    NSLog(@"%@", myBlock); // __NSMallocBlock__
}

// block 作为函数参数
void BlockAsAFunctionParameter() {
    
    NSString *string = @"This is a string!";
    void (^myBlock)(void) = ^ {
        
        NSLog(@"myBlock: %@", string);
    };
    
    void(^anotherBlock)(BlockType aBlock) = ^(BlockType aBlock){
        NSLog(@"AnotherBlock");
        
        aBlock();
    };
    
    anotherBlock(myBlock);
    
    // 可以把这里传进去的 myBlock 看成是一个对象，调用 anotherBlock 时，就相当于调用一个函数，在这个函数中，myBlock 跟 anotherBlock 没有什么
    // 引用关系，myBlock 纯粹是一个参数，所以只需要考虑 myBlock 本身的情况。另外，myBlock 将外部的 string 对象捕获进去了，而且 myBlock 在堆上，所以 myBlock 对这个 string 对象进行了强引用。
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        ModifyAObjCObjectInBlock();
        
        NSLog(@"%@", ^{});  // __NSGlobalBlock__
        
        PrintGlobalBlock();
        BlockAsAFunctionParameter();
        
    }
    return 0;
}

