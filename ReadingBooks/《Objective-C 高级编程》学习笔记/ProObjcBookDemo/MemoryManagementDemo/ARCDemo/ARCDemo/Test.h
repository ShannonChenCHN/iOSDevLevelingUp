//
//  Test.h
//  ARCDemo
//
//  Created by ShannonChen on 2017/3/26.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Test : NSObject {
    id __strong obj_;
}

- (void)setObject:(id __strong)obj;

+ (void)testAutoreleaseQualifier;

+ (void)testArray;

@end
