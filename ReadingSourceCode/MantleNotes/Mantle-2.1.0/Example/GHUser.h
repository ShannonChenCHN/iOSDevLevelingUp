//
//  GHUser.h
//  NetworkingDemo
//
//  Created by ShannonChen on 17/3/7.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "Mantle.h"

typedef enum : NSInteger {
    GHUserTypeUser,
    GHUserTypeAdministrator,
} GHUserType;

@interface GHUser : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSURL *avatarURL;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) GHUserType type;
@property (nonatomic, assign, readonly) BOOL isAdministrator;


@end
