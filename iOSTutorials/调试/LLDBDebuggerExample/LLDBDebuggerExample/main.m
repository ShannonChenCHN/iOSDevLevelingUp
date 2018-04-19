//
//  main.m
//  LLDBDebuggerExample
//
//  Created by ShannonChen on 2018/4/17.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

static BOOL isEven(int i) {
    if (i % 2 == 0) {
        NSLog(@"%d is even!", i);
        return YES;
    }
    
    NSLog(@"%d is odd!", i);
    return NO;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSUInteger count = 99;
        NSString *objects = @"red balloons";
        NSArray *array = @[@"a", @"b"];
        
        int i = 99;
        BOOL even0 = isEven(i + 1);
        BOOL even1 = isEven(i + 2);
        
        NSLog(@"%lu %@.", count, objects);
        
    }
    return 0;
}
