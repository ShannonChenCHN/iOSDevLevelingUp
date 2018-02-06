//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STWebPViewController.h"

#import "STWebPDecoder.h"

#include <mach/mach_time.h>


//static void CGDataProviderReleaseDataCallbackFree(void *info, const void *data, size_t size);


@interface STWebPViewController ()
@property (nonatomic,weak) UIImageView *imageView;
@end


@implementation STWebPViewController

+ (instancetype)viewController {
	return [[self alloc] initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
	}
	return self;
}


- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:(CGRect){ .size = { .width = 768, .height = 968 } }];
	UIView * const view = self.view;
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	view.backgroundColor = [UIColor whiteColor];

	UIImageView * const imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	imageView.contentMode = UIViewContentModeCenter;
	[view addSubview:imageView];
	self.imageView = imageView;
}


- (void)viewDidLoad {
	[super viewDidLoad];

	mach_timebase_info_data_t timebaseInfo = { };
	(void)mach_timebase_info(&timebaseInfo);

//	@autoreleasepool {
//		uint64_t const start = mach_absolute_time();
//
//		for (int i = 0; i < 100; ++i) @autoreleasepool {
//			NSString * const webpPath = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"webp"];
//			NSData * const webpData = [NSData dataWithContentsOfFile:webpPath options:NSDataReadingMappedIfSafe error:NULL];
//
//			int bitmapWidth = 0, bitmapHeight = 0;
//			uint8_t *bitmapData = WebPDecodeBGRA(webpData.bytes, webpData.length, &bitmapWidth, &bitmapHeight);
//			if (!bitmapData) {
//				return;
//			}
//
//			CGDataProviderRef bitmapDataProvider = CGDataProviderCreateWithData(NULL, bitmapData, bitmapWidth * bitmapHeight, CGDataProviderReleaseDataCallbackFree);
//
//			CGColorSpaceRef drgb = CGColorSpaceCreateDeviceRGB();
//			CGBitmapInfo const bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
//			CGImageRef bitmap = CGImageCreate(bitmapWidth, bitmapHeight, 8, 32, bitmapWidth*4, drgb, bitmapInfo, bitmapDataProvider, NULL, YES, kCGRenderingIntentDefault);
//			CFRelease(drgb);
//
//			UIImage *image = [[UIImage alloc] initWithCGImage:bitmap scale:1 orientation:UIImageOrientationUp];
//			CFRelease(bitmap);
//			(void)image;
//		}
//		uint64_t const end = mach_absolute_time();
//		NSLog(@"webp elapsed:  %lluns", ((end - start) * timebaseInfo.numer / timebaseInfo.denom) / 100);
//	}

//	@autoreleasepool {
//		uint64_t const start = mach_absolute_time();
//
//		NSString * const webpPath = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"webp"];
//		NSData * const webpData = [[NSData alloc] initWithContentsOfFile:webpPath options:NSDataReadingMappedIfSafe error:NULL];
//
//		for (int i = 0; i < 100; ++i) @autoreleasepool {
//
//			UIImage * const image = [STWebPDecoder imageWithData:webpData scale:1 error:NULL];
//			(void)image;
//		}
//		uint64_t const end = mach_absolute_time();
//		NSLog(@"webp elapsed:  %lluns", ((end - start) * timebaseInfo.numer / timebaseInfo.denom) / 100);
//	}
//
//
//	@autoreleasepool {
//		uint64_t const start = mach_absolute_time();
//		for (int i = 0; i < 100; ++i) @autoreleasepool {
//			NSString * const inputPath = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"jpg"];
//			NSData * const inputData = [NSData dataWithContentsOfFile:inputPath options:NSDataReadingMappedIfSafe error:NULL];
//
//			CGDataProviderRef bitmapDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inputData);
//
//			CGImageRef bitmap = CGImageCreateWithJPEGDataProvider(bitmapDataProvider, NULL, YES, kCGRenderingIntentDefault);
//
//			UIImage *image = [[UIImage alloc] initWithCGImage:bitmap scale:1 orientation:UIImageOrientationUp];
//			CFRelease(bitmap);
//			CGDataProviderRelease(bitmapDataProvider);
//			(void)image;
//		}
//		uint64_t const end = mach_absolute_time();
//		NSLog(@"jpeg elapsed:  %lluns", ((end - start) * timebaseInfo.numer / timebaseInfo.denom) / 100);
//	}
//
//	@autoreleasepool {
//		uint64_t const start = mach_absolute_time();
//		for (int i = 0; i < 100; ++i) @autoreleasepool {
//			NSString * const webpPath = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"jpg"];
//			UIImage *image = [[UIImage alloc] initWithContentsOfFile:webpPath];
//			(void)image;
//		}
//		uint64_t const end = mach_absolute_time();
//		NSLog(@"jpegi elapsed: %lluns", ((end - start) * timebaseInfo.numer / timebaseInfo.denom) / 100);
//	}

	NSString * const webpPath = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"webp"];
	NSData * const webpData = [[NSData alloc] initWithContentsOfFile:webpPath options:NSDataReadingMappedIfSafe error:NULL];
	self.imageView.image = [STWebPDecoder imageWithData:webpData scale:2 error:NULL];
//	self.imageView.image = nil;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	UIView * const view = self.view;
	CGRect const bounds = view.bounds;
	CGSize const boundsSize = bounds.size;

	UIImageView * const imageView = self.imageView;
	UIImage * const imageViewImage = imageView.image;
	CGSize const imageViewImageSize = imageViewImage ? imageViewImage.size : (CGSize){ 0, 0 };

	CGRect const imageViewFrame = (CGRect){
		.origin = {
			.x = (boundsSize.width - imageViewImageSize.width) / 2,
			.y = (boundsSize.height - imageViewImageSize.height) / 2,
		},
		.size = imageViewImageSize,
	};

	imageView.frame = imageViewFrame;
}

@end


//static void CGDataProviderReleaseDataCallbackFree(void *info, const void *data, size_t size) {
//	free((void *)data);
//};
