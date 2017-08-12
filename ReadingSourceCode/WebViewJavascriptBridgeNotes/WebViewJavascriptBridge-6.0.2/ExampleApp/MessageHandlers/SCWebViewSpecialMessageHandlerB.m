//
//  SCWebViewSpecialMessageHandlerB.m
//  ExampleApp
//
//  Created by ShannonChen on 2017/8/12.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "SCWebViewSpecialMessageHandlerB.h"
#import "SCWebViewController.h"

@implementation SCWebViewSpecialMessageHandlerB

- (NSArray *)specialHandlerNames {
    return @[
             @"pay"
             ];
}

- (void)pay:(NSDictionary *)args {
    NSString *paymentInfo = [NSString stringWithFormat:@"支付方式：%@\n价格：%@", args[@"type"], args[@"price"]];
    [self.controller showAlertViewWithTitle:@"去支付" message:paymentInfo];
}


@end
