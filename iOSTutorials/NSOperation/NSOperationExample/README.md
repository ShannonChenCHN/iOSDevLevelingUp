
# NSOperation


### 简介
后台异步执行任务一般有 GCD 和 NSOperation 这两种选择。
相对于GCD来说，NSOperaton 提供的是面向对象的方式，可控性更强，并且可以加入操作依赖。

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


#### 2. 取消操作

- 当 NSOperation 的 -cancel 方法被调用的时候，会通过 KVO 通知 isCancelled 的 keypath 来修改 isCancelled 属性的返回值，NSOperation 需要尽快地清理一些内部细节，而后到达一个合适的最终状态。这个时候 isCancelled 和 isFinished 的值将是YES，而isExecuting的值则为NO。
- 值得注意的是，-cancel 方法被调用的时候，操作并没有直接被取消。
  - 如果这个操作在队列中没有执行，那么这个时候取消并将状态finished设置为YES，那么这个时候的取消就是直接取消了。
  - 如果这个操作已经在执行了，当我们调用cancel方法的时候，只是将isCancelled设置为YES，那么我们只能等其操作完成。
  - 所以，我们应该在每个操作开始前，或者在每个有意义的实际操作完成后，先检查下这个属性是不是已经被设置为YES，如果是YES，则后面操作都可以不用再执行了。


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
- 除非一个操作的依赖的isFinished返回YES，不然这个操作不会开始
- 时时牢记将所有的依赖关系添加到操作队列很重要
- 确保不要意外地创建依赖循环，像A依赖B，B又依赖A，这也会导致杯具的死锁。


#### 5. completionBlock








https://www.appcoda.com/ios-concurrency/

http://nshipster.cn/nsoperation/


http://www.jianshu.com/p/a044cd145a3d
