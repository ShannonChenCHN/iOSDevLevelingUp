//
//  Book.h
//  MemoryManagementDemo
//
//  Created by ShannonChen on 2017/3/25.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (copy, nonatomic) NSString *name;

+ (instancetype)newBook;
+ (instancetype)bookWithName:(NSString *)name;

- (Book *)chineseBook;
- (void)turnToPage:(NSUInteger)pageIndex;



@end
