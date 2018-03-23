//
//  main9.c
//  BlockImplementaionDemo
//
//  Created by ShannonChen on 2017/4/2.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#include <stdio.h>


int main() {
    
    typedef void(^blk_t) (id obj);
    
    blk_t blk;
    {
        // 带有 __block 的  Objective-C 对象
        __block id array = [[NSMutableArray alloc] init];
        blk = ^void(id obj) {
            [array addObject:obj];
            
            NSLog(@"array count = %ld", [array count]);
        };
    }
    
    
    blk([[NSObject alloc] init]);
    blk([[NSObject alloc] init]);
    blk([[NSObject alloc] init]);
    
    return 0;
}
