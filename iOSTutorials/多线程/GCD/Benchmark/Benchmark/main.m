//
//  main.m
//  Benchmark
//
//  Created by ShannonChen on 2017/12/20.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>


/// 全局队列（同时也是一个并行队列）
void startOperationOnGlobalQueue(BOOL isAsync) {
    // 获得全局的并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 将 任务 添加 全局队列 中去执行
    for (int i = 0; i < 10; i++) {
        if (isAsync) {
            // 并发队列+异步：新开多条不同的子线程，异步执行，该函数的执行不堵塞当前线程
            dispatch_async(queue, ^{
                NSLog(@"-----下载图片%@---%@", @(i), [NSThread currentThread]);
            });
            
            NSLog(@"滑动列表");
        } else {
            // 并发队列+同步：不会新开线程，顺序执行，该函数的执行会堵塞当前线程
            dispatch_sync(queue, ^{
                NSLog(@"-----下载图片%@---%@", @(i), [NSThread currentThread]);
            });
            NSLog(@"滑动列表");
        }
        
    }
    
}

/// 串行队列
void startOperationOnSerialQueue(BOOL isAsync) {
    // 1.创建一个串行队列，任务的执行方式是串行执行（一个任务执行完毕后再执行下一个任务），出队的顺序是 FIFO
    dispatch_queue_t queue = dispatch_queue_create("com.shannon.queue", DISPATCH_QUEUE_SERIAL);
    
    // 2.将任务添加到串行队列中执行
    for (int i = 0; i < 10; i++) {
        if (isAsync) {
            // 串行队列+异步：新开一条子线程，顺序执行，该函数的执行不堵塞当前线程
            dispatch_async(queue, ^{
                NSLog(@"-----下载图片%@---%@", @(i), [NSThread currentThread]);
            });
            
            NSLog(@"滑动列表");
        } else {
            // 串行队列+同步：不会新开线程，一般是在被调用的线程上执行，顺序执行，该函数的执行会堵塞当前线程
            dispatch_sync(queue, ^{
                NSLog(@"-----下载图片%@---%@", @(i), [NSThread currentThread]);
            });
            
            NSLog(@"滑动列表");
        }
        
    }
    
}

/// 主队列（其实也是一个串行队列）
void startOperationOnMainQueue(BOOL isAysnc) {
    // 1. 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // 2.将任务添加到主队列中执行
    for (int i = 0; i < 10; i++) {
        if (isAysnc) {
            // 主队列+异步：不会新开线程，因为主队列只有一个主线程
            dispatch_async(mainQueue, ^{
                NSLog(@"-----下载图片%@---%@", @(i), [NSThread currentThread]);
            });
            
            NSLog(@"滑动列表");
        } else {
            // block 中的任务加入主线程队列里等待主队列中的任务完成，才回返回 block 里面的内容。
            // 但是当同步执行这个函数时，会阻塞主线程，所以 block 中的任务不能执行，因此没有返回，结果导致这个函数也就一直没有返回，所以就造成了死锁现象.
            dispatch_sync(mainQueue, ^{
                NSLog(@"这是一个死锁");
            });
            
            NSLog(@"滑动列表");
            
//            其实，这种死锁的情况在其他串行队列也可能会发生，比如：
//            dispatch_queue_t queue = dispatch_queue_create("com.shannon.queue", DISPATCH_QUEUE_SERIAL);
//            dispatch_sync(queue, ^{
//                NSLog(@"哈哈哈");
//                dispatch_async(queue, ^{
//                    NSLog(@"这是一个死锁");
//                });
//            });
        }
        
    }
    
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        
        
        // 全局队列，异步执行
//        startOperationOnGlobalQueue(YES);
        
        // 全局队列，同步执行
//        startOperationOnGlobalQueue(NO);
        
        // 串行队列，异步执行
//        startOperationOnSerialQueue(YES);
        
        // 串行队列，同步执行
//        startOperationOnSerialQueue(NO);

        // 主队列，异步执行
//        startOperationOnMainQueue(YES);
        
        
        // 主队列，同步执行
//        startOperationOnMainQueue(NO);

        sleep(10);
        
        /*
         http://www.cnblogs.com/dsxniubility/p/4296937.html 文中的第 5 种情况跟这里的试验有出入
         http://www.superqq.com/blog/2015/10/16/five-case-know-gcd/
         结论：
         
         1. 会不新开线程，取决于执行任务的函数，同步不开，异步开（主队列除外）。
         
         2. 异步时开几条线程，取决于队列，串行开一条，并发开多条。
         
         3. 如果是同步的话，是并行队列还是串行队列没什么区别了。
         
         4. 执行同步函数会阻塞当前线程直到 block 中的任务完成，执行异步函数则不会。
         
         5. 主队列：专门用来在主线程上调度任务的"队列"，主队列不能在其他线程中调度任务。
         
         6. 在一个串行队列上同步添加一个新任务到该串行队列，会造成死锁。
         
         7. 通过同步和异步任务的嵌套，可以实现任务之间的依赖关系。
         
         8. 全局队列：并发，能够调度多个线程，执行效率高，但是相对费电。 串行队列效率较低，省电省流量，或者是任务之间需要依赖也可以使用串行队列。
         */
        
      
        
        
        
    
        
    }
    return 0;
}

