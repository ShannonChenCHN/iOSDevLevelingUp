//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013-2014 Scott Talbot.

#import "STWebP.h"

#import "lib/libwebp/src/webp/decode.h"


static void STCGDataProviderReleaseDataCallbackFree(void * __unused info, const void *data, size_t __unused size) {
	free((void *)data);
}


@implementation STWebPStreamingDecoder {
@private
	WebPIDecoder *_decoder;
}

+ (instancetype)decoderWithData:(NSData *)data {
	return [[self alloc] initWithData:data];
}

- (id)init {
	return [self initWithData:nil];
}

- (id)initWithData:(NSData *)data {
	if ((self = [super init])) {
		_decoder = WebPINewRGB(MODE_BGRA, NULL, 0, 0);
		_state = STWebPStreamingDecoderStateIncomplete;

		if (data) {
			[self updateWithData:data];
		}
	}
	return self;
}

- (void)dealloc {
	WebPIDelete(_decoder), _decoder = NULL;
}


- (STWebPStreamingDecoderState)updateWithData:(NSData *)data {
	{
		switch (_state) {
			case STWebPStreamingDecoderStateComplete:
			case STWebPStreamingDecoderStateError:
				return _state;
			case STWebPStreamingDecoderStateIncomplete:
				break;
		}
	}

	if ([data length]) {
		VP8StatusCode status = WebPIAppend(_decoder, data.bytes, data.length);
		switch (status) {
			case VP8_STATUS_OK:
				_state = STWebPStreamingDecoderStateComplete;
				break;
			case VP8_STATUS_SUSPENDED:
				_state = STWebPStreamingDecoderStateIncomplete;
				break;
			case VP8_STATUS_BITSTREAM_ERROR:
			case VP8_STATUS_INVALID_PARAM:
			case VP8_STATUS_NOT_ENOUGH_DATA:
			case VP8_STATUS_OUT_OF_MEMORY:
			case VP8_STATUS_UNSUPPORTED_FEATURE:
			case VP8_STATUS_USER_ABORT:
				_state = STWebPStreamingDecoderStateError;
				break;
		}
	}

	return _state;
}

- (NSImage *)imageWithScale:(CGFloat)scale {
	return [self imageWithScale:scale error:nil];
}
- (NSImage *)imageWithScale:(CGFloat)scale error:(NSError * __autoreleasing *)error {
	switch (_state) {
		case STWebPStreamingDecoderStateError: {
			if (error) {
				*error = [NSError errorWithDomain:STWebPErrorDomain code:STWebPDecodeFailure userInfo:nil];
			}
			return nil;
		}
		case STWebPStreamingDecoderStateIncomplete:
		case STWebPStreamingDecoderStateComplete:
			break;
	}

	int w = 0, h = 0, last_y = 0, stride = 0;
	uint8_t *bitmapDataInternal = WebPIDecGetRGB(_decoder, &last_y, &w, &h, &stride);

	if (!bitmapDataInternal) {
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

		CGBitmapInfo const bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;

		CGColorSpaceRef drgb = CGColorSpaceCreateDeviceRGB();
		if (drgb) {
			uint8_t *bitmapData = calloc(stride, h);
			memcpy(bitmapData, bitmapDataInternal, stride * last_y);

			CGDataProviderRef bitmapDataProvider = CGDataProviderCreateWithData(NULL, bitmapData, (size_t)(stride * h), STCGDataProviderReleaseDataCallbackFree);

			if (bitmapDataProvider) {
				bitmap = CGImageCreate((size_t)w, (size_t)h, bitsPerComponent, bitsPerPixel, stride, drgb, bitmapInfo, bitmapDataProvider, NULL, YES, kCGRenderingIntentDefault);
				CGDataProviderRelease(bitmapDataProvider);
			} else {
				free(bitmapData);
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

	if (scale == 0) {
		scale = 1;
	}
	NSSize const imageSize = (NSSize){ .width = w / scale, .height = h / scale };

	NSImage *image = [[NSImage alloc] initWithCGImage:bitmap size:imageSize];
	CFRelease(bitmap);
	
	return image;
}

@end
