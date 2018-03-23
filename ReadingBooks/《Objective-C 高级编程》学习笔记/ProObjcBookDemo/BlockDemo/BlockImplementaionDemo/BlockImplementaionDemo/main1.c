//
//  main1.c
//  BlockImplementaionDemo
//
//  Created by ShannonChen on 2017/4/2.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#include <stdio.h>


int main () {
    
    int val1 = 256;
    int val2 = 10;
    const char *fmt = "val2 = %d\n";
    
    void (^myBlock)(void) = ^void(void) {
        printf(fmt, val2);
    };
    
    val2 = 2;
    fmt = "These values were changed. val2 = %d\n";
    
    myBlock();
    
    return 0;
}
