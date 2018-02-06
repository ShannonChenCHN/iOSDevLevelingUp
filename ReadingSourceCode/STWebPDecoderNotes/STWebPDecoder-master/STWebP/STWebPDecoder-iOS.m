//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot.

#import "STWebP.h"

#import "lib/libwebp/src/webp/decode.h"


static void STCGDataProviderReleaseDataCallbackFree(void * __unused info, const void *data, size_t __unused size) {
	free((void *)data);
}


@implementation STWebPDecoder

+ (UIImage *)imageWithData:(NSData *)data error:(NSError * __autoreleasing *)error {
	return [self imageWithData:data scale:1 error:error];
}

+ (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale error:(NSError * __autoreleasing *)error {
	int w = 0, h = 0;
	uint8_t *bitmapData = WebPDecodeBGRA(data.bytes, data.length, &w, &h);
	if (!bitmapData) {
		if (error) {
			*error = [NSError errorWithDomain:STWebPErrorDomain code:STWebPDecodeFailure userInfo:nil];
		}
		return nil;
	}

	CGImageRef bitmap = NULL;
	{
		NSUInteger const bitsPerComponent = 8;
		NSUInteger const bytesPerPixel = 4;
		NSUInteger const bitsPerPixel = bitsPerComponent * bytesPerPixel;
		NSUInteger const stride = (NSUInteger)w * bytesPerPixel;

		CGBitmapInfo const bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;

		CGColorSpaceRef drgb = CGColorSpaceCreateDeviceRGB();
		if (drgb) {
			CGDataProviderRef bitmapDataProvider = CGDataProviderCreateWithData(NULL, bitmapData, (size_t)(stride * h), STCGDataProviderReleaseDataCallbackFree);

			if (bitmapDataProvider) {
				bitmap = CGImageCreate((size_t)w, (size_t)h, bitsPerComponent, bitsPerPixel, stride, drgb, bitmapInfo, bitmapDataProvider, NULL, YES, kCGRenderingIntentDefault);
				CGDataProviderRelease(bitmapDataProvider);
			}

			CGColorSpaceRelease(drgb);
		}
	}
	if (!bitmap) {
		if (error) {
			*error = [NSError errorWithDomain:STWebPErrorDomain code:STWebPDecodeFailure userInfo:nil];
		}
		return nil;
	}

	UIImage *image = [[UIImage alloc] initWithCGImage:bitmap scale:scale orientation:UIImageOrientationUp];
	CFRelease(bitmap);

	return image;
}

@end
