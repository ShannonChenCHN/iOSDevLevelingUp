//
//  main.m
//  BlockImplementaionDemo
//
//  Created by ShannonChen on 2017/3/29.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockTest.h"

void func1(int a[10]) {
    int *b = a; // 取首个元素的地址
    printf("%d\n", *(b+1));
    printf("%d\n", b[1]);
}


//void func2(int a[10]) {
//    int b[10] = a;  // C 语言中，不能直接引用整个数组，只能引用数组中的一个元素或者一个数组元素的指针，而且 C 语言中，指针是一个变量，但是数组名不是变量
//    printf("%d\n", b[1]);
//}

void func3(int *a) {
    int *b = a;
    printf("%d\n", *(b+1));
}

int main() {
    /*
    const char *d = "d";
    printf("%s\n", d); // 打印结果为 d
    const char *c = d;
    c = "c";
    printf("%s\n", d); // 仍然是 d
    */
    void (^block)(void) = ^void(void) {
        printf("Block\n");
    };
    
    block();
    
    int a[10] = {2, 3, 4};
    printf("%d\n", *a); // *a 是数组首元素
    func1(a); // a 是数组首元素地址
    
    typedef void(^blockInArray)();
    blockInArray block1 = [[[BlockTest alloc] init] getBlockArray][0];
    block1();
    
    return 0;
}

