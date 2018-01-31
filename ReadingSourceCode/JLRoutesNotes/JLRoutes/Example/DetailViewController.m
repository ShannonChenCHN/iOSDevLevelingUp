//
//  DetailViewController.m
//  Example
//
//  Created by ShannonChen on 2018/1/30.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <JLRRouteHandlerTarget>

@end

@implementation DetailViewController

- (instancetype)initWithRouteParameters:(NSDictionary<NSString *,id> *)parameters {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        
        NSString *title = parameters[@"title"];
        NSString *pageId = parameters[@"id"];
        
        self.title = [title stringByAppendingString:pageId];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}



@end
