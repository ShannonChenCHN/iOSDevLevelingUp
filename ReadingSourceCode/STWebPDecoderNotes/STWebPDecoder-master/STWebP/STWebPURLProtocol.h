//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot.

#import <Foundation/Foundation.h>


extern NSString * const STWebPURLProtocolSchemePrefix;


extern NSString * const STWebPURLProtocolOptionClaimWebPExtension;


@interface STWebPURLProtocol : NSURLProtocol
+ (void)register;
+ (void)registerWithOptions:(NSDictionary *)options;
+ (void)unregister;
@end
