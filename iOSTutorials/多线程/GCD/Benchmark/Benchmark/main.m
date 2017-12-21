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
            // 当执行这个同步函数时，block 提交到队列中后，并不会马上返回，而是等到 block 执行后才会返回，因此会阻塞主队列；
            // 而 block 中的任务加入的是当前的串行队列（在这里也就是主队列），所以需要等待队列中前面的任务完成后，才会执行 block 。
            // 但是这个同步函数又阻塞了当前队列，结果就导致了死锁。
            /*
                 Serial Queue
             ┏━━━━━━━━━━━━━━━━━━┓
             ┃       task 1     ┃ ↑
             ┃━━━━━━━━━━━━━━━━━━┃ ┃
             ┃  dispatch_sync   ┃ ↑ ━━━━┓
             ┃━━━━━━━━━━━━━━━━━━┃ ┃     ┃
             ┃      task 2      ┃ ↑     ↓  等待 block 执行完后 dispatch_sync 函数再返回
             ┃━━━━━━━━━━━━━━━━━━┃ ┃     ┃  而 block 需要等到队列中前面所有任务执行完才执行
             ┃ submitted block  ┃ ↑ <━━━┛
             ┗━━━━━━━━━━━━━━━━━━┛
             */
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
        dispatch_queue_t serialQueue = dispatch_queue_create("com.shannon.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t concurrentQueue = dispatch_queue_create("com.shannon.queue", DISPATCH_QUEUE_CONCURRENT);
        
        
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
        
        dispatch_async(serialQueue, ^{
//            NSLog(@"异步-任务1");
        });
        
        dispatch_async(concurrentQueue, ^{
            NSLog(@"异步-任务1 %@", [NSThread currentThread]);
            dispatch_sync(concurrentQueue, ^{
                NSLog(@"同步-任务2 %@", [NSThread currentThread]);
            });
            NSLog(@"异步-任务2 %@", [NSThread currentThread]);
        });
        

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

