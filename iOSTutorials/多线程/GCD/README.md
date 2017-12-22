
# GCD（Grand Central Dispatch）

### 一、简介

#### 1. 什么是 GCD

- 什么是 GCD？
通过 GCD，开发者不用再直接跟线程打交道了，只需要向队列中添加代码块即可，GCD 在后端管理着一个线程池。GCD 不仅决定着你的代码块将在哪个线程被执行，它还根据可用的系统资源对这些线程进行管理。这样可以将开发者从线程管理的工作中解放出来，通过集中的管理线程，来缓解大量线程被创建的问题。

GCD 带来的另一个重要改变是，作为开发者可以将工作考虑为一个队列，而不是一堆线程，这种并行的抽象模型更容易掌握和使用。

GCD 公开有 5 个不同的队列：运行在主线程中的 main queue，3 个不同优先级的后台队列，以及一个优先级更低的后台队列（用于 I/O）。 另外，开发者可以创建自定义队列：串行或者并行队列。自定义队列非常强大，在自定义队列中被调度的所有 block 最终都将被放入到系统的全局队列中和线程池中。

![](https://www.objc.io/images/issue-2/gcd-queues@2x-82965db9.png)


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





2. 什么情况下使用 GCD 会出现死锁？

在一个串行队列上同步添加一个任务到当前队列上（主队列也是一个串行队列）会导致死锁。

分析：当执行这个同步函数时，block 提交到队列中后，并不会马上返回，而是等到 block 执行后才会返回，因此会阻塞主队列；
而 block 中的任务加入的是当前的串行队列（在这里也就是主队列），所以需要等待队列中前面的任务完成后，才会执行 block 。
但是这个同步函数又阻塞了当前队列，结果就导致了死锁。

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


```
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
```

但是，对于一个并行队列，并不会出现上述的死锁情况，因为并行队列的任务是并发的，一个任务不需要等待上一个任务结束才开始执行。
```
dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_async(globalQueue, ^{

    NSLog(@"任务1 %@", [NSThread currentThread]);
    dispatch_sync(globalQueue, ^{
        NSLog(@"任务2 %@", [NSThread currentThread]);
    });
    NSLog(@"任务3 %@", [NSThread currentThread]);
});
```




### 参考

- [并发编程 - objc.io](https://www.objc.io/issues/2-concurrency/)
- https://bestswifter.com/multithreadconclusion/
- [dispatch_sync 和 dispatch_async 有什么区别？](https://www.zhihu.com/question/23436395)
- [五个案例让你明白GCD死锁](http://www.superqq.com/blog/2015/10/16/five-case-know-gcd/)（其中的图解非常棒）
- https://stackoverflow.com/a/5226271
- [Concurrency Programming Guide](https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html)
- [Objective-C 高级编程：内存管理和多线程]()
- https://www.appcoda.com/ios-concurrency/
