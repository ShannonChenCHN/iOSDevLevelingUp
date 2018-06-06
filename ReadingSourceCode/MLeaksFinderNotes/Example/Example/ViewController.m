//
//  ViewController.m
//  Example
//
//  Created by ShannonChen on 2018/5/25.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, copy) void (^block)(void);
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation ViewController

- (void)dealloc {
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.data = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.block = ^{
        for (int i = 0; i < 10000; i++) {
            [self.data addObject:[UIImage imageNamed:@"chao"]];  // 这里会导致内存泄漏
        }
    };
    
    self.block();
}

- (IBAction)push:(id)sender {
    
    ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(ViewController.class)];
;
    vc.title = [NSString stringWithFormat:@"%@", @(self.navigationController.viewControllers.count)];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
