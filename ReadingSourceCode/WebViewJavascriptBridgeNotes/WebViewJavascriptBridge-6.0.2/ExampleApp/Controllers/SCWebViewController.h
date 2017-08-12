//
//  SCWebViewController.h
//  ExampleApp
//
//  Created by ShannonChen on 2017/7/30.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCWebViewController : UIViewController

- (instancetype)initWithHTMLFileName:(NSString *)fileName messageHandlerClass:(Class)messageHandlerClass;

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;

@end

