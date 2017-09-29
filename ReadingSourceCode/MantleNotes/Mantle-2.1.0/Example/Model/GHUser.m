//
//  GHUser.m
//  NetworkingDemo
//
//  Created by ShannonChen on 17/3/7.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "GHUser.h"

@implementation GHUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"userId": @"id",
             @"avatarURL": @"avatar_url",
             @"type": @"type",
             @"isAdministrator": @"site_admin"
             };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"avatarURL"]) {
        return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    }
    
    if ([key isEqualToString:@"type"]) {
        return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                               @"user": @(GHUserTypeUser),
                                                                               @"administrator": @(GHUserTypeAdministrator)
                                                                               }];
    }
    
    if ([key isEqualToString:@"isAdministrator"]) {
        return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
    }
    
    
    return nil;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self) {
        // do some additional setup after serialization.
    }
    return self;
}

@end
