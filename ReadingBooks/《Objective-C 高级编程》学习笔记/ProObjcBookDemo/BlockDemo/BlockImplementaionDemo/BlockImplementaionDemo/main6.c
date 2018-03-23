//
//  main6.c
//  BlockImplementaionDemo
//
//  Created by ShannonChen on 2017/4/2.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#include <stdio.h>

void(^globalBlcok)() = ^void(void) {
    // 全局的 block
};

int main() {
    
    // 局部变量的 block，但是不捕获自动变量
    int (^stackBlock)(int) = ^int(int a) {
        return a;
    };

    stackBlock(1);
    
    return 0;
}
