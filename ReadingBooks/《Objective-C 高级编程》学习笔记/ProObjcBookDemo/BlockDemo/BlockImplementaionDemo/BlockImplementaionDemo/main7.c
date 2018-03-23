//
//  main7.c
//  BlockImplementaionDemo
//
//  Created by ShannonChen on 2017/4/2.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#include <stdio.h>


typedef int (^returnedBlock)(int a);

// block 作为返回值
returnedBlock func() {
    return ^int (int a) {
        return 5;
    };
}
