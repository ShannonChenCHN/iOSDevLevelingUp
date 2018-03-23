//
//  Book.m
//  MemoryManagementDemo
//
//  Created by ShannonChen on 2017/3/25.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "Book.h"

@implementation Book

- (void)dealloc {
    [_name release];
    
    [super dealloc];
}


+ (instancetype)newBook {
    // 自己生成并持有对象，retainCount +1
    Book *book = [[Book alloc] init];
    
    // 注意：由于方法名是以 new 开头的，所以直接返回持有的对象，把对象地址传给外面的指针
    // 实际上也就是被外面的使用者持有了，当外面的使用者不再使用了，外面的使用者有义务把他 release 掉。
    return book;
}

+ (instancetype)bookWithName:(NSString *)name {
    // 自己生成并持有对象, retainCout +1
    Book *book = [[Book alloc] init];
    
    // 使取得的对象存在，但自己不持有对象
    [book autorelease];
    
    // 注意：由于方法名不是以 alloc、new 之类的命名规则定义的方式开头的
    // 所以外面的使用者不会持有该对象，当外面的使用者不再使用了，外面的使用者不需要把他 release 掉
    return book;
}

- (Book *)chineseBook {
    // 自己生成并持有对象, retainCout +1
    Book *book = [[Book alloc] init];
    
    // 使取得的对象存在，但自己不持有对象
    [book autorelease];
    
    // 注意：由于方法名不是以 alloc、new 之类的命名规则定义的方式开头的
    // 所以外面的使用者不会持有该对象，当外面的使用者不再使用了，外面的使用者不需要把他 release 掉
    return book;
}

- (void)turnToPage:(NSUInteger)pageIndex {
    NSLog(@"Now we are on page %li", pageIndex);
    
}


@end
