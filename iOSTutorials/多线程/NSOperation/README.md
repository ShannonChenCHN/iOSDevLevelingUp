
# NSOperation


### 简介
后台异步执行任务一般有 GCD 和 NSOperation 这两种选择。
相对于GCD来说，NSOperaton 提供的是面向对象的方式，可控性更强，并且可以加入操作依赖。NSOperation 和 NSOperationQueue 实际上是在 GCD 的基础上构建的。

### 任务、线程和进程

- 进程（process）：指的是一个正在运行中的可执行文件。每一个进程都拥有独立的虚拟内存空间和系统资源，包括端口权限等，且至少包含一个主线程和任意数量的辅助线程。另外，当一个进程的主线程退出时，这个进程就结束了；
- 线程（thread）：指的是一个独立的代码执行路径，也就是说线程是代码执行路径的最小分支。在 iOS 中，线程的底层实现是基于 POSIX threads API 的，也就是我们常说的 pthreads ；
- 任务（task）：指的是我们需要执行的工作，是一个抽象的概念，用通俗的话说，就是一段代码。

![](https://koenig-media.raywenderlich.com/uploads/2012/08/Process_Thread_Task.png)

一个进程可以包含几个不同线程，一个线程可以同时执行多个不同的任务。
主线程一般执行 UI 相关的任务，子线程中执行一些比较耗时的任务，比如读取文件、网络请求。

> iOS 中多线程编程的几种方式：
> - POSIX Threads API（pthreads）
> - GCD
> - NSOperation
> - NSThread

### NSOperation 和 GCD 的对比
- GCD：轻量好用，但是不方便暂停、取消任务，以及控制任务之间的依赖，
- NSOperation：弥补了 GCD 的缺点，提供了更高层次的 API，但是使用起来却更复杂

### 什么是 NSOperation？
NSOperation是一个抽象的基类，表示一个独立的计算单元，可以为子类提供有用且线程安全的建立状态，优先级，依赖和取消等操作。

NSOperation 的 3 种使用形式
- NSBlockOperation
- NSInvocationOperation
- 自定义 NSOperation 子类

### NSOperation 的应用场景
很多执行任务类型的案例都很好的运用了NSOperation，包括网络请求，图像压缩，自然语言处理或者其他很多需要返回处理后数据的、可重复的、结构化的、相对长时间运行的任务。

### NSOperationQueue 与 NSOperation 的结合使用
- 优先级：NSOperationQueue 控制着这些并行操作的执行，它扮演者优先级队列的角色，让它管理的高优先级操作(NSOperation -queuePriority)能优先于低优先级的操作运行的情况下，使它管理的操作能基本遵循先进先出的原则执行。

- 最大并发数：在你设置了能并行运行的操作的最大值(maxConcurrentOperationCount)之后，NSOperationQueue还能并行执行操作。

- 启动 operation：让一个NSOperation操作开始，你可以直接调用-start，或者将它添加到NSOperationQueue中，添加之后，它会在队列排到它以后自动执行。

### 如何实现 NSOperation 子类

#### 1. 状态的管理

NSOperation包含了一个十分优雅的状态机来描述每一个操作的执行。

> isReady → isExecuting → isFinished

- NSOperation提供了isReady, isCancelled, isExecuting, isFinished这几个状态变化，我们在使用时也必须处理自己关心的其中的状态。这些状态都是基于keypath的KVO通知决定，所以在你手动改变自己关心的状态时，请别忘了手动发送通知。
- 每一个属性对于其他的属性必须是互相独立不同的，也就是同时只可能有一个属性返回YES，从而才能维护一个连续的状态：
  - isReady: 返回 YES 表示操作已经准备好被执行, 如果返回NO则说明还有其他没有先前的相关步骤没有完成。
  - isExecuting: 返回YES表示操作正在执行，反之则没在执行。
  - isFinished : 返回YES表示操作执行成功或者被取消了（**注意：NSOperationQueue只有当它管理的所有操作的isFinished属性全标为YES以后操作才停止出列，也就是队列停止运行，所以正确实现这个方法对于内存管理和避免死锁很关键。**）


#### 2. 启动、暂停和取消操作

##### 2.1 启动
（1）手动调用 start 方法
我们直接通过调用 start 方法来执行一个 operation ，但是这种方式并不能保证 operation 是异步执行的。NSOperation 类的 isConcurrent 方法的返回值标识了一个 operation 相对于调用它的 start 方法的线程来说是否是异步执行的。在默认情况下，isConcurrent 方法的返回值是 NO ，也就是说会阻塞调用它的 start 方法的线程。

如果我们想要自定义一个并发执行的 operation ，那么我们就必须要编写一些额外的代码来让这个 operation 异步执行。比如，为这个 operation 创建新的线程、调用系统的异步方法或者其他任何方式来确保 start 方法在开始执行任务后立即返回。

（2）添加到 queue 中后自动启动
我们一般是通过将 operation 添加到一个 operation queue 的方式来执行 operation 的，operation 被添加到 queue 中后，就会在队列中自动排队等待执行。

在绝大多数情况下，我们都不需要去实现一个并发的 operation 。如果我们一直是通过将 operation 添加到 operation queue 的方式来执行 operation 的话，我们就完全没有必要去实现一个并发的 operation 。因为，**当我们将一个非并发的 operation 添加到 operation queue 后，operation queue 会自动为这个 operation 创建一个线程。**因此，只有当我们需要手动地执行一个 operation ，又想让它异步执行时，我们才有必要去实现一个并发的 operation 。

（3） start 方法和 main 方法

start ：start 方法是一个 operation 的起点。这个方法的默认实现是更新 operation 的状态并调用 main 方法。这个方法的内部在执行任务前会检查  cancelled 和 finished 的值，以确保任务需要被执行。
所有并发执行的 operation 都必须要重写这个方法，并替换掉 NSOperation 类中的默认实现。需要特别注意的是，在我们重写的 start 方法中一定不要调用 super。我们可以在这里配置任务执行的环境，另外，还要记得追踪 operation 的状态，并且进行合适的状态切换。
在任务执行完毕后，我们需要手动触动 isExecuting 和 isFinished 的 KVO 通知。


main ：负责执行 operation 对象中的非并发部分的操作，非必须实现。通常这个方法就是专门用来实现与该 operation 相关联的任务的。尽管我们可以直接在 start 方法中执行我们的任务，但是用 main 方法来实现我们的任务可以使设置代码和任务代码得到分离，从而使 operation 的结构更清晰。
这个方法的默认实现什么都没有做，我们在重写时，不要调用 super。


##### 2.2 暂停和恢复

如果我们想要暂停和恢复执行 operation queue 中的 operation ，可以通过调用 operation queue 的 setSuspended: 方法来实现这个目的。不过需要注意的是，暂停执行 operation queue 并不能使正在执行的 operation 暂停执行，而只是简单地暂停调度新的 operation 。另外，我们并不能单独地暂停执行一个 operation ，除非直接 cancel 掉。

##### 2.3 取消
- 当 NSOperation 的 -cancel 方法被调用的时候，会通过 KVO 通知 isCancelled 的 keypath 来修改 isCancelled 属性的返回值，NSOperation 需要尽快地清理一些内部细节，而后到达一个合适的最终状态。这个时候 isCancelled 和 isFinished 的值将是YES，而isExecuting的值则为NO。
- 值得注意的是，-cancel 方法被调用的时候，操作并没有直接被取消。
  - 如果这个操作在队列中没有执行，那么这个时候取消并将状态finished设置为YES，那么这个时候的取消就是直接取消了。
  - 如果这个操作已经在执行了，当我们调用cancel方法的时候，只是将isCancelled设置为YES，那么我们只能等其操作完成。
  - 所以，我们应该在每个操作开始前，或者在每个有意义的实际操作完成后，先检查下这个属性是不是已经被设置为YES，如果是YES，则后面操作都可以不用再执行了。比如 start 方法、main 方法以及 completionBlock 中，耗时比较长的循环中等。


#### 3. 优先级

通过设置 queuePriority 属性可以控制队列中操作执行的优先级：
- NSOperationQueuePriorityVeryHigh
- NSOperationQueuePriorityHigh
- NSOperationQueuePriorityNormal
- NSOperationQueuePriorityLow
- NSOperationQueuePriorityVeryLow

queuePriority 属性决定队列中操作相互之间的依赖关系，因此使用 queuePriority 的前提是没有通过 addDependency 方法设置过操作之间的 dependency


#### 4. 依赖性

当一个任务需要在另一个任务执行完后在执行时，可以通过设置任务之间的 dependency 关系来实现。

比如说，对于服务器下载并压缩一张图片的整个过程，你可能会将这个整个过程分为两个操作（可能你还会用到这个网络子过程再去下载另一张图片，然后用压缩子过程去压缩磁盘上的图片）。显然图片需要等到下载完成之后才能被调整尺寸，所以我们定义网络子操作是压缩子操作的依赖，通过代码来说就是：
```
[resizingOperation addDependency:networkingOperation];
[operationQueue addOperation:networkingOperation];
[operationQueue addOperation:resizingOperation];
```
注意点：
- 在每个操作完成时，请将i sFinished 设置为YES，不然后续依赖的操作是不会开始执行的。
- 时时牢记将所有的依赖关系添加到操作队列很重要。？？？
- 确保不要意外地创建依赖循环，像A依赖B，B又依赖A，这也会导致杯具的死锁。


#### 5. completionBlock

每当一个NSOperation执行完毕或者被取消，它就会调用它的completionBlock属性一次，这提供了一个非常好的方式让你能在视图控制器(View Controller)里或者模型(Model)里加入自己更多自己的代码逻辑。比如说，你可以在一个网络请求操作的completionBlock来处理操作执行完以后从服务器下载下来的数据。

注意：completionBlock 被回调时，不能确保是在主线程，所以需要你自己控制是否回到主线程。


### 如何自定义 NSOperation

我们可以通过重写 main 或者 start 方法 来定义自己的 operations 。

使用 main 方法非常简单，开发者不需要管理一些状态属性（例如 isExecuting 和 isFinished），当 main 方法返回的时候，这个 operation 就结束了。这种方式使用起来非常简单，但是灵活性相对重写 start 来说要少一些，**因为main方法执行完就认为operation结束了，所以一般可以用来执行同步任务。**

如果你希望拥有更多的控制权，或者想在一个操作中可以执行异步任务，那么就重写 start 方法, 但是注意：这种情况下，你必须手动管理操作的状态， 只有当发送 isFinished 的 KVO 消息时，才认为是 operation 结束。

**当实现了start方法时，默认会执行start方法，而不执行main方法。**

为了让操作队列能够捕获到操作的改变，需要将状态的属性以配合 KVO 的方式进行实现。如果你不使用它们默认的 setter 来进行设置的话，你就需要在合适的时候发送合适的 KVO 消息。
需要手动管理的状态有：
- isExecuting 代表任务正在执行中
- isFinished 代表任务已经执行完成
- isCancelled 代表任务已经取消执行

为了能使用操作队列所提供的取消功能，你需要在适当的时机检查 isCancelled 属性。

### 总结

我们应该尽可能地直接使用队列而不是线程，让系统去与线程打交道，而我们只需定义好要调度的任务就可以了。一般情况下，我们也完全不需要去自定义一个并发的 operation ，因为在与 operation queue 结合使用时，operation queue 会自动为非并发的 operation 创建一个线程。Operation Queues 是对 GCD 面向对象的封装，它可以高度定制化，对依赖关系、队列优先级和线程优先级等提供了很好的支持，是我们实现复杂任务调度时的不二之选。

### 参考

- http://nshipster.cn/nsoperation/
- http://www.jianshu.com/p/a044cd145a3d
- https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift
- https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html#//apple_ref/doc/uid/TP40008091-CH101-SW16
- http://blog.leichunfeng.com/blog/2015/07/29/ios-concurrency-programming-operation-queues/
- https://blog.cnbluebox.com/blog/2014/07/01/cocoashen-ru-xue-xi-nsoperationqueuehe-nsoperationyuan-li-he-shi-yong/
- https://stackoverflow.com/a/4300849
- https://github.com/AFNetworking/AFNetworking/blob/2.x/AFNetworking/AFURLConnectionOperation.m


