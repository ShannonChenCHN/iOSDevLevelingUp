//
//  Person.h
//  RuntimeDemo
//
//  Created by ShannonChen on 2018/3/7.
//  Copyright © 2018年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat weight;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSArray <Person *> *children;

- (BOOL)run;

- (BOOL)driveWithCar:(id)car;

@end
