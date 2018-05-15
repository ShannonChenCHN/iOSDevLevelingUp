//
//  TouchView.m
//  TouchEventExample
//
//  Created by ShannonChen on 2018/5/15.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

// 只要事件一传递给一个控件,这个控件就会调用他自己的hitTest：withEvent：方法
// 寻找并返回最合适的view(能够响应事件的那个最合适的view)
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

@end
