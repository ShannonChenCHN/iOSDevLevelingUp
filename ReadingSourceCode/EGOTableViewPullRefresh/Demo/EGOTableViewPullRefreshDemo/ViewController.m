//
//  ViewController.m
//  EGOTableViewPullRefreshDemo
//
//  Created by ShannonChen on 17/4/18.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"
#import "PullTableView.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, PullTableViewDelegate>

@property (strong, nonatomic) PullTableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self refreshData];
    
    self.tableView = [[PullTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.insets = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.pullDelegate = self;
    self.tableView.loadMoreViewEnable = YES;
    self.tableView.refreshingViewEnable = YES;
    [self.view addSubview:self.tableView];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}


- (void)refreshData {
    [self.dataSource removeAllObjects];
    
    for (int i = 0; i < 10; i++) {
        [self.dataSource addObject:[NSNull null]];
    }
}

- (void)loadMoreData {
    for (int i = 0; i < 10; i++) {
        [self.dataSource addObject:[NSNull null]];
    }
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
/// number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/// row count for each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

/// cell configuration
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellReuseIdentifier = @"EGOPullTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%li-%li", indexPath.section, indexPath.row];
    
    return cell;
}

/// cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

/// cell selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark - <PullTableViewDelegate>
// 下拉刷新
- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshData];
        [self.tableView reloadData];
        
        self.tableView.pullTableIsRefreshing = NO;
        NSLog(@"------ %g, %g -------", self.tableView.contentInset.top, self.tableView.contentOffset.y);
    });
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadMoreData];
        [self.tableView reloadData];
        
        self.tableView.pullTableIsLoadingMore = NO;
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"====== %g, %g ========", self.tableView.contentInset.top, self.tableView.contentOffset.y);
}

@end
