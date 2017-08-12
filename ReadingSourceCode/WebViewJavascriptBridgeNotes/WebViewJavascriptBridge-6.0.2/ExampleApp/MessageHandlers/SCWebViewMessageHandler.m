//
//  SCWebViewMessageHandler.m
//  ExampleApp
//
//  Created by ShannonChen on 2017/8/12.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "SCWebViewMessageHandler.h"
#import "SCWebViewController.h"

@implementation SCWebViewMessageHandler

- (void)registerHandlersForJSBridge:(WebViewJavascriptBridge *)bridge {
    
    NSMutableArray *handlerNames = @[@"requestLocation", @"share"].mutableCopy;

    [handlerNames addObjectsFromArray:[self specialHandlerNames]];
    
    for (NSString *aHandlerName in handlerNames) {
        [bridge registerHandler:aHandlerName handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSMutableDictionary *args = [NSMutableDictionary dictionary];
            
            if ([data isKindOfClass:[NSDictionary class]]) {
                [args addEntriesFromDictionary:data];
            }
            
            if (responseCallback) {
                [args setObject:responseCallback forKey:@"responseCallback"];
            }
            
            
            NSString *ObjCMethodName = [aHandlerName stringByAppendingString:@":"];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:NSSelectorFromString(ObjCMethodName) withObject:args];
#pragma clang diagnostic pop
            
        }];
    }
}

- (NSArray *)specialHandlerNames {
    return @[];
}


#pragma mark - Handler Methods

// 获取地理位置信息
- (void)requestLocation:(NSDictionary *)args {
    WVJBResponseCallback responseCallback = args[@"responseCallback"];
    
    if (responseCallback) {
        
        responseCallback(@"上海市浦东新区张江高科");
    }
}

// 分享
- (void)share:(NSDictionary *)args {
    
    NSString *shareContent = [NSString stringWithFormat:@"标题：%@\n 内容：%@ \n url：%@",
                              args[@"title"],
                              args[@"content"],
                              args[@"url"]];
    [self.controller showAlertViewWithTitle:@"调用原生分享菜单" message:shareContent];
}




@end
