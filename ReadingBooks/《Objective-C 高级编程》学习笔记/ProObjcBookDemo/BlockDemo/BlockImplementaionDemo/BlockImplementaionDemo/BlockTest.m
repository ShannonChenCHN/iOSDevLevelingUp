//
//  BlockTest.m
//  BlockImplementaionDemo
//
//  Created by ShannonChen on 2017/4/2.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "BlockTest.h"

@implementation BlockTest

- (id)getBlockArray {
    int val = 10;
    
    return [[NSArray alloc] initWithObjects:^{NSLog(@"blk0: %d", val);},
                                            ^{NSLog(@"blk1: %d", val);},  // 在 ARC 中这里并不需要手动 copy，在 MRR 中就需要手动 copy（p114）
                                            nil];
}

@end
