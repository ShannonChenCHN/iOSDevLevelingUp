//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import "STAppDelegate.h"
#import "STWebPDecoder.h"


@implementation STAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification * __unused)aNotification {
	NSString * const webpPath = [[NSBundle mainBundle] pathForResource:@"4" ofType:@"webp"];
	NSData * const webpData = [[NSData alloc] initWithContentsOfFile:webpPath options:NSDataReadingMappedIfSafe error:NULL];
	self.imageView.image = [STWebPDecoder imageWithData:webpData scale:2 error:NULL];
}

@end
