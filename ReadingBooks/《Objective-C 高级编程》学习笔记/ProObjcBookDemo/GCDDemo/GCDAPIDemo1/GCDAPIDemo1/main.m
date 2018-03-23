//
//  main.m
//  GCDAPIDemo1
//
//  Created by ShannonChen on 2017/4/3.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//

#import <Foundation/Foundation.h>

void executeGeneralIntroduction() {
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.shannon.gcd.myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t serialQueue = dispatch_queue_create("com.shannon.gcd.mySerialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    for (int i = 0; i < 20; i++) {
        dispatch_async(concurrentQueue, ^{
    
            NSLog(@"线程 %@ 执行任务 %d", [NSThread currentThread], i);
        });
    }
}

dispatch_time_t getDispatchTimeByDate(NSDate *date) {
    NSTimeInterval interval;
    double seconds, subseconds;
    struct timespec time;
    dispatch_time_t milestone;
    
    interval = [date timeIntervalSince1970];
    subseconds = modf(interval, &interval);
    time.tv_sec = seconds;
    time.tv_nsec = subseconds * NSEC_PER_SEC;
    
    milestone = dispatch_walltime(&time, 0);
    
    return milestone;
}

void executeDispatchAfter() {
    dispatch_time_t relativeTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3ull * NSEC_PER_SEC));
    dispatch_time_t absoluteTime = getDispatchTimeByDate([NSDate date]);
    
    dispatch_after(relativeTime, dispatch_get_main_queue(), ^{
        
    });
}

void excuteSetTargetQueue() {
    dispatch_queue_t serialQueue1 = dispatch_queue_create("com.shannon.gcd.mySerialQueue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t serialQueue2 = dispatch_queue_create("com.shannon.gcd.mySerialQueue2", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t serialQueue3 = dispatch_queue_create("com.shannon.gcd.mySerialQueue3", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t serialQueue4 = dispatch_queue_create("com.shannon.gcd.mySerialQueue4", DISPATCH_QUEUE_SERIAL);
    
    // 通过变更优先级，使多个 Serial Dispatch Queue 的并行执行，变成一次只能执行一个任务的串行，但仍然是多个线程
    dispatch_set_target_queue(serialQueue1, serialQueue4);
    dispatch_set_target_queue(serialQueue2, serialQueue4);
    dispatch_set_target_queue(serialQueue3, serialQueue4);
    
    dispatch_async(serialQueue1, ^{
        NSLog(@"线程 %@ 执行任务队列 serialQueue1", [NSThread currentThread]);
    });
    dispatch_async(serialQueue2, ^{
        NSLog(@"线程 %@ 执行任务队列 serialQueue2", [NSThread currentThread]);
    });
    dispatch_async(serialQueue3, ^{
        NSLog(@"线程 %@ 执行任务队列 serialQueue3", [NSThread currentThread]);
    });
    dispatch_async(serialQueue4, ^{
        NSLog(@"线程 %@ 执行任务队列 serialQueue4", [NSThread currentThread]);
    });

}

void executeGroupTask() {
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t queue2 = dispatch_queue_create("com.shannon.gcd.queue2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue1, ^{
        NSLog(@"线程 %@ 执行任务1", [NSThread currentThread]);
    });
    dispatch_group_async(group, queue1, ^{
        NSLog(@"线程 %@ 执行任务2", [NSThread currentThread]);
    });
    dispatch_group_async(group, queue2, ^{
        NSLog(@"线程 %@ 执行任务3", [NSThread currentThread]);
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"线程 %@ 执行最终任务", [NSThread currentThread]);
    });
    
//   long flag = dispatch_group_wait(group, 10);
    
}

void executeBarrierAsync() {
    
    __block int num = 1;
    dispatch_queue_t queue = dispatch_queue_create("com.shannon.gcd.ForBarrier", DISPATCH_QUEUE_CONCURRENT);
    
    // 前动作
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"读取数据%d： %d", i, num);
        });
    }
    
    // 中间动作
    dispatch_barrier_async(queue, ^{ // 相应的还有  dispatch_barrier_sync 函数
        
        num += 1;
        NSLog(@"写入数据： %d", num);
        
    });
    
    // 后动作
    for (int i = 10; i < 20; i++) {
        dispatch_async(queue, ^{
            NSLog(@"读取数据%d： %d", i, num);
        });
    }
    
    NSLog(@"执行主线程任务");
}

void compareSyncTaskAndAsyncTask() {
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"async %d.", i);
            
        });
    }
    
    NSLog(@"final async.");
    
    NSLog(@"====================\n");
    for (int i = 0; i < 10; i++) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"sync %d.", i);
            
        });
    }
    
    NSLog(@"final sync.");
}

void executeDeadLock() {
    // 情形一
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        NSLog(@"线程 %@", [NSThread currentThread]);
//    });
    
    // 情形二
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    dispatch_async(mainQueue, ^{
//       dispatch_sync(mainQueue, ^{
//           NSLog(@"线程 %@", [NSThread currentThread]);
//       });
//    });
    
    
    // 情形三
    dispatch_queue_t serialQueue = dispatch_queue_create("com.shannon.gcd.serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(serialQueue, ^{
        dispatch_sync(serialQueue, ^{
            NSLog(@"线程 %@", [NSThread currentThread]);
        });
    });
}

void excuteDispatchApplyFunc() {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 异步执行，不阻塞主线程
    dispatch_async(queue, ^{
        
        // 在全局队列分配的线程中执行
        dispatch_apply(10, queue, ^(size_t index) {
            NSLog(@"%zu", index);
        });
        
//        // 等待全局队列中的任务全部执行完毕后，回到主线程的 RunLoop 中
//        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"Done.");
//        });
        
    });
    
}

void executeDispatchSemphore() {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            NSObject *obj = [NSObject new];
            NSLog(@"%p", obj);
            [array addObject:obj];
            
            dispatch_semaphore_signal(semaphore);
        });
        
    }
}


void executeDispatchSourceTimer() {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 1ull * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"wakeup!");
        
        dispatch_source_cancel(timer);
    });
    
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"canceled");
        
    });
    
    NSLog(@"start timer!");
    dispatch_resume(timer);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//        // concurrent queue、 serial queue、global queue、 main queue
//        executeGeneralIntroduction();
//        
//        // dispatch_set_target_queue 函数
//        excuteSetTargetQueue();
//        
//        // dispatch_after 函数 和dispatch_time 函数、 dispatch_walltime 函数
//        executeDispatchAfter();
//        
//        // dispatch_group 函数
//        executeGroupTask();
//        
//        // dispatch_barrier_async 函数
//        executeBarrierAsync();
//
//        // dispatch_sync 函数
//        compareSyncTaskAndAsyncTask();
//        
//        // dispatch_sync 引起的死锁
//        executeDeadLock();
//        
//        // dispatch_apply 函数
//        excuteDispatchApplyFunc();
//        
//        // dispatch semaphore
//        executeDispatchSemphore();
//        
//        // dispatch_source_timer
//        executeDispatchSourceTimer();
        
        // 阻塞主线程
        for (int i = 0; i < 100; i++) {
            NSLog(@"");
        }
        
    }
    return 0;
}




