//
//  MyProtocol.m
//  Test
//
//  Created by ShannonChen on 2018/2/7.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "MyProtocol.h"

static NSMutableArray <Class> *m_registeredClasses = nil;

@implementation MyProtocol

+ (void)registerClass:(Class)class {
    
    if (!m_registeredClasses) {
        m_registeredClasses = [NSMutableArray array];
    }
    
    [m_registeredClasses addObject:class];
    
}

+ (void)unregisterClass:(Class)class {
    [m_registeredClasses removeObject:class];
}

+ (NSArray *)registeredClasses {
    return m_registeredClasses;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return NO;
}

- (instancetype)initWithRequest:(NSURLRequest *)request {
    
    if ([self isMemberOfClass:[MyProtocol class]]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"必须子类化 MyProtocol " userInfo:nil];
    }
    
    return [super init];
}

@end
