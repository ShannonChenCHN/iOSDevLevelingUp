
# 多线程


### 简介

#### 线程和进程、任务

- 进程（process），指的是一个正在运行中的可执行文件。每一个进程都拥有独立的虚拟内存空间和系统资源，包括端口权限等，且至少包含一个主线程和任意数量的辅助线程。另外，当一个进程的主线程退出时，这个进程就结束了；
- 线程（thread），指的是一个独立的代码执行路径，也就是说线程是代码执行路径的最小分支。在 iOS 中，线程的底层实现是基于 POSIX threads API 的，也就是我们常说的 pthreads ；
- 任务（task），指的是我们需要执行的工作，是一个抽象的概念，用通俗的话说，就是一段代码。

串行和并行

队列和线程


### 参考

- https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html
- https://www.appcoda.com/ios-concurrency/
- https://bestswifter.com/multithreadconclusion/
- http://www.jianshu.com/p/0b0d9b1f1f19
- [关于 iOS 多线程，都在这里了](http://www.jianshu.com/p/6a6722f12fe3)
- http://www.superqq.com/blog/2015/10/16/five-case-know-gcd/
