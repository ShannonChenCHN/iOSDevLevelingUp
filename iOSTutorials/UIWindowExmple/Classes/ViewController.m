//
//  ViewController.m
//  Test
//
//  Created by ShannonChen on 2018/6/6.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "DebugWindow.h"
#import "DebugViewController.h"

@interface ViewController ()


@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    
    
}

- (IBAction)toggleDebubWindow:(id)sender {
    static UIWindow *window = nil;
    if (!window) {
        window = [[DebugWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.rootViewController = [DebugViewController new];
        
        window.hidden = NO; // We need to make window visible by set its `hidden` property to NO.
    }
    
//    window.hidden = !(window.hidden); // We need to make window visible by set its `hidden` property to NO.
    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
}

@end
