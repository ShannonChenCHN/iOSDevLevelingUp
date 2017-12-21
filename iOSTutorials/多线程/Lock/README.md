# 多线程中的锁

### 一、简介

### 二、iOS 保证线程安全的几种方式

iOS 保证线程安全的几种方式有：
- 互斥锁 NSLock
- 互斥锁 @synchronized
- 信号量 dispatch_semaphore
- 条件锁 NSCondition
- 条件锁 NSConditionLock
- 递归锁 NSRecursiveLock
- 自旋锁 OSSpinLock
- pthread_mutex

#### 1. NSLock

```
_lock = [[NSLock alloc] init];

- (void)testMethod {
    [lock lock];
    self.name = @"another name";
    [lock unlock];
}

```

NSLock 遵循 NSLocking 协议，lock 方法是加锁，unlock 方法是解锁，tryLock 方法是尝试加锁，如果失败的话返回 NO，lockBeforeDate: 是在指定Date之前尝试加锁，如果在指定时间之前都不能加锁，则返回NO。

使用 lock 方法添加的互斥锁会使得线程阻塞，阻塞的过程又分两个阶段，第一阶段是会先空转，可以理解成跑一个 while 循环，不断地去申请加锁，在空转一定时间之后，线程会进入 waiting 状态，此时线程就不占用CPU资源了，等锁可用的时候，这个线程会立即被唤醒。

tryLock 方法并不会阻塞线程。[lock tryLock] 能加锁返回 YES，不能加锁返回 NO，然后都会执行后续代码。

#### 2. @synchronized

```
- (void)testMethod {
    @synchronized(self) {
        self.name = @"another name";
    }
}

```

@synchronized(object) 指令使用的 object 为该锁的唯一标识，只有当标识相同时，才满足互斥，所以如果线程 2 中的 @synchronized(self) 改为@synchronized(self.view)，则线程2就不会被阻塞。

@synchronized 指令实现锁的优点就是我们不需要在代码中显式的创建锁对象，便可以实现锁的机制。但作为一种预防措施，@synchronized 块会隐式的添加一个异常处理例程来保护代码，该处理例程会在异常抛出的时候自动的释放互斥锁。@synchronized 还有一个好处就是不用担心忘记解锁了。

如果在 @sychronized(object){} 内部 object 被释放或被设为 nil，从测试的结果来看，的确没有问题，但如果 object 一开始就是 nil，则失去了锁的功能。不过虽然 nil 不行，但 @synchronized([NSNull null]) 是完全可以的。


#### 3. dispatch_semaphore
dispatch_semaphore 是 GCD 用来同步的一种方式，与他相关的有三个函数：

- `dispatch_semaphore_create(long value)`：创建信号量。信号量值的大小代表还可以有多少线程同时访问被保护的资源，当为 0 时会阻塞即将要访问的线程。注意，这里的传入的参数必须大于或等于 0。
- `dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout)`：等待信号。先判断信号量值是否大于 0，如果大于 0 的话，就不会阻塞线程，而是直接执行后面的任务，同时信号量减 1。如果信号值为 0，该线程会直接进入 waiting 状态（不会去轮询），等待其他线程发送信号唤醒线程去执行后续任务。或者当 overTime  时限到了，也会执行后续任务。
- `dispatch_semaphore_signal(dispatch_semaphore_t dsema)`：发送信号。如果没有等待的线程接受信号，则使 signal 信号值加 1。

一个 `dispatch_semaphore_wait() ` 函数必须要对应一个 `dispatch_semaphore_signal()` 函数，看起来像 NSLock 的 ` lock` 和 `unlock`。
两者的区别在于，NSLock 所限制的是一次只能一个线程访问被保护的临界区，而 dispatch_semaphore 有信号量这个参数，如果 dispatch_semaphore 的信号量初始值为 x ，则可以有 x 个线程同时访问被保护的临界区。
所以，也可以这样理解，dispatch_semaphore 作为信号量，当信号总量设为 1 时也可以当作锁来。


```
dispatch_semaphore_t signal = dispatch_semaphore_create(1);   // 一次可以有 1 条线程同时访问
dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC); // 超时时长为 10 秒

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_semaphore_wait(signal, overTime);
    sleep(3); // 3 秒后开锁
    NSLog(@"线程1, %@", [NSThread currentThread]);
    dispatch_semaphore_signal(signal);
});

```

#### 4. NSCondition

NSCondition 的对象实际上作为一个锁和一个线程检查器，锁上之后可以保护任务中访问的资源，线程检查器可以根据条件决定是否继续执行任务。当条件不满足时，当前线程就会被阻塞。等到其它线程中的同一个锁执行 signal 或者 broadcast 方法时，线程被唤醒，再根据条件决定是否继续运行之后的任务。

