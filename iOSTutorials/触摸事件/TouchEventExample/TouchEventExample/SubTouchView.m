//
//  SubTouchView.m
//  TouchEventExample
//
//  Created by ShannonChen on 2018/5/15.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "SubTouchView.h"

@implementation SubTouchView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

@end
