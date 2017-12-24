//
//  ViewController.m
//  RunloopExample
//
//  Created by ShannonChen on 2017/12/23.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self performSelector:@selector(print:) withObject:@"哈哈" afterDelay:2];
        CFRunLoopRun();
    });
    
}

- (void)print:(NSString *)args {
    CFRunLoopStop(CFRunLoopGetCurrent());
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

//- (void)handleCrash {
//    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
//    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
//    while (!isQuit){
//        for (NSString *mode in (__bridge NSArray *)allModes) {
//            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
//        }
//    }
//    CFRelease(allModes);
//}


@end