几个常用方法：
- `lock`：一般用于多线程同时访问、修改同一个数据源，保证在同一时间内数据源只被访问、修改一次，其他使用相同 lock 的线程会被阻塞住。

- `unlock`：解锁，与 lock 配合使用。

- `wait`：让当前线程处于等待状态。

- `signal`：CPU发信号告诉线程不用在等待，可以继续执行。

NSCondition 的使用步骤：
> 1. 锁住 condition 对象。
> 2. 根据一个布尔条件，来决定是否要执行后面的任务。
> 3. 如果这个布尔条件为假，就调用 condition 对象的 `wait` 方法或者 `waitUntilDate:` 方法来阻塞当前线程。一旦 `wait` 方法返回了，当前线程就不再阻塞，接着回到步骤 2，重新检查布尔条件。
> 4. 如果这个布尔条件为真，就接着执行后面的任务。
> 5. 如果需要的话，更新一些影响条件判断的参数或者发送信号量给 condition 对象。
> 6. 任务完成，不再锁住 condition 对象。

使用伪代码来表示的话，就是下面这样：
```
lock the condition
while (!(boolean_predicate)) {
    wait on condition
}
do protected work
(optionally, signal or broadcast the condition again or change a predicate value)
unlock the condition
```


当一个线程在等待一个条件时，也就是调用 `wait` 方法时，condition 对象会解开之前加上的锁，同时阻塞当前线程。等到这个 condition 对象被信号量唤醒时，当前线程也就不再被阻塞了。这个 condition 对象在 `wait` 和 `waitUntilDate:` 方法返回前，又会重新加上锁。因此，我们可以看做当前线程一直是安全的。


#### 5. NSConditionLock

NSConditionLock 是一种条件锁，NSConditionLock 和 NSLock 一样，都遵循 NSLocking 协议，方法也很类似，只是多了一个 condition 属性，以及每个操作都多了一个更新 condition 属性的方法。

只有 condition 参数与初始化时候的 condition 相等，lock 才能正确进行加锁操作。而 unlockWithCondition: 并不是当 Condition 符合条件时才解锁，而是解锁之后，修改 Condition 的值。

- `lockWhenCondition:`
- `tryLockWhenCondition:`
- `unlockWithCondition:`

#### 6. NSRecursiveLock
NSRecursiveLock 是递归锁，他和 NSLock 的区别在于，NSRecursiveLock 可以在一个线程中重复加锁（反正单线程内任务是按顺序执行的，不会出现资源竞争问题），NSRecursiveLock 会记录上锁和解锁的次数，当二者平衡的时候，才会释放锁，其它线程才可以上锁成功。

```
NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    static void (^RecursiveBlock)(int);
    RecursiveBlock = ^(int value) {
        [lock lock];
        if (value > 0) {
            NSLog(@"value:%d", value);
            RecursiveBlock(value - 1);
        }
        [lock unlock];
    };
    RecursiveBlock(2);
});
```

如上面的示例，如果用 NSLock 的话，lock 先锁上了，但未执行解锁的时候，就会进入递归的下一层，而再次请求上锁，阻塞了该线程，线程被阻塞了，自然后面的解锁代码不会执行，而形成了死锁。而 NSRecursiveLock 递归锁就是为了解决这个问题。

#### 7. 自旋锁 OSSpinLock

OSSpinLock 是一种自旋锁，也只有加锁，解锁，尝试加锁三个方法。和 NSLock 不同的是 NSLock 请求加锁失败的话，会先轮询，但一秒过后便会使线程进入 waiting 状态，等待唤醒。而 OSSpinLock 会一直轮询，等待时会消耗大量 CPU 资源，不适用于较长时间的任务。

使用示例：
```
__block OSSpinLock theLock = OS_SPINLOCK_INIT;
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    OSSpinLockLock(&theLock);
    NSLog(@"线程1");
    sleep(10);
    OSSpinLockUnlock(&theLock);
    NSLog(@"线程1解锁成功");
});

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    sleep(1);
    OSSpinLockLock(&theLock);
    NSLog(@"线程2");
    OSSpinLockUnlock(&theLock);
});
```
拿上面的输出结果和上文 NSLock 的输出结果做对比，会发现 sleep(10) 的情况，OSSpinLock 中的“线程 2”并没有和”线程 1解锁成功“在一个时间输出，而是有一点时间间隔，而 NSLock 这里是同一时间输出，所以 OSSpinLock 一直在做着轮询，而不是像 NSLock 一样先轮询，再 waiting 等唤醒。


