# Runloop


### 一、简介

#### 1. 什么是 Runloop？

Runloop 是什么？Runloop 还是比较顾名思义的一个东西，说白了就是一种循环，只不过它这种循环比较高级。一般的 while 循环会导致 CPU 进入忙等待状态，而 Runloop 则是一种“闲”等待，这部分可以类比 Linux 下的 epoll。当没有事件时，Runloop 会进入休眠状态，有事件发生时， Runloop 会去找对应的 Handler 处理事件。Runloop 可以让线程在需要做事的时候忙起来，不需要的话就让线程休眠。

![](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Multithreading/Art/runloop.jpg)

举个例子，一个应用开始运行以后，如果不对它进行任何操作，这个应用就像静止了一样，不会自发的有任何动作发生，但是如果我们点击界面上的一个按钮，这个时候就会有对应的按钮响应事件发生。给我们的感觉就像应用一直处于随时待命的状态，在没人操作的时候它一直在休息，在让它干活的时候，它就能立刻响应。其实，这就是 Runloop 的功劳。


#### 2. 为什么需要 Runloop？

一般来说一个线程一次只能执行一个任务，任务执行完成这个线程就会退出。
某些情况下我们需要这个线程一直运行着，不管有没有任务执行（比方说App的主线程），所以需要一种机制来维持线程的生命周期，通常的代码逻辑是这样的：

```
function loop() {
    initialize();
    do {
        var message = get_next_message();
        process_message(message);
    } while (message != quit);
}
```
这种模型通常被称作 Event Loop。 Event Loop 在很多系统和框架里都有实现，比如 Node.js 的事件处理，比如 Windows 程序的消息循环，再比如 OSX/iOS 里的 RunLoop，安卓里面的 Looper 机制。实现这种模型的关键点在于：如何管理事件/消息，如何让线程在没有处理消息时休眠以避免资源占用、在有消息到来时立刻被唤醒。

#### 3. iOS 中 Runloop
RunLoop 实际上就是一个对象，这个对象管理了其需要处理的事件和消息，并提供了一个入口函数来执行上面 Event Loop 的逻辑。线程执行了这个函数后，就会一直处于这个函数内部 “接受消息->等待->处理” 的循环中，直到这个循环结束（比如传入 quit 的消息），函数返回。

OSX/iOS 系统中，提供了两个这样的对象：NSRunLoop 和 CFRunLoopRef。
CFRunLoopRef 是在 CoreFoundation 框架内的，它提供了纯 C 函数的 API，所有这些 API 都是线程安全的。
NSRunLoop 是基于 CFRunLoopRef 的封装，提供了面向对象的 API，但是这些 API 不是线程安全的。

### 二、RunLoop 与线程的关系

一些线程执行的任务是一条直线，起点到终点；而另一些线程要干的活则是一个圆环，不断循环，直到通过某种方式将它终止。比如，简单的 Hello World就是一种直线执行的线程，一旦执行完毕，它的生命周期便结束了，像昙花一现那样；而像 iOS 应用的主线程那样的圆形线程 ，一直运行直到退出应用。
在 iOS 中，圆形的线程就是通过 Runloop 不停的循环实现的。

实际上，run loop和线程是紧密相连的，可以这样说run loop是为了线程而生，没有线程，它就没有存在的必要。Run loops是线程的基础架构部分，Cocoa和CoreFundation都提供了run loop对象方便配置和管理线程的run loop。每个线程，包括程序的主线程（main thread）都有与之相应的run loop对象。

主线程的 run loop 默认是启动的。对其它线程来说，run loop 默认是没有启动的。另外，苹果不允许直接创建 RunLoop，不过我们可以通过：
```
NSRunLoop *runloop = [NSRunLoop currentRunLoop];
```
来获取到当前线程的 run loop。

从 CFRunLoopRef 的源码可以看出，线程和 RunLoop 之间是一一对应的，其关系是保存在一个全局的 Dictionary 里。线程刚创建时并没有 RunLoop，如果你不主动获取，那它一直都不会有。RunLoop 的创建是发生在第一次获取时，RunLoop 的销毁是发生在线程结束时。你只能在一个线程的内部获取其 RunLoop（主线程除外）。


### 三、RunLoop 的构成

#### 1. RunLoop 的 Mode


#### 2. CFRunLoopTimer

#### 3. CFRunLoopSource

#### 4. CFRunLoopObserver

### 四、Runloop 的运行逻辑


### 五、RunLoop 的底层实现


###  六、Runloop 都做了些什么
AutoreleasePool
事件响应
手势识别
界面更新
定时器
PerformSelecter
关于GCD
关于网络请求

### 七、Runloop 在实际开发中的应用（When and How）

#### 1. 以+ scheduledTimerWithTimeInterval...的方式触发的timer，在滑动页面上的列表时，timer会暂定回调，为什么？如何解决？

一个 Timer 一次只能加入到一个 RunLoop 中。我们日常使用的时候，通常就是加入到当前的 runLoop 的 default mode 中，而 ScrollView 在用户滑动时，主线程 RunLoop 会转到 UITrackingRunLoopMode 以保证 ScrollView 的流畅滑动：只能在NSDefaultRunLoopMode 模式下处理的事件会影响ScrollView的滑动。因此这个时候， Timer 就不会运行。

有如下两种解决方案：

第一种: 设置RunLoop Mode，例如NSTimer,我们指定它运行于 NSRunLoopCommonModes ，这是一个Mode的集合。注册到这个 Mode 下后，无论当前 runLoop 运行哪个 mode ，事件都能得到执行。
第二种: 另一种解决Timer的方法是，我们在另外一个线程执行和处理 Timer 事件，然后在主线程更新UI。

在 AFNetworking 3.0 中，就采用了第一种方法，代码如下：

```
- (void)startActivationDelayTimer {
    self.activationDelayTimer = [NSTimer
    timerWithTimeInterval:self.activationDelay target:self selector:@selector(activationDelayTimerFired) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.activationDelayTimer forMode:NSRunLoopCommonModes];
}
```



### 参考
- [并发编程 - obj.io](https://www.objc.io/issues/2-concurrency/)
- [Threading Programming Guide](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)
- [《招聘一个靠谱的iOS》面试题参考答案（下）](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01《招聘一个靠谱的iOS》面试题参考答案/《招聘一个靠谱的iOS》面试题参考答案（下）.md)
- [Objective-C之run loop详解](http://blog.csdn.net/wzzvictory/article/details/9237973)
- [深入理解RunLoop](https://blog.ibireme.com/2015/05/18/runloop/)
- [CFRunLoop](https://github.com/ming1016/study/wiki/CFRunLoop)
- [深入研究 Runloop 与线程保活](https://bestswifter.com/runloop-and-thread/)
- [RunLoop的前世今生](https://www.gaoshilei.com/2016/11/20/RunLoop/)
- [Runloop - 笔试面试知识整理](https://hit-alibaba.github.io/interview/iOS/ObjC-Basic/Runloop.html)
