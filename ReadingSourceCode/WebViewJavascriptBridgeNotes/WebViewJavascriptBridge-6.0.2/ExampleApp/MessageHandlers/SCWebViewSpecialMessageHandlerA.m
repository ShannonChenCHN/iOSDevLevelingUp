//
//  SCWebViewSpecialMessageHandlerA.m
//  ExampleApp
//
//  Created by ShannonChen on 2017/8/12.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "SCWebViewSpecialMessageHandlerA.h"
#import "SCWebViewController.h"

@implementation SCWebViewSpecialMessageHandlerA

- (NSArray *)specialHandlerNames {
    return @[
             @"makeACall"
             ];
}

- (void)makeACall:(NSDictionary *)args {
    [self.controller showAlertViewWithTitle:@"拨打电话" message:args[@"number"]];
}

@end
