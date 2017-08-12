//
//  SCWebViewMessageHandler.h
//  ExampleApp
//
//  Created by ShannonChen on 2017/8/12.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"

@class SCWebViewController;

@interface SCWebViewMessageHandler : NSObject


@property (weak, nonatomic) SCWebViewController *controller;

/// 注册 handler
- (void)registerHandlersForJSBridge:(WebViewJavascriptBridge *)bridge;


/// 要注册的特定 handler name，子类重写
- (NSArray *)specialHandlerNames;


@end
