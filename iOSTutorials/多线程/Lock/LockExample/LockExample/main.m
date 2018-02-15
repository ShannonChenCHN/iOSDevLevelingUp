//
//  main.m
//  LockExample
//
//  Created by ShannonChen on 2017/12/20.
//  Copyright © 2017年 ShannonChen. All rights reserved.
//
// https://www.jianshu.com/p/ddbe44064ca4
// http://www.jianshu.com/p/938d68ed832c


#import <Foundation/Foundation.h>
#import <pthread.h>

void testNSLock() {
    
    /*
     互斥锁会使得线程阻塞，阻塞的过程又分两个阶段，第一阶段是会先空转，可以理解成跑一个 while 循环，不断地去申请加锁，在空转一定时间之后，线程会进入 waiting 状态，此时线程就不占用CPU资源了，等锁可用的时候，这个线程会立即被唤醒。
     
     如果是多个线程，那么一个线程在加锁的时候，其余请求锁的线程将形成一个等待队列，按先进先出原则，这个结果可以通过修改线程优先级进行测试得出。
     */
    
    NSLock *lock = [[NSLock alloc] init];
    
    // 线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [lock lock];     // 这里用的和下面的任务是同一把锁，当这把锁“锁住”后，其他线程需要用这把锁时，都会被阻塞住
        NSLog(@"线程1, %@", [NSThread currentThread]);
        sleep(5);
        [lock unlock];
        NSLog(@"线程1解锁成功, %@", [NSThread currentThread]);
    });
    
    // 线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);           // 以保证让线程2的代码后执行
        [lock lock];
        NSLog(@"线程2, %@", [NSThread currentThread]);
        [lock unlock];
        
    });
    
}

void testSynchronizedLock() {
    NSString *name = @"a string";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(name) {
            sleep(5);
            NSLog(@"线程1, %@", [NSThread currentThread]);
        }
        NSLog(@"线程1解锁成功, %@", [NSThread currentThread]);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        @synchronized(name) {
            NSLog(@"线程2, %@", [NSThread currentThread]);
        }
    });
    
}


void testGCDSemaphore() {
    
    // 信号量值的大小代表还可以有多少线程同时访问被保护的资源，当为 0 时会阻塞即将要访问的线程
    // 注意，这里的传入的参数必须大于或等于 0
    dispatch_semaphore_t signal = dispatch_semaphore_create(2);   // 可以有 2 条线程同时访问
    dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC); // 超时时长为 10 秒
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 先判断信号量值是否大于 0，如果大于 0 的话，就不会阻塞线程，而是直接执行后面的任务，同时信号量减 1。
        // 如果信号值为 0，该线程会直接进入 waiting 状态，等待其他线程发送信号唤醒线程去执行后续任务。或者当 overTime  时限到了，也会执行后续任务。
        dispatch_semaphore_wait(signal, overTime);
        sleep(3); // 3 秒后开锁
        NSLog(@"线程1, %@", [NSThread currentThread]);
        dispatch_semaphore_signal(signal);     // 发送信号，如果没有等待的线程接受信号，则使 signal 信号值加一（做到对信号的保存）。
    });
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(signal, overTime);
        sleep(3);
        NSLog(@"线程2, %@", [NSThread currentThread]);
        dispatch_semaphore_signal(signal);
    });
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1); // 不要马上执行，用于测试
        dispatch_semaphore_wait(signal, overTime);
        sleep(3);
        NSLog(@"线程3, %@", [NSThread currentThread]);
        dispatch_semaphore_signal(signal);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_semaphore_wait(signal, overTime);
        sleep(3);
        NSLog(@"线程4, %@", [NSThread currentThread]);
        dispatch_semaphore_signal(signal);
    });
    
    /**
     一个 dispatch_semaphore_wait() 函数必须要对应一个 dispatch_semaphore_signal() 函数，看起来像 NSLock 的 lock 和 unlock。
     两者的区别在于，NSLock 所限制的是一次只能一个线程访问被保护的临界区，而 dispatch_semaphore 有信号量这个参数，如果 dispatch_semaphore 的信号量初始值为 x ，则可以有 x 个线程同时访问被保护的临界区。
     所以，也可以这样理解，dispatch_semaphore 作为信号量，当信号总量设为 1 时也可以当作锁来。
     
     */
}

