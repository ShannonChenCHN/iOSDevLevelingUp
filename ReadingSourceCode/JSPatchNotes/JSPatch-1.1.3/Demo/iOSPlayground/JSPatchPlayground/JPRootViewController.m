//
//  ViewController.m
//  JSPatchPlayground
//
//  Created by bang on 5/14/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "JPRootViewController.h"
#import "JPEngine.h"
#import "SGDirWatchdog.h"
#import "JPCleaner.h"
#import "JPErrorMsgViewController.h"

@interface JPRootViewController ()
@property (nonatomic) NSMutableArray *watchDogs;
@property (nonatomic) UIWindow *errorWindow;
@property (nonatomic) NSString *errMsg;
@end

@implementation JPRootViewController

+ (void)request:(void(^)(NSString *content, BOOL success))callback {
    callback(@"I'm content", YES);
}

typedef void (^JSBlock)(NSDictionary *dict);
+ (JSBlock)genBlock {
    NSString *ctn = @"JSPatch";
    JSBlock block = ^(NSDictionary *dict) {
        NSLog(@"I'm %@, version: %@", ctn, dict[@"v"]);
    };
    return block;
}

- (void)callBlock:(void(^)(void))block {
    block();
}

- (void)doSomething {
    NSLog(@"My boyfriend is gay!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
#if TARGET_IPHONE_SIMULATOR
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"projectPath"];
#else
    NSString *rootPath = [[NSBundle mainBundle] bundlePath];
#endif
    
    [JPEngine handleException:^(NSString *msg) {
        if (!self.errorWindow) {
            self.errorWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
            self.errorWindow.windowLevel = UIWindowLevelStatusBar + 1.0f;
            self.errorWindow.backgroundColor = [UIColor blackColor];
            UIButton *errBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, [UIScreen mainScreen].bounds.size.width - 10, 20)];
            errBtn.titleLabel.font = [UIFont systemFontOfSize:10];
            [errBtn setTitle:msg forState:UIControlStateNormal];
            [errBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            errBtn.tag = 100;
            [errBtn addTarget:self action:@selector(handleTapErrorBtn) forControlEvents:UIControlEventTouchDown];
            [self.errorWindow addSubview:errBtn];
            [self.errorWindow makeKeyAndVisible];
        } else {
            UIButton *errBtn = [self.errorWindow viewWithTag:100];
            [errBtn setTitle:msg forState:UIControlStateNormal];
        }
        self.errMsg = msg;
        
        self.errorWindow.hidden = NO;
    }];
    
    // 执行 main.js 中的脚本
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"src"];
    NSString *mainScriptPath = [NSString stringWithFormat:@"%@/%@", scriptRootPath, @"/main.js"];
    [JPEngine evaluateScriptWithPath:mainScriptPath];
    
    
    self.watchDogs = [[NSMutableArray alloc] init];
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:scriptRootPath error:NULL];
    [self watchFolder:scriptRootPath mainScriptPath:mainScriptPath];
    for (NSString *aPath in contentOfFolder) {
        NSString * fullPath = [scriptRootPath stringByAppendingPathComponent:aPath];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) {
            [self watchFolder:fullPath mainScriptPath:mainScriptPath];
        }
    }
    [self showController];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 50)];
    [btn setTitle:@"Push Playground" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showController) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:btn];
}

- (void)handleTapErrorBtn
{
    JPErrorMsgViewController *errorMsgVC = [[JPErrorMsgViewController alloc] initWithMsg:self.errMsg];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:errorMsgVC];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)watchFolder:(NSString *)folderPath mainScriptPath:(NSString *)mainScriptPath
{
    SGDirWatchdog *watchDog = [[SGDirWatchdog alloc] initWithPath:folderPath update:^{
        self.errorWindow.hidden = YES;
        [JPCleaner cleanAll];
        [JPEngine evaluateScriptWithPath:mainScriptPath];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self showController];
    }];
    [watchDog start];
    [self.watchDogs addObject:watchDog];
}

- (void)showController
{
    //override in JSPatch
}


@end
