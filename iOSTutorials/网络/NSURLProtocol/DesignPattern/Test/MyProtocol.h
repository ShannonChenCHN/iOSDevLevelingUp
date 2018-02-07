//
//  MyProtocol.h
//  Test
//
//  Created by ShannonChen on 2018/2/7.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyProtocol;


/*
 *  protocol 抽象类
 */
@interface MyProtocol : NSObject

+ (void)registerClass:(Class)class;
+ (void)unregisterClass:(Class)class;

+ (NSArray *)registeredClasses;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request;

- (instancetype)initWithRequest:(NSURLRequest *)request;

@end
