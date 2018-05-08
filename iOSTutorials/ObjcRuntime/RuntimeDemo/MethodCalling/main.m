//
//  main.m
//  MethodCalling
//
//  Created by ShannonChen on 2018/5/4.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

// 通过调用函数指针的方式调用方法
void callMethodThroughFuntionPointer() {
    Person *person = [[Person alloc] init];
    
    SEL selector = @selector(driveWithCar:);
    IMP imp = [person methodForSelector:selector];
    
    BOOL (*drive)(id, SEL, id) = (__typeof__(drive))imp;
    drive(person, selector, @"car");
    //        objc_msgSend(person, selector, @"car");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        callMethodThroughFuntionPointer();
        
    }
    return 0;
}
