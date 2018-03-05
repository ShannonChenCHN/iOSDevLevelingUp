//
//  GHIssue.m
//  NetworkingDemo
//
//  Created by ShannonChen on 17/3/7.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "GHIssue.h"


@implementation GHIssue

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

// 没有在该方法中声明的 property key 会被忽略掉
// 其中的 “location” 对应的就是一个字典：
// @{
//      @"latitude": JSONDictionary[@"latitude"],
//      @"longitude": JSONDictionary[@"longitude"]
//   }
//
// “reporterLogin” 对应的是：JSONDictionary[@"assignee"][@"login"]
//
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"URL": @"url",
             @"HTMLURL": @"html_url",
             @"number": @"number",
             @"state": @"state",
             @"reporterLogin": @"assignee.login",
             @"assignee": @"assignee",
             @"updatedAt": @"updated_at",
             @"title": @"title",
             @"body": @"body",
             @"location" : @[@"latitude", @"longitude"],
             };
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)stateJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"open": @(GHIssueStateOpen),
                                                                           @"closed": @(GHIssueStateClosed)
                                                                           }];
}

//+ (NSValueTransformer *)assigneeJSONTransformer {
//    return [MTLJSONAdapter dictionaryTransformerWithModelClass:GHUser.class];
//}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    // Store a value that needs to be determined locally upon initialization.
    _retrievedAt = [NSDate date];
    
    return self;
}


@end
