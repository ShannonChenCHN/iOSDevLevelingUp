//
//  MyCustomProtocol.m
//  Test
//
//  Created by ShannonChen on 2018/2/7.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "MyCustomProtocol.h"

@implementation MyCustomProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return YES;
}

- (instancetype)initWithRequest:(NSURLRequest *)request {
    return [super init];
}

@end
