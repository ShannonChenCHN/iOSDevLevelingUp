//
//  SCTableViewController.m
//  ExampleApp
//
//  Created by ShannonChen on 2017/8/11.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "SCTableViewController.h"
#import "SCWebViewController.h"
#import "SCWebViewMessageHandler.h"
#import "SCWebViewSpecialMessageHandlerA.h"
#import "SCWebViewSpecialMessageHandlerB.h"

@interface SCTableViewController ()

@end

@implementation SCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *fileName = [NSString stringWithFormat:@"WebViewTest_0%li", indexPath.row + 1];
    NSDictionary *messageHandlerClasses = @{
                                            [NSIndexPath indexPathForRow:0 inSection:0] : [SCWebViewMessageHandler class],
                                            [NSIndexPath indexPathForRow:1 inSection:0] : [SCWebViewSpecialMessageHandlerA class],
                                            [NSIndexPath indexPathForRow:2 inSection:0] : [SCWebViewSpecialMessageHandlerB class],
                                            };

    SCWebViewController *controller = [[SCWebViewController alloc] initWithHTMLFileName:fileName messageHandlerClass:messageHandlerClasses[indexPath]];
    controller.title = [NSString stringWithFormat:@"Example_0%li", indexPath.row + 1];
    [self.navigationController pushViewController:controller animated:YES];
}


@end
