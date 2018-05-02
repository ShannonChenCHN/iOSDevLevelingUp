//
//  ViewController.m
//  Example
//
//  Created by ShannonChen on 2018/5/2.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Person.h"

static JSContext *_context;

@interface ViewController ()

@end

@implementation ViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    

    _context = [[JSContext alloc] init];
    
    
    // 异常处理
    _context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"JS Error: %@", exception);
    };
    
//    [self runExample_1];
    [self runExample_2];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.navigationController pushViewController:[ViewController new] animated:YES];
    });
    
}


- (void)runExample_2 {
    
    // export Person class
    _context[@"Person"] = [Person class];
    
    [_context evaluateScript:@"\
     var loadPeopleFromJSON = function(jsonString) {\
     var data = JSON.parse(jsonString);\
     var people = [];\
     for (i = 0; i < data.length; i++) {\
         var person = Person.createWithFirstNameLastName(data[i].first, data[i].last);\
         person.birthYear = data[i].year;\
         people.push(person);\
     }\
     return people;\
     }"];
    
    // get JSON string
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"People" ofType:@"json"];
    NSString *peopleJSON = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // get load function
    JSValue *load = _context[@"loadPeopleFromJSON"];
    
    // call with JSON and convert to an NSArray
    JSValue *loadResult = [load callWithArguments:@[peopleJSON]];
    NSArray *people = [loadResult toArray];
    
    // loop through people and render Person object as string
    for (Person *person in people) {
        NSLog(@"%@", [person getFullName]);
    }

    
}

- (void)runExample_1 {
    /* Objective-C 调用 JavaScript */
    
    // 执行 JS 脚本
    [_context evaluateScript:@"var num = 5 + 5"];
    [_context evaluateScript:@"var names = ['Grace', 'Ada', 'Margaret']"];
    [_context evaluateScript:@"var triple = function(value) { return value * 3 }"];
    JSValue *tripleNum = [_context evaluateScript:@"triple(num)"];
    NSLog(@"Tripled: %d", [tripleNum toInt32]);
    
    // 下标访问
    JSValue *names = _context[@"names"];
    JSValue *initialName = names[0];
    NSLog(@"The first name: %@", [initialName toString]);
    
    // 调用 JS 函数
    JSValue *tripleFunction = _context[@"triple"];
    JSValue *result = [tripleFunction callWithArguments:@[@5] ];
    NSLog(@"Five tripled: %d", [result toInt32]);
    
    
    /*  JavaScript 调用 Objective-C */
    
    // 方式一：通过 block 的方式定义 JS 函数
    __weak typeof(self) weakSelf = self;
    _context[@"alert"] = ^(NSString *input) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:input message:weakSelf.title delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alertView show];
        
        return input;
    };
    
    NSLog(@"%@", [_context evaluateScript:@"alert('안녕하새요!')"]);
}


@end
