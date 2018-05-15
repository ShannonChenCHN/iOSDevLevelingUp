//
//  GreenView.m
//  TouchEventExample
//
//  Created by ShannonChen on 2018/5/15.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "GreenView.h"

@implementation GreenView

// 处理事件的方法
// 如果这个方法没有被实现或者直接调用 super，也就是说这个 view 不能处理触摸事件，系统会将事件传递给响应者链条的下一级
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

@end
