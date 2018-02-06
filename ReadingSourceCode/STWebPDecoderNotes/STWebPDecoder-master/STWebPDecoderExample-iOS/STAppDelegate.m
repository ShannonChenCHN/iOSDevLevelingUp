//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STAppDelegate.h"

#import "STWebPViewController.h"
#import "STWebPWebViewController.h"

#import "STWebPURLProtocol.h"


@implementation STAppDelegate

- (void)setWindow:(UIWindow *)window {
	_window = window;
	[_window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication * __unused)application didFinishLaunchingWithOptions:(NSDictionary * __unused)launchOptions {
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.backgroundColor = [UIColor blackColor];

	[STWebPURLProtocol registerWithOptions:@{ STWebPURLProtocolOptionClaimWebPExtension: @YES }];

	STWebPWebViewController *viewController = [STWebPWebViewController viewController];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	window.rootViewController = navController;

	self.window = window;

	return YES;
}

@end
