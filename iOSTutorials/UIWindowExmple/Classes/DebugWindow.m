//
//  DebugWindow.m
//  UIWindowExmple
//
//  Created by ShannonChen on 2018/6/8.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "DebugWindow.h"


@interface DebugWindow ()

@property (nonatomic, strong) UIView *touchView;

@end

@implementation DebugWindow

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        
        // Some apps have windows at UIWindowLevelStatusBar + n.
        // If we make the window level too high, we block out UIAlertViews.
        // There's a balance between staying above the app's windows and staying below alerts.
        // UIWindowLevelStatusBar + 100 seems to hit that balance.
        self.windowLevel = UIWindowLevelStatusBar + 100.0;
        
        
        [self addSubview:self.touchView];
        
    }
    return self;
}

- (UIView *)touchView {
    if (!_touchView) {
        CGFloat touchRadius = 10;
        self.touchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, touchRadius * 2, touchRadius * 2)];
        _touchView.backgroundColor = [UIColor redColor];
        _touchView.layer.cornerRadius = touchRadius;
        _touchView.layer.masksToBounds = YES;
    }
    
    return _touchView;
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
//}
//
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    return [super hitTest:point withEvent:event];
//}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    _touchView.center = point;
    [self bringSubviewToFront:_touchView];
    
    return NO;
}

@end
