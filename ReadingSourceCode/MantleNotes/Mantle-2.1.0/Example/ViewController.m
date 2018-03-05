//
//  ViewController.m
//  Example
//
//  Created by ShannonChen on 2017/9/20.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "GHIssue.h"
#import "NSJSONSerialization+Nonnull.h"
#import "UIImageView+downloader.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 读取数据
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    
    // JSON 序列化
    NSError *serializationError = nil;
    NSDictionary *jsonKeyValues = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL removingNulls:YES ignoreArrays:NO];
    if (serializationError) {
        NSLog(@"serialization error: %@", serializationError);
    }
    
    // JSON 解析
    NSError *modelError = nil;
    GHIssue *issue = [MTLJSONAdapter modelOfClass:[GHIssue class] fromJSONDictionary:jsonKeyValues error:&modelError];
    if (modelError) {
        NSLog(@"model: error: %@", modelError);
    }
    
    NSDictionary *JSONDictionary = [MTLJSONAdapter JSONDictionaryFromModel:issue error:nil];
    
    // 更新界面
    self.nameLabel.text = issue.assignee.name;
    [self.avatar setImageWithURL:issue.assignee.avatarURL];
    
}


@end
