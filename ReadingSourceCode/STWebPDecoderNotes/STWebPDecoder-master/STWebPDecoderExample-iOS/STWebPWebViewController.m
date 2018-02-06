//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STWebPWebViewController.h"


@interface STWebPWebViewController ()
@property (nonatomic,weak) UIWebView *webView;
@end


@implementation STWebPWebViewController

+ (instancetype)viewController {
	return [[self alloc] initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
	}
	return self;
}

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:(CGRect){ .size = { .width = 768, .height = 1004 } }];
	UIView * const view = self.view;
	CGRect const bounds = view.bounds;

	UIWebView *webView = [[UIWebView alloc] initWithFrame:bounds];
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.webView = webView;
	[view addSubview:webView];
}

- (void)viewDidLoad {
	[super viewDidLoad];

//	double delayInSeconds = 2.0;
//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self.webView loadHTMLString:@"<img src=\"https://www.gstatic.com/webp/gallery3/2_webp_ll.webp\">" baseURL:nil];
//	});
}

@end
