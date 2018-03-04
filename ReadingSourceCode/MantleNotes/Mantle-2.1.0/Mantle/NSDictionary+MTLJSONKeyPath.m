//
//  NSDictionary+MTLJSONKeyPath.m
//  Mantle
//
//  Created by Robert Böhnke on 19/03/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "NSDictionary+MTLJSONKeyPath.h"

#import "MTLJSONAdapter.h"

@implementation NSDictionary (MTLJSONKeyPath)

// 从 JSON Dictionary 中找到 keypath 对应的值，可能存在多层嵌套的情况，比如 @"assignee.login"
- (id)mtl_valueForJSONKeyPath:(NSString *)JSONKeyPath success:(BOOL *)success error:(NSError **)error {
    
    // @"assignee.login"  ---> @[@"assignee", @"login"]
	NSArray *components = [JSONKeyPath componentsSeparatedByString:@"."];

    // 一层一层的去取 key 值对应的 value
	id result = self;
	for (NSString *component in components) {  // 示例：1. @"assignee",  2. @"login"
		// Check the result before resolving the key path component to not
		// affect the last value of the path.
		if (result == nil || result == NSNull.null) break;

        // 每一层都必须是字典
		if (![result isKindOfClass:NSDictionary.class]) {
			if (error != NULL) {
				NSDictionary *userInfo = @{
					NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid JSON dictionary", @""),
					NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"JSON key path %1$@ could not resolved because an incompatible JSON dictionary was supplied: \"%2$@\"", @""), JSONKeyPath, self]
				};

				*error = [NSError errorWithDomain:MTLJSONAdapterErrorDomain code:MTLJSONAdapterErrorInvalidJSONDictionary userInfo:userInfo];
			}

			if (success != NULL) *success = NO;

			return nil;
		}

        result = result[component];  // 示例：1. {@"login": @"octocat"}  2.  octocat
	}

	if (success != NULL) *success = YES;

	return result;
}

@end
