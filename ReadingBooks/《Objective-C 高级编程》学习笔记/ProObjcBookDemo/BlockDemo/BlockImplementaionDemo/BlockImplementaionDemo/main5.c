//
//  main5.c
//  BlockImplementaionDemo
//
//  Created by ShannonChen on 2017/4/2.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#include <stdio.h>



int main() {
    
    __block int block_val = 8;
    
    void (^myBlock0)(void) = ^void(void) {
        block_val = 9;
    };
    
    void (^myBlock1)(void) = ^void(void) {
        block_val = 10;
    };
    
    myBlock0();
    myBlock1();
    
}
