//
//  ViewController.m
//  ExampleApp
//
//  Created by ShannonChen on 2017/7/30.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "WebViewJavascriptBridge.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) WebViewJavascriptBridge *bridge;

@end

@implementation ViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建 WebViewJavascriptBridge 对象
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    
    // 注册 handler
    [self registerHandlers];
    
    
}

- (IBAction)startLoading:(id)sender {
    // 加载网页
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WebViewTest" ofType:@"html"];
    NSString *HTMLString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:HTMLString baseURL:nil];
}

#pragma mark - Native <-> JavaScript

- (void)registerHandlers {
    
    // 获取位置信息
    [self.bridge registerHandler:@"requestLocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        // callback 回调
        responseCallback(@"上海市浦东新区张江高科");
    }];
    
    // 分享
    [self.bridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *shareContent = [NSString stringWithFormat:@"标题：%@\n 内容：%@ \n url：%@",
                                  data[@"title"],
                                  data[@"content"],
                                  data[@"url"]];
        [self showAlertViewWithTitle:@"调用原生分享菜单" message:shareContent];
    }];

}

- (IBAction)callJavaScript {
    
    // 原生调 JS
    [self.bridge callHandler:@"share" data:nil responseCallback:^(id responseData) {
        NSString *shareContent = [NSString stringWithFormat:@"标题：%@\n 内容：%@ \n url：%@",
                                  responseData[@"title"],
                                  responseData[@"content"],
                                  responseData[@"url"]];
        [self showAlertViewWithTitle:@"调用原生分享菜单" message:shareContent];
    }];
    
}

#pragma mark - Action

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}




@end
