//
//  main2.c
//  BlockImplementaionDemo
//
//  Created by ShannonChen on 2017/4/2.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#include <stdio.h>


int main() {
    
    // 不截获自动变量的 block
    void (^block1)(void) = ^void(void) {
        printf("Block\n");
    };
    
    block1();
    
    // 截获 c 语言数组
    const char *text = "hello";
    void (^blockToCaptureCArray)(void) = ^void(void) {
        printf("The third letter is %c\n", text[2]);
    };
    
    blockToCaptureCArray();
    
    return 0;
}
