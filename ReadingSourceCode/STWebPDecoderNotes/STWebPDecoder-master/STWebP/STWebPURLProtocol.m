//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot.

#import "STWebP.h"


NSString * const STWebPURLProtocolOptionClaimWebPExtension = @"claim-webp-extension";


NSString * const STWebPURLProtocolSchemePrefix = @"stwebp-";
static NSUInteger const STWebPURLProtocolSchemePrefixLength = 7;

static NSString * const STWebPURLRequestHandledKey = @"stwebp-handled";
static NSString * const STWebPURLRequestHandledValue = @"handled";


static NSDictionary *gSTWebPURLProtocolOptions = nil;


@interface STWebPURLProtocol () <NSURLConnectionDataDelegate>
@end

@implementation STWebPURLProtocol {
@private
	NSURLConnection *_connection;
	STWebPStreamingDecoder *_decoder;
}

+ (void)register {
	[self registerWithOptions:nil];
}
+ (void)registerWithOptions:(NSDictionary *)options {
	NSAssert([NSThread isMainThread], @"not on main thread");

	NSMutableDictionary *sanitizedOptions = [[NSMutableDictionary alloc] initWithCapacity:options.count];
	{
		id const optionClaimWebPExtension = options[STWebPURLProtocolOptionClaimWebPExtension];
		if ([optionClaimWebPExtension respondsToSelector:@selector(boolValue)] && [optionClaimWebPExtension boolValue]) {
			[sanitizedOptions setObject:@YES forKey:STWebPURLProtocolOptionClaimWebPExtension];
		}
	}
	gSTWebPURLProtocolOptions = [sanitizedOptions copy];

	[NSURLProtocol registerClass:self];
}

+ (void)unregister {
	NSAssert([NSThread isMainThread], @"not on main thread");

	[self unregisterClass:self];
	gSTWebPURLProtocolOptions = nil;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	if ([self propertyForKey:STWebPURLRequestHandledKey inRequest:request] == STWebPURLRequestHandledValue) {
		return NO;
	}

	NSString * const requestURLScheme = request.URL.scheme.lowercaseString;

	BOOL canProbablyInit = NO;
	if ([requestURLScheme hasPrefix:STWebPURLProtocolSchemePrefix]) {
		NSString * const deprefixedScheme = [requestURLScheme substringFromIndex:STWebPURLProtocolSchemePrefixLength];
		canProbablyInit = [deprefixedScheme hasPrefix:@"http"];
	}
	if (!canProbablyInit && [gSTWebPURLProtocolOptions[STWebPURLProtocolOptionClaimWebPExtension] boolValue]) {
		NSString * const requestURLPathExtension = request.URL.pathExtension.lowercaseString;
		if ([@"webp" isEqualToString:requestURLPathExtension]) {
			canProbablyInit = [requestURLScheme hasPrefix:@"http"];
		}
	}
	if (!canProbablyInit) {
		return NO;
	}
	request = [self st_canonicalRequestForRequest:request];
	return [NSURLConnection canHandleRequest:request];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return [self st_canonicalRequestForRequest:request];
}

+ (NSURLRequest *)st_canonicalRequestForRequest:(NSURLRequest *)request {
	NSURL *url = request.URL;
	NSString * const absoluteURLString = [url absoluteString];
	if ([absoluteURLString hasPrefix:STWebPURLProtocolSchemePrefix]) {
		url = [NSURL URLWithString:[absoluteURLString substringFromIndex:STWebPURLProtocolSchemePrefixLength]];
	}
	NSMutableURLRequest * const modifiedRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:request.cachePolicy timeoutInterval:request.timeoutInterval];
	[modifiedRequest addValue:@"image/webp" forHTTPHeaderField:@"Accept"];
	[self setProperty:STWebPURLRequestHandledValue forKey:STWebPURLRequestHandledKey inRequest:modifiedRequest];
	return modifiedRequest;
}


- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
	if ((self = [super initWithRequest:request cachedResponse:cachedResponse client:client])) {
		request = [self.class canonicalRequestForRequest:request];
		_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
		[_connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	}
	return self;
}

- (void)dealloc {
	[_connection cancel];
}


- (void)startLoading {
	[_connection start];
}

- (void)stopLoading {
	[_connection cancel];
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection * __unused)connection didFailWithError:(NSError *)error {
	[self.client URLProtocol:self didFailWithError:error];
}


#pragma mark - NSURLConnectionDataDelegate

- (NSURLRequest *)connection:(NSURLConnection * __unused)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse * __unused)response {
//	[self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
	return request;
}

- (void)connection:(NSURLConnection * __unused)connection didReceiveResponse:(NSURLResponse *)response {
	NSHTTPURLResponse * const httpResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;

	if (httpResponse.statusCode != 200) {
		[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
		return;
	}

	NSDictionary * const responseHeaderFields = @{
		@"Content-Type": @"image/png",
		@"X-STWebP": @"YES",
	};

	NSURLRequest * const request = self.request;
	NSHTTPURLResponse * const modifiedResponse = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"1.0" headerFields:responseHeaderFields];

	_decoder = [[STWebPStreamingDecoder alloc] init];
	[self.client URLProtocol:self didReceiveResponse:modifiedResponse cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connection:(NSURLConnection * __unused)connection didReceiveData:(NSData *)data {
	[_decoder updateWithData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection * __unused)connection {
	NSError *error = nil;
	UIImage *image = [_decoder imageWithScale:1 error:&error];
	if (!image) {
		[self.client URLProtocol:self didFailWithError:error];
		return;
	}

	NSData *imagePNGData = UIImagePNGRepresentation(image);
	[self.client URLProtocol:self didLoadData:imagePNGData];
	[self.client URLProtocolDidFinishLoading:self];
}

@end
