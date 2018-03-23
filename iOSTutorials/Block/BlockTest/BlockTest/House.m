//
//  House.m
//  BlockTest
//
//  Created by ShannonChen on 2018/3/23.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "House.h"
#import "Person.h"

@interface House ()

@property (nonatomic, strong) Person *person;

@end

@implementation House

- (void)dealloc {
    
}


- (instancetype)init {
    self = [super init];
    if (self) {
        
        // self 持有 person
        _person = [Person new];
        __weak typeof(self) weakSelf = self;
        [_person setCallback:^(Person *person) {
            
            person.name = @"xxx";  // 但是这样就不会导致循环引用，因为这里是作为一个参数传进来的，不会捕获 self
//            _person.name = @"xxx"; // 这里会导致 block 持有 self，而 block 是 person 对象所持有的，这就导致了循环引用
//            weakSelf.name = @"xxx"; // 加 weak 也可以
        }];
        
    }
    return self;
}

@end
