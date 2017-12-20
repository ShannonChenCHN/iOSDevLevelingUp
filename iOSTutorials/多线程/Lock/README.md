# 多线程中的锁

### 简介

### iOS 保证线程安全的几种方式

iOS 保证线程安全的几种方式有：
- NSLock
- @synchronized
- dispatch_semaphore
- 条件锁 NSConditionLock
- 递归锁 NSRecursiveLock
- NSCondition
- 自旋锁 OSSpinLock
- pthread_mutex

#### NSLock

NSLock 遵循 NSLocking 协议，lock 方法是加锁，unlock 方法是解锁，tryLock 方法是尝试加锁，如果失败的话返回 NO，lockBeforeDate: 是在指定Date之前尝试加锁，如果在指定时间之前都不能加锁，则返回NO。

使用 lock 方法添加的互斥锁会使得线程阻塞，阻塞的过程又分两个阶段，第一阶段是会先空转，可以理解成跑一个 while 循环，不断地去申请加锁，在空转一定时间之后，线程会进入 waiting 状态，此时线程就不占用CPU资源了，等锁可用的时候，这个线程会立即被唤醒。

tryLock 方法并不会阻塞线程。[lock tryLock] 能加锁返回 YES，不能加锁返回 NO，然后都会执行后续代码。

####

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
