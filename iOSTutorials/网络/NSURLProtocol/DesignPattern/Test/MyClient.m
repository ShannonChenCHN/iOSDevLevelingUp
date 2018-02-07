//
//  MyClient.m
//  Test
//
//  Created by ShannonChen on 2018/2/7.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "MyClient.h"
#import "MyProtocol.h"

@implementation MyClient

- (void)start {
    
    // 加载拦截器
    for (Class protocolClass in [MyProtocol registeredClasses]) {
        if ([protocolClass canInitWithRequest:nil]) {
            id aProtocolObj = [[protocolClass alloc] initWithRequest:nil];
        }
    }
    
    
}

@end
