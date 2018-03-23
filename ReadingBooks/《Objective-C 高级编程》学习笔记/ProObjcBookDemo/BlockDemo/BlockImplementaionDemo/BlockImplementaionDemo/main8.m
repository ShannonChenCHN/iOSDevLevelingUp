//
//  main8.c
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
        // 捕获 Objective-C  对象
        id array = [[NSMutableArray alloc] init];

        blk = ^void(id obj) {
            [array addObject:obj];
            
            NSLog(@"array count = %ld", [array count]);
        }; // 在 ARC 中这里并不需要手动 copy，在 MRR 中就需要手动 copy（p125）
    }
    
    
    blk([[NSObject alloc] init]);
    blk([[NSObject alloc] init]);
    blk([[NSObject alloc] init]);
    
    
    return 0;
}
