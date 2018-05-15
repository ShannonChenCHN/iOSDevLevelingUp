//
//  ViewController.m
//  TouchEventExample
//
//  Created by ShannonChen on 2018/5/15.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"

/*
 
 参考：https://www.jianshu.com/p/2e074db792ba
 
 事件传递：
 当一个事件发生后，事件会从父控件传给子控件，也就是说由 Runloop source0 -> UIKit __handleEventQueueInternal -> UIWindow -> UIView -> initial view，以上就是事件的传递，也就是寻找最合适的view的过程。
 
 
 事件响应：
 首先看initial view能否处理这个事件，如果不能则会将事件传递给其上级视图（inital view的superView）；如果上级视图仍然无法处理则会继续往上传递；一直传递到视图控制器view controller，首先判断视图控制器的根视图view是否能处理此事件；如果不能则接着判断该视图控制器能否处理此事件，如果还是不能则继续向上传 递；（对于第二个图视图控制器本身还在另一个视图控制器中，则继续交给父视图控制器的根视图，如果根视图不能处理则交给父视图控制器处理）；一直到 window，如果window还是不能处理此事件则继续交给application处理，如果最后application还是不能处理此事件则将其丢弃
 
 Runloop source0 -> UIApplication sendEvent -> UIWindow sendEvent -> initial view
 
 如果 initial view 不能处理 -> 传给 next responder，superview 或者 controller -> UIWindow ->
UIApplication
 */

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}



@end
