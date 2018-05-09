//
//  ViewController.m
//  SCPatch
//
//  Created by ShannonChen on 2018/5/2.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "JSEngine.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [JSEngine evaluateJavaScriptString:@""];
}

+ (void)callObjC {
    NSLog(@"调用 ObjC");
}

@end
