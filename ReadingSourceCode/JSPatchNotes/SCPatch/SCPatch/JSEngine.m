//
//  JSEngine.m
//  SCPatch
//
//  Created by ShannonChen on 2018/5/2.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "JSEngine.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>


static JSContext *_context;
static NSString *_regexStr = @"(?<!\\\\)\\.\\s*(\\w+)\\s*\\(";
static NSString *_replaceStr = @".__call(\"$1\")(";
static NSRegularExpression* _regex;

@implementation JSEngine

/*
 几个主要的问题：
 
 1. JS 怎么跟 Objective-C 通信？
 
 JavaScriptCore
 
 2. JS 如何调用 Objective-C 中已经定义好的方法？比如调用 UIColor 的 redColor 方法。
 ```
 UIColor.redColor();
 ```
 
 简单概括，就是拿到类或者对象，以及方法名用运行时进行调用。

 
 2.1 调用实例方法怎么拿到对象？
 
 2.2
 
 3. JS 中如何修改 Objective-C 类中的方法？
 
 4. JS 中如何给 Objective-C 类添加方法？
 
 5. JS 中如何定义一个新类？
 
 6. self 和 super 的实现
 
 */


+ (void)start {
    
    if (!_context) {
        _context = [[JSContext alloc] init];
        
        _context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
            NSLog(@"JS Error: %@", exception);
        };
        
        _context[@"logInXcode"] = ^(id obj) {
            NSLog(@"%@", obj);
        };
        
        // 1. 调用 Objective-C 的方法
        _context[@"callObjCMethod"] = ^id(NSString *clsName, id obj, NSString *selectorName, NSArray *args) {
            Class cls = NSClassFromString(clsName);
            
            if (args.count) {
                selectorName = [selectorName stringByAppendingString:@":"];
            }
            SEL selector = NSSelectorFromString(selectorName);
            
            id caller = obj ? : cls;
            if (caller && selector) {
                id result = [caller performSelector:selector withObject:args.count ? args.firstObject[@"object"] : nil];
                if (result) {
                    return result;
                } else {
                    return nil;
                }
            }
            return nil;
        };
        
        
        // 3.
        
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"JSPatch" ofType:@"js"];
        NSString *jsString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        [_context evaluateScript:jsString];
    }
    
}



+ (void)evaluateJavaScriptString:(NSString *)string {
    
    [JSEngine start];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Example" ofType:@"js"];
    NSString *jsString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    if (jsString) {
        
        if (!_regex) {
            _regex = [NSRegularExpression regularExpressionWithPattern:_regexStr options:0 error:nil];
        }
        NSString *formatedScript = [_regex stringByReplacingMatchesInString:jsString options:0 range:NSMakeRange(0, jsString.length) withTemplate:_replaceStr];
        
        [_context evaluateScript:formatedScript];
    }
    
}

@end