OSSpinLock 自旋锁，性能最高的锁。原理很简单，就是一直 do while 忙等。它的缺点是当等待时会消耗大量 CPU 资源，所以它不适用于较长时间的任务。 不过最近YY大神在自己的博客不再安全的 OSSpinLock中说明了OSSpinLock已经不再安全，在 macOS 10.12 中已经被 deprecate 了。

#### 8. pthread_mutex

pthread pthread_mutex 是 C 语言下多线程加互斥锁的方式，使用时需要通过 `#import <pthread.h>` 导入头文件。


几个相关函数：
- `pthread_mutex_init(pthread_mutex_t * mutex,const pthread_mutexattr_t attr)`：初始化锁变量 mutex，attr 为锁属性，传 NULL 时就为默认属性。锁的类型一共有 4 类型：
    - `PTHREAD_MUTEX_NORMAL`：缺省类型，也就是普通锁。当一个线程加锁以后，其余请求锁的线程将形成一个等待队列，并在解锁后先进先出原则获得锁。
    - `PTHREAD_MUTEX_ERRORCHECK`： 检错锁，如果同一个线程请求同一个锁，则返回 EDEADLK，否则与普通锁类型动作相同。这样就保证当不允许多次加锁时不会出现嵌套情况下的死锁。
    - `PTHREAD_MUTEX_RECURSIVE`： 递归锁，允许同一个线程对同一个锁成功获得多次，并通过多次 unlock 解锁。
    - `PTHREAD_MUTEX_DEFAULT`： 适应锁，动作最简单的锁类型，仅等待解锁后重新竞争，没有等待队列。

- `pthread_mutex_lock(pthread_mutex_t* mutex)`：加锁
- `pthread_mutex_tylock(pthread_mutex_t* mutex);`：尝试加锁，但是与上面一个函数不一样的是，当锁已经在使用的时候，返回为EBUSY，而不是挂起等待。
- `pthread_mutex_unlock(pthread_mutex_t* mutex);`：释放锁
- `pthread_mutex_destroy(pthread_mutex_t* *mutex);`：使用完后释放

##### 8.1 普通锁


跟 NSLock 的效果类似：
```
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

```

##### 8.2 递归锁


```
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
```

这是 `pthread_mutex` 为了防止在递归的情况下出现死锁而出现的递归锁。作用和 `NSRecursiveLock` 递归锁类似。
如果使用 `pthread_mutex_init(&theLock, NULL);` 初始化锁的话，上面的代码会出现死锁现象。如果使用递归锁的形式，就没有问题。

### 三、总结

ibireme 在 [ 不再安全的 OSSpinLock](https://link.jianshu.com/?t=http://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios/) 中对不同的锁做出了性能对比分析：

![](https://blog.ibireme.com/wp-content/uploads/2016/01/lock_benchmark.png)

- OSSpinLock 和 dispatch_semaphore 的效率远远高于其他。
- @synchronized 和 NSConditionLock 效率较差。

值得注意的是，OSSpinLock 性能最高，但它已经不再安全，如果一个低优先级的线程获得锁并访问共享资源，这时一个高优先级的线程也尝试获得这个锁，由于它会处于轮询的忙等状态从而占用大量 CPU。此时低优先级线程无法与高优先级线程争夺 CPU 时间，从而导致任务迟迟完不成、无法释放 lock。这样就很容易导致*优先级反转*的问题。

另外，如果不考虑性能，只是图个方便的话，那就使用 @synchronized。

最后用一句来解释线程安全怎么解决：解决线程安全的问题，无非就是加锁，等待（阻塞），解锁。


### 参考

- [深入理解 iOS 开发中的锁](https://bestswifter.com/ios-lock/)
- [关于 @synchronized，这儿比你想知道的还要多](http://yulingtianxia.com/blog/2015/11/01/More-than-you-want-to-know-about-synchronized/)
- [iOS中保证线程安全的几种方式与性能对比](https://www.jianshu.com/p/938d68ed832c)
- [不再安全的 OSSpinLock](https://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios/)
- [iOS 常见知识点（三）：Lock](https://www.jianshu.com/p/ddbe44064ca4)
- [Threading Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Multithreading/ThreadSafety/ThreadSafety.html)
- [iOS多线程到底不安全在哪里？ - MrPeak](http://mrpeak.cn/blog/ios-thread-safety/)
- [iOS多线程-各种线程锁的简单介绍](http://www.jianshu.com/p/35dd92bcfe8c)
- [正确使用多线程同步锁@synchronized() - MrPeak](http://mrpeak.cn/blog/synchronized/)
