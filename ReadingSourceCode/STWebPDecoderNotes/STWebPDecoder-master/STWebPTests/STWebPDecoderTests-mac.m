//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <XCTest/XCTest.h>

#import <Cocoa/Cocoa.h>

#import <STWebP/STWebP.h>


@interface STWebPDecoderTests : XCTestCase
@end

@implementation STWebPDecoderTests {
@private
    NSData *_gridImageData;
    NSData *_peakImageData;
}

- (NSData *)st_bitmapDataForImage:(NSImage *)image {
    CGSize const imageSize = image.size;
    NSUInteger const bitsPerComponent = 8;
    NSUInteger const bytesPerPixel = 4;
    NSUInteger const stride = (NSUInteger)imageSize.width * bytesPerPixel;

    CGBitmapInfo const bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;

    CGColorSpaceRef const drgb = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, (size_t)imageSize.width, (size_t)imageSize.height, bitsPerComponent, stride, drgb, bitmapInfo);
    CGColorSpaceRelease(drgb);
    CGContextDrawImage(ctx, (CGRect){ .size = imageSize }, [image CGImageForProposedRect:NULL context:nil hints:nil]);
    NSData * const imageData = [[NSData alloc] initWithBytes:CGBitmapContextGetData(ctx) length:(NSUInteger)(stride*imageSize.height)];

    CGContextRelease(ctx);

    return imageData;
}

- (void)setUp {
    [super setUp];

    NSBundle * const bundle = [NSBundle bundleForClass:self.class];
    {
        NSURL * const gridPNGURL = [bundle URLForResource:@"grid" withExtension:@"png" subdirectory:@"libwebp-test-data"];
        NSImage * const gridImage = [[NSImage alloc] initWithContentsOfURL:gridPNGURL];
        _gridImageData = [self st_bitmapDataForImage:gridImage];
    }
    {
        NSURL * const peakPNGURL = [bundle URLForResource:@"peak" withExtension:@"png" subdirectory:@"libwebp-test-data"];
        NSImage * const peakImage = [[NSImage alloc] initWithContentsOfURL:peakPNGURL];
        _peakImageData = [self st_bitmapDataForImage:peakImage];
    }
}

- (BOOL)st_checkLosslessVec1Image:(NSImage *)image {
    NSData * const imageBitmapData = [self st_bitmapDataForImage:image];
    return [_gridImageData isEqualToData:imageBitmapData];
}

- (BOOL)st_testLosslessVec1:(NSUInteger)number {
    NSString * const filename = [NSString stringWithFormat:@"lossless_vec_1_%lu", (unsigned long)number];
    NSBundle * const bundle = [NSBundle bundleForClass:self.class];
    NSURL * const url = [bundle URLForResource:filename withExtension:@"webp" subdirectory:@"libwebp-test-data"];
    NSData * const data = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:NULL];
    NSImage * const image = [STWebPDecoder imageWithData:data error:NULL];
    return [self st_checkLosslessVec1Image:image];
}

- (void)testLosslessVec1_0 {
    XCTAssert([self st_testLosslessVec1:0], @"");
}
- (void)testLosslessVec1_1 {
    XCTAssert([self st_testLosslessVec1:1], @"");
}
- (void)testLosslessVec1_2 {
    XCTAssert([self st_testLosslessVec1:2], @"");
}
- (void)testLosslessVec1_3 {
    XCTAssert([self st_testLosslessVec1:3], @"");
}
- (void)testLosslessVec1_4 {
    XCTAssert([self st_testLosslessVec1:4], @"");
}
- (void)testLosslessVec1_5 {
    XCTAssert([self st_testLosslessVec1:5], @"");
}
- (void)testLosslessVec1_6 {
    XCTAssert([self st_testLosslessVec1:6], @"");
}
- (void)testLosslessVec1_7 {
    XCTAssert([self st_testLosslessVec1:7], @"");
}
- (void)testLosslessVec1_8 {
    XCTAssert([self st_testLosslessVec1:8], @"");
}
- (void)testLosslessVec1_9 {
    XCTAssert([self st_testLosslessVec1:9], @"");
}
- (void)testLosslessVec1_10 {
    XCTAssert([self st_testLosslessVec1:10], @"");
}
- (void)testLosslessVec1_11 {
    XCTAssert([self st_testLosslessVec1:11], @"");
}
- (void)testLosslessVec1_12 {
    XCTAssert([self st_testLosslessVec1:12], @"");
}
- (void)testLosslessVec1_13 {
    XCTAssert([self st_testLosslessVec1:13], @"");
}
- (void)testLosslessVec1_14 {
    XCTAssert([self st_testLosslessVec1:14], @"");
}
- (void)testLosslessVec1_15 {
    XCTAssert([self st_testLosslessVec1:15], @"");
}

- (BOOL)st_checkLosslessVec2Image:(NSImage *)image {
    NSData * const imageBitmapData = [self st_bitmapDataForImage:image];
    return [_peakImageData isEqualToData:imageBitmapData];
}

- (BOOL)st_testLosslessVec2:(NSUInteger)number {
    NSString * const filename = [NSString stringWithFormat:@"lossless_vec_2_%lu", (unsigned long)number];
    NSBundle * const bundle = [NSBundle bundleForClass:self.class];
    NSURL * const url = [bundle URLForResource:filename withExtension:@"webp" subdirectory:@"libwebp-test-data"];
    NSData * const data = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:NULL];
    NSImage * const image = [STWebPDecoder imageWithData:data error:NULL];
    return [self st_checkLosslessVec2Image:image];
}

- (void)testLosslessVec2_0 {
    XCTAssert([self st_testLosslessVec2:0], @"");
}
- (void)testLosslessVec2_1 {
    XCTAssert([self st_testLosslessVec2:1], @"");
}
- (void)testLosslessVec2_2 {
    XCTAssert([self st_testLosslessVec2:2], @"");
}
- (void)testLosslessVec2_3 {
    XCTAssert([self st_testLosslessVec2:3], @"");
}
- (void)testLosslessVec2_4 {
    XCTAssert([self st_testLosslessVec2:4], @"");
}
- (void)testLosslessVec2_5 {
    XCTAssert([self st_testLosslessVec2:5], @"");
}
- (void)testLosslessVec2_6 {
    XCTAssert([self st_testLosslessVec2:6], @"");
}
- (void)testLosslessVec2_7 {
    XCTAssert([self st_testLosslessVec2:7], @"");
}
- (void)testLosslessVec2_8 {
    XCTAssert([self st_testLosslessVec2:8], @"");
}
- (void)testLosslessVec2_9 {
    XCTAssert([self st_testLosslessVec2:9], @"");
}
- (void)testLosslessVec2_10 {
    XCTAssert([self st_testLosslessVec2:10], @"");
}
- (void)testLosslessVec2_11 {
    XCTAssert([self st_testLosslessVec2:11], @"");
}
- (void)testLosslessVec2_12 {
    XCTAssert([self st_testLosslessVec2:12], @"");
}
- (void)testLosslessVec2_13 {
    XCTAssert([self st_testLosslessVec2:13], @"");
}
- (void)testLosslessVec2_14 {
    XCTAssert([self st_testLosslessVec2:14], @"");
}
- (void)testLosslessVec2_15 {
    XCTAssert([self st_testLosslessVec2:15], @"");
}

@end
