//
//  main.m
//  LockExample
//
//  Created by ShannonChen on 2017/12/20.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//
// https://www.jianshu.com/p/ddbe44064ca4


#import <Foundation/Foundation.h>


void testNSLock() {
    
    /*
     互斥锁会使得线程阻塞，阻塞的过程又分两个阶段，第一阶段是会先空转，可以理解成跑一个 while 循环，不断地去申请加锁，在空转一定时间之后，线程会进入 waiting 状态，此时线程就不占用CPU资源了，等锁可用的时候，这个线程会立即被唤醒。
     
     如果是多个线程，那么一个线程在加锁的时候，其余请求锁的线程将形成一个等待队列，按先进先出原则，这个结果可以通过修改线程优先级进行测试得出。
     */
    
    NSLock *lock = [[NSLock alloc] init];
    
    // 线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [lock lock];     // 这里用的和下面的任务是同一把锁，当这把锁“锁住”后，其他线程需要用这把锁时，都会被阻塞住
        NSLog(@"线程1");
        sleep(5);
        [lock unlock];
        NSLog(@"线程1解锁成功");
    });
    
    // 线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);           // 以保证让线程2的代码后执行
//        [lock lock];
        
        NSLog(@"线程2");
        [lock unlock];
        
    });
    
    sleep(10);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        testNSLock();
       
    }
    return 0;
}

