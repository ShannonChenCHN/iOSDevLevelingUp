//
//  ViewController.m
//  MemoryManagementDemo
//
//  Created by ShannonChen on 2017/3/25.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import "ViewController.h"

#import "Book.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self testMRCRules];
    
    
    [self testAutorelease];
}


- (void)testMRCRules {
    /********************************    自己生成并持有对象  retainCount +1 ***********************/
    id obj = [[NSObject alloc] init];
    NSLog(@"retain count of obj: %li", [obj retainCount]);  // 1
    [obj release];
    //    [obj release]; // 因为 obj 已经被释放掉了，这里是给 obj 发送 release 消息，使用了已经被废弃的对象，所以走到这里会奔溃， "Reference-counted object is used after it is released"
    
    // newBook 名称符合命名规则，因此它跟用 alloc 方法生成并持有对象的情况完全相同
    Book *book = [Book newBook];
    NSLog(@"retain count of book: %li", [book retainCount]); // 1
    [book release]; // 指向对象的指针仍然被保留在变量 book 中，貌似能够访问，但对象一经释放绝对不可访问
    //    book = nil;
    //    [book turnToPage:100]; // 因为 book 已经被释放掉了，所以走到这里会奔溃（如果先把 book 置为 nil，就不会崩溃了）， "Reference-counted object is used after it is released"
    
    
    
    
    /******************************    非自己生成的对象，但自己也能持有   *********************************/
    id mutableArray = [NSMutableArray array];  // 虽然 mutableArray 自己不持有生成的对象，但是 - array 方法内部通过 autorelease 实现了持有和自动释放，所以这里 retainCount +1
    NSLog(@"retain count of mutableArray: %li", [mutableArray retainCount]); // 1
    [mutableArray retain]; // 这里我们可以通过 retain 方法将调用 autorelease 方法取得的对象变为自己持有
    NSLog(@"After retain explicity, retain count of mutableArray: %li", [mutableArray retainCount]);  // 2
    [mutableArray release];
    
    
    // 自己实现一个类似于 -[NSMutableArray array] 的方法
    Book *book2 = [Book bookWithName:@"Effective Objective-C 2.0"];
    NSLog(@"retain count of book2: %li", [book2 retainCount]);
    
    Book *book3 = [book2 chineseBook];
    NSLog(@"retain count of book3: %li", [book3 retainCount]);
    //    [book3 release]; // 走到这里会奔溃，"Incorrect decrement of the reference count of an object that is not owned at this point by the caller"
}

// 函数声明，调用非公开函数
extern void _objc_autoreleasePoolPrint();

- (void)testAutorelease {

    // autorelease pool 的嵌套
    NSAutoreleasePool *pool0 = [[NSAutoreleasePool alloc] init];
        NSAutoreleasePool *pool1 = [[NSAutoreleasePool alloc] init];
    
        NSArray *array = [[NSArray alloc] init];
        [array autorelease]; // 会加入到最内侧的 pool 中
    
        _objc_autoreleasePoolPrint(); // 调用非公开函数打印 autorelease pool 中的对象
        NSLog(@"self: %p, array: %p, pool1: %p retain count: %li", self, array, pool1, [array retainCount]);  // 引用计数居然是 -1 ?!?!!
    
        [pool1 drain];
    [pool0 drain];
    
    
    
    
    // autorelease pool 的典型使用场景
    for (int i = 0; i < 100000; i++) {

        for (int i = 0; i < 100000; i++) {

            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

            UIImage *image = [UIImage imageNamed:@"like_icon.png"];
            NSArray *array = [NSArray arrayWithObjects:image, nil];
            NSLog(@"%@", array);

            [pool drain];  // 没有 autoreleasePool 的话，内存会一直增加

        }
        
    }
    
    
}

@end
