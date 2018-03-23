//
//  main.m
//  BlockTest
//
//  Created by ShannonChen on 2018/3/23.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "House.h"


void (^globalBlock)(void) = ^ { };

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        House *house = [[House alloc] init];
        
        
        void (^myBlock)(void) = ^ {
            
//            house = [[House alloc] init]; // 编译失败
            house.name = @"大房子"; // 可以编译通过，可以修改属性值
        };
        
        NSLog(@"%@, %@", myBlock, globalBlock);
    }
    return 0;
}
