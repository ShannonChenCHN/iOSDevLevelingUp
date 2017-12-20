
# GCD（Grand Central Dispatch）

### 一、简介

#### 1. 什么是 GCD

- 什么是 GCD？
- GCD 与其他多线程编程技术（NSThread、NSOperation）的比较：
- GCD 的优缺点：

#### 2. 多线程编程

- 从计算机 CPU 执行命令的层面，解释一下什么是线程：
- 什么是多线程
- 多线程编程技术的原理
- 多线程编程中常见问题：
    - 数据竞争
    - 死锁
    - 线程太多导致消耗大量内存
- 为什么要使用多线程编程技术：

### 二、GCD 中的 API

1. Dispatch Queue

2. `dispatch_queue_create`函数

3. Main Dispatch Queue 和 Global Dispatch Queue

4. `dispatch_set_target_queue`

5. `dispatch_after` 函数

6. Dispatch Group

7. `dispatch_barrier_async` 函数

8. `dispatch_sync` 函数

9. `dispatch_apply` 函数

10. `dispatch_suspend` 函数和 `dispatch_resume` 函数

11. Dispatch Semaphore

12. `dispatch_once` 函数

13. Dispatch I/O


### 三、GCD 的实现

1. Dispatch Queue


2. Dispatch Source

### 四、常见问题
1. dispatch_sync 和 dispatch_async 有什么区别？

dispatch_sync和 dispatch_async需要两个参数，一个是队列，一个是block,它们的共同点是block都会在你指定的队列上执行(无论队列是并行队列还是串行队列)，不同的是dispatch_sync会阻塞当前调用GCD的线程直到block结束，而dispatch_async异步继续执行。
```
- (void)func {
    dispatch_async(someQueue, ^{
        //do some work.
        NSLog(@"Here 1.");
    });
    NSLog(@"Here 2.");
    
}
```

因为dispatch_async异步非阻塞，所以Here 1.和Here 2.的打印顺序不确定;
```
- (void)func {
    dispatch_sync(someQueue, ^{
        //do some work.
        NSLog(@"Here 1.");
    });
    NSLog(@"Here 2.");}
```
因为dispatch_sync阻塞当前操作知道block返回，所以打印顺序一定是Here 1. 然后再打印Here 2.





2. GCD 死锁

```
// 在主线程调用该函数
- (void)func {

    dispatch_sync(dispatch_get_main_queue(), ^{
        //do some work.
        NSLog(@"Here 1.");
    });
    NSLog(@"Here 2.");

}
```



### 参考

- https://bestswifter.com/multithreadconclusion/
- [dispatch_sync 和 dispatch_async 有什么区别？](https://www.zhihu.com/question/23436395)
- [五个案例让你明白GCD死锁](http://www.superqq.com/blog/2015/10/16/five-case-know-gcd/)（其中的图解非常棒）
- https://stackoverflow.com/a/5226271
- [Concurrency Programming Guide](https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html)
- [Objective-C 高级编程：内存管理和多线程]()
- https://www.appcoda.com/ios-concurrency/
