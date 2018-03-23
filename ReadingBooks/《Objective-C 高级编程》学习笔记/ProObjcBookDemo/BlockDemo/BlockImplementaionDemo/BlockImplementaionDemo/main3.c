//
//  main3.c
//  BlockImplementaionDemo
//
//  Created by ShannonChen on 2017/4/2.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#include <stdio.h>

int global_val = 60;
static int static_global_val = 10;

int main() {
    
    int val = 10;
    static int static_val = 4;
    
    void (^myBlock)(void) = ^void(void) {
//        val = 20;
        static_val = 30;
        global_val = 6;
        static_global_val = 50;
        printf("myBlock:val(10) = %d,\n static_val(4) = %d,\n global_val(60) = %d,\n static_global_val(10) = %d\n", val, static_val, global_val, static_global_val);
    };
    
    myBlock();
    
}
