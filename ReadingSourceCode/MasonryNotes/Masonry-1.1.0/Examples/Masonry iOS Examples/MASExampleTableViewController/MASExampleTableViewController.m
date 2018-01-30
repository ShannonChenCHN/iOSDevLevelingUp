//
//  MASExampleTableViewController.m
//  Masonry iOS Examples
//
//  Created by ShannonChen on 2018/1/30.
//  Copyright © 2018年 Jonas Budelmann. All rights reserved.
//

#import "MASExampleTableViewController.h"
#import "MASTextTableViewCell.h"

@interface MASExampleTableViewController ()

@property (nonatomic, strong) NSMutableArray <NSString *> *data;

@end

@implementation MASExampleTableViewController

static NSString *kMASTextTableViewCellId = @"MASTextTableViewCell";

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    self.title = @"iOS 8 Self-Sizing Cells";
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    [self.tableView registerClass:[MASTextTableViewCell class]
           forCellReuseIdentifier:kMASTextTableViewCellId];
    
    // 生成数据
    NSString *string = @"Masonry is a light-weight layout framework which wraps AutoLayout with a nicer syntax.";
    _data = [NSMutableArray new];
    
    for (NSInteger i = 0; i < 20; i++) {
        [_data addObject:[string substringToIndex:arc4random_uniform((uint32_t)string.length)]];
    }
    
    // 刷新
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MASTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMASTextTableViewCellId forIndexPath:indexPath];
    [cell configWithText:_data[indexPath.row]];
    return cell;
}



@end
