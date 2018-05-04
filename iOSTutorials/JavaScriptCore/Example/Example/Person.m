//
//  Person.m
//  Example
//
//  Created by ShannonChen on 2018/5/2.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import "Person.h"

@implementation Person

- (void)dealloc {
    
}

- (NSString *)getFullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

+ (instancetype) createWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    Person *person = [[Person alloc] init];
    person.firstName = firstName;
    person.lastName = lastName;
    return person;
}

@end
