//
//  Person.m
//  RuntimeDemo
//
//  Created by ShannonChen on 2018/3/7.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "Person.h"

@implementation Person


//- (BOOL)run {
//    return YES;
//}

- (BOOL)driveWithCar:(id)car {
    
    NSLog(@"%@ %@%@", self, NSStringFromSelector(_cmd), car);
    
    return (car != nil);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    if ([NSStringFromSelector(aSelector) isEqualToString:@"run"]) {
        NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"c24@0:8@16"];
        return signature;
    } else {
        return [super methodSignatureForSelector:aSelector];
    }
    
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
//    [self doesNotRecognizeSelector:anInvocation.selector];
    
    if ([NSStringFromSelector(anInvocation.selector) isEqualToString:@"run"]) {
        BOOL returnValue = YES;
        [anInvocation setReturnValue:&returnValue];
    }
    
}

@end
