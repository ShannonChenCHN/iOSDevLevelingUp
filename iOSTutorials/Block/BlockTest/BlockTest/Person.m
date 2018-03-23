//
//  Person.m
//  BlockTest
//
//  Created by ShannonChen on 2018/3/23.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "Person.h"

@interface Person ()

@property (nonatomic, copy) void (^callback)(Person *aPerson);

@end

@implementation Person

- (void)dealloc {
    
}

@end
