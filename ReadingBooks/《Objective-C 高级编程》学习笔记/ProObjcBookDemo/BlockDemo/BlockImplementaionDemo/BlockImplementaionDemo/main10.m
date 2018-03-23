//
//  main10.c
//  BlockImplementaionDemo
//
//  Created by ShannonChen on 2017/4/2.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

int main() {
    
    typedef void(^blk_t) (id obj);
    
    blk_t blk;
    {
        // 捕获带有 __weak 的 Objective-C  对象
        id array = [[NSMutableArray alloc] init];
        id __weak weakArray = array;
        
        blk = ^void(id obj) {
            [weakArray addObject:obj];
            
            NSLog(@"array: %@, array count = %ld", weakArray, [weakArray count]);
        };
    }
    blk([[NSObject alloc] init]);
    blk([[NSObject alloc] init]);
    blk([[NSObject alloc] init]);
    
    
    
    
    return 0;
}