void testNSCondition() {
    
    NSCondition *lock = [[NSCondition alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [lock lock];
        while (array.count == 0) {
            NSLog(@"线程1处于等待状态, %@", [NSThread currentThread]);
            [lock wait];
        }
        [array removeAllObjects];
        NSLog(@"array removeAllObjects");
        [lock unlock];
    });
    
    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);//以保证让线程2的代码后执行
        [lock lock];
        NSLog(@"线程2, %@", [NSThread currentThread]);
        [array addObject:@1];
        NSLog(@"array addObject:@1");
        [lock signal];
        [lock unlock];
    });
    
}


void testConditionLock() {
    
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"线程1准备加锁");
        [lock lockWhenCondition:1];
        NSLog(@"线程1");
        sleep(2);
        [lock unlock];
    });
    
    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);   // 以保证让线程2的代码后执行
        if ([lock tryLockWhenCondition:0]) {
            NSLog(@"线程2");
            [lock unlockWithCondition:2];
            NSLog(@"线程2解锁成功");
        } else {
            NSLog(@"线程2尝试加锁失败");
        }
    });
    
    //线程3
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);       // 以保证让线程3的代码后执行
        if ([lock tryLockWhenCondition:2]) {
            NSLog(@"线程3");
            [lock unlock];
            NSLog(@"线程3解锁成功");
        } else {
            NSLog(@"线程3尝试加锁失败");
        }
    });
    
    //线程4
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(3);        // 以保证让线程4的代码后执行
        if ([lock tryLockWhenCondition:2]) {
            NSLog(@"线程4");
            [lock unlockWithCondition:1];
            NSLog(@"线程4解锁成功");
        } else {
            NSLog(@"线程4尝试加锁失败");
        }
    });
    
}


void testNSRecursiveLock() {
    
    /*
     如果用 NSLock 的话，lock 先锁上了，但未执行解锁的时候，就会进入递归的下一层，而再次请求上锁，阻塞了该线程，线程被阻塞了，自然后面的解锁代码不会执行，而形成了死锁。而 NSRecursiveLock 递归锁就是为了解决这个问题。
     */
//    NSLock *lock = [[NSLock alloc] init];
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        static void (^RecursiveBlock)(int);
        RecursiveBlock = ^(int value) {
            [lock lock];
            if (value > 0) {
                NSLog(@"线程：%@，value: %d", [NSThread currentThread], value);
                RecursiveBlock(value - 1);
            }
            [lock unlock];
        };
        RecursiveBlock(2);
    });
    
}


void testOSSpinLock() {
    
    __block OSSpinLock theLock = OS_SPINLOCK_INIT;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&theLock);
        NSLog(@"线程1");
        sleep(5);
        OSSpinLockUnlock(&theLock);
        NSLog(@"线程1解锁成功");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        OSSpinLockLock(&theLock);
        NSLog(@"线程2");
        OSSpinLockUnlock(&theLock);
    });
    
    /*
     拿输出结果和上面 NSLock 的输出结果做对比，会发现 sleep(5) 的情况，OSSpinLock 中的“线程 2”并没有和”线程 1解锁成功“在一个时间输出，而是有一点时间间隔，而 NSLock 这里是同一时间输出，所以 OSSpinLock 一直在做着轮询，而不是像 NSLock 一样先轮询，再 waiting 等唤醒。
     */
}

void testPthreadMutexNormalLock() {
    
    __block pthread_mutex_t theLock;
    pthread_mutex_init(&theLock, NULL); // NULL 代表锁类型为 PTHREAD_MUTEX_NORMAL
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&theLock);
        NSLog(@"需要线程同步的操作1 开始");
        sleep(3);
        NSLog(@"需要线程同步的操作1 结束");
        pthread_mutex_unlock(&theLock);
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        pthread_mutex_lock(&theLock);
        NSLog(@"需要线程同步的操作2");
        pthread_mutex_unlock(&theLock);
        
    });
}

void testPthreadMutexRecursiveLock() {
    __block pthread_mutex_t theLock;
    
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE); // 递归锁
    pthread_mutex_init(&theLock, &attr);
    pthread_mutexattr_destroy(&attr);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        static void (^RecursiveMethod)(int);
        
        RecursiveMethod = ^(int value) {
            
            pthread_mutex_lock(&theLock);
            if (value > 0) {
                
                NSLog(@"value = %d", value);
                sleep(1);
                RecursiveMethod(value - 1);
            }
            pthread_mutex_unlock(&theLock);
        };
        
        RecursiveMethod(5);
    });
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//        testNSLock();
//        testSynchronizedLock();
//        testGCDSemaphore();
//        testNSCondition();
//        testConditionLock();
//        testNSRecursiveLock();
//        testOSSpinLock();
//        testPthreadMutexLock();
//        testPthreadMutexRecursiveLock();
        
        sleep(10);
       
    }
    return 0;
}

