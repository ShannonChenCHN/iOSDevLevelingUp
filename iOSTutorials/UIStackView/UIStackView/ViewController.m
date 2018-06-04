//
//  ViewController.m
//  UIStackView
//
//  Created by ShannonChen on 2018/6/4.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIStackView *stackView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.stackView = [[UIStackView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 200)];
    _stackView.axis = UILayoutConstraintAxisHorizontal;     // 水平布局
    _stackView.distribution = UIStackViewDistributionFill; // 子空间等间距排列
    _stackView.alignment = UIStackViewAlignmentCenter;          // 居顶对齐
    _stackView.spacing = 50;
    [self.view addSubview:_stackView];
    
    // 官方文档：https://developer.apple.com/documentation/uikit/uistackview?changes=_6&language=objc
    // 如果要想实现 UIStackView 中的子空间间距不一致，该如何实现？https://stackoverflow.com/questions/32999159/how-can-i-create-uistackview-with-variable-spacing-between-views?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"Label %@", @(_stackView.subviews.count)];
    label.backgroundColor = [UIColor greenColor];
    label.textAlignment = NSTextAlignmentCenter;
    [_stackView addArrangedSubview:label];

}


@end
