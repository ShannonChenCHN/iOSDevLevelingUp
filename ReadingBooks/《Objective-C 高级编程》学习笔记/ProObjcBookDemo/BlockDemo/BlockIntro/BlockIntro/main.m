//
//  main.m
//  BlockIntro
//
//  Created by ShannonChen on 2017/3/31.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef int(^MyBlock)(int a);


/// block 作为函数参数
void useBlockAsParameters(int (^block)(int)) {
    block(2);
}

/// block 作为函数返回值
int (^useBlockAsReturnValue())(int) {
    return ^int(int b) {
        NSLog(@"use block as a return value: %d + 1 = %d", b, (b + 1));
        return b + 1;
    };
}

/// 函数
int sum(int a, int b) {
    return a + b;
}

/// 函数指针和 block 的对比
void compareFunctionPointerWithBlock() {
    // 函数指针
    int (*funcPointer)(int, int) = &sum;
    int sum1 = funcPointer(1, 2);
    int sum2 = (*funcPointer)(1, 3);
    
    NSLog(@"sum1 = %d, sum2 = %d", sum1, sum2);
    
    // block
    int(^sumBlock)(int, int) = ^int (int a, int b) {
        return a + b;
    };
    
    int sum3 = sumBlock(4, 5);
    NSLog(@"sum3 = %d", sum3);
    
    /**
     block 与函数在定义上的区别：
     1.block 没有函数名
     2.block 的返回值类型前面带有 “^”
     
     // block
     ^int (int a, int b) {
     return a + b;
     };
     
     // 函数
     int sum(int a, int b) {
     return a + b;
     }
     
     
     */
    
    
    /**
     block 变量与函数指针变量的语义区别：
     唯一的区别在于变量名前的 “^” 和 “*”
     
     // block 变量
     int(^sumBlock)(int, int)
     
     // 函数指针变量
     int (*funcPointer)(int, int)
     
     */
}



//----------------------------------------------------------------------------------------------------

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        // 函数指针和 block 的对比
        compareFunctionPointerWithBlock();
        
        
        // block 作为函数参数
        useBlockAsParameters(^int(int a) {
            NSLog(@"use block as a parameter: %d + 1 = %d", a, a + 1);
            return a + 1;
        });
        
        
        
        // block 作为函数返回值
        MyBlock myBlock = useBlockAsReturnValue();
        myBlock(7);
        
        
        // 截获自动变量
        __block int val = 20;  // 需要声明 __block，才能在 block 中改变值
        const char *fmt = "original val = %d\n";
        void (^log)(void) = ^void() {
            val = 40;
            printf(fmt, val);
        };
        
        val = 10;
        fmt = "These values were changed. val = %d\n";
        log();
        
        printf("val = %d\n", val);
        
        
        // 截获 Objective-C 对象
        id array = [NSMutableArray array];
        void (^blockToCaptureObject)(void) = ^void(void) {
            id obj = [[NSObject alloc] init];
            
            [array addObject:obj];
        };
        blockToCaptureObject();
        
        // 不允许截获 c 语言数组
//    const char text[] = "hello";
//    void (^blockToCaptureCArray)(void) = ^void(void) {
//        printf("The third letter is %c\n", text[2]);
//    };
        
//    int nums[] = {1, 2, 3};
//    void (^blockToCaptureCArray)(void) = ^void(void) {
//        printf("The third letter is %c\n", nums[2]);
//    };
        
        // 截获字符串数组（指针）
        const char *text = "hello";
        void (^blockToCaptureCString)(void) = ^void(void) {
            printf("The second letter is %c\n", text[1]);
        };
        
        blockToCaptureCString();
        
    }
    return 0;
}



