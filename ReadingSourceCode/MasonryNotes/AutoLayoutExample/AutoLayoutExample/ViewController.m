//
//  ViewController.m
//  AutoLayoutExample
//
//  Created by ShannonChen on 2017/11/8.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    /*
     // http://www.vienta.me/2014/12/07/AutoLayout-%E5%BF%98%E6%8E%89Frame-%E6%8B%A5%E6%8A%B1Constraint%EF%BC%88I%EF%BC%89/
     // https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/ProgrammaticallyCreatingConstraints.html#//apple_ref/doc/uid/TP40010853-CH16-SW1
     // https://www.zybuluo.com/MicroCai/note/73867#autolayout-基础
     1. xib 和 storyboard 中的 constraint 也是可以成为 property 的
     
     2. 使用 autolayout 时，一定要设置 view.translatesAutoresizingMaskIntoConstraints = NO;
     
     3. 约束的种类：
         Leading Space to: Superview 相对父视图保持左对齐
         Trailling Space to: Superview 相对父视图保持右对齐
         Top Space to: SuperView 相对父视图顶部对齐
         Bottom Space to: SupderView 相对父视图底部对齐
         Width: 自身约束宽
         Height: 自身约束高
         Width Equally: view   和参考的view等宽
         Height Equally: view  和参考的view等高
         Baseline: view 和参考的view在同一水平线
         Horizontal Space: view 和参考的view保持水平距离
         Vertical Space: view 和参考的view保持垂直距离
         Aspect Ratio: 设置 View 自身宽高比例
     
     4. UIKit 的一些控件如 UILabel、UIImageView 等有自适应特性，会根据内容自适应尺寸，所以可以不约束其宽高。
     
     5. 同样的约束用在 UIScrollView 和 UIImageViwe 上，为什么会出现错误？
     */
    
    UIView *superview = self.view;
    
    UIView *view1 = [[UIView alloc] init];
    view1.translatesAutoresizingMaskIntoConstraints = NO;  // 防止与 autosize 冲突，一定要写，否则不能正常进行
    view1.backgroundColor = [UIColor greenColor];
    [superview addSubview:view1];
    
    UIView *view2 = [[UIView alloc] init];
    view2.translatesAutoresizingMaskIntoConstraints = NO;
    view2.backgroundColor = [UIColor orangeColor];
    [superview addSubview:view2];
    
    CGFloat view1Height = 100;
    CGFloat view1PaddingTop = 10;
    CGFloat view1PaddingLeftRight = 10;
    
    // 一个 NSLayoutConstraint 类代表一个约束
    
    // constraintWithItem: 方法创建约束
    NSArray *constraintsForView1 = @[
                                
                                //view1 constraints
                                [NSLayoutConstraint constraintWithItem:view1
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superview
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:view1PaddingTop],
                                
                                [NSLayoutConstraint constraintWithItem:view1
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superview
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:view1PaddingLeftRight],
                                
                                
                                [NSLayoutConstraint constraintWithItem:view1
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superview
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:-view1PaddingLeftRight],
                                
                                [NSLayoutConstraint constraintWithItem:view1
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:view1Height],
                                
                                ];
    
    [superview addConstraints:constraintsForView1];
    
    // 通过 VFL 写约束
    CGFloat view2PaddingTop = 300;
    CGFloat view2PaddingLeftRight = 10;
    CGFloat view2Height = 100;
    
    NSString *horizontalVFL = [NSString stringWithFormat:@"H:|-%@-[view2]-%@-|", @(view2PaddingLeftRight), @(view2PaddingLeftRight)];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:horizontalVFL
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(view2)];
    
    NSString *verticalVFL = [NSString stringWithFormat:@"V:|-%@-[view2(==%@)]", @(view2PaddingTop), @(view2Height)];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalVFL
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(view2)];
    
    [superview addConstraints:horizontalConstraints];
    [superview addConstraints:verticalConstraints];
    
}


@end
