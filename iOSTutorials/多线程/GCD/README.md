
# GCD

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

https://www.zhihu.com/question/23436395



2. GCD 死锁的几种情况分析


https://stackoverflow.com/a/5226271
http://www.superqq.com/blog/2015/10/16/five-case-know-gcd/


### 参考

- https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html
- https://www.appcoda.com/ios-concurrency/
- https://bestswifter.com/multithreadconclusion/
