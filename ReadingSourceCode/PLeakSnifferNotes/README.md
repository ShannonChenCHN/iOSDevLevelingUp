# PLeakSniffer

## 基本思想
跟微信读书开源的 MLeaksFinder 的核心思想一致，PLeakSniffer 的实现也是基于以下这些假设：             
- 大多数情况下，Controller 就是一个根节点，持有并管理着很多子节点对象，这些子节点对象的生命周期都依赖于 Controller。
- Controller 要么是被另一个 Controller present 出来，然后被 dismiss，要么就是被UINavigationController push 到栈顶，然后被 pop 出栈。
- 如果Controller 被释放了，但其曾经持有过的子对象如果还存在，那么这些子对象就是泄漏的可疑目标。


## 主要原理


![](http://www.mrpeak.cn/images/sniffer2.png)

给每个对象绑定一个 weak 引用的 proxy 对象（理论上该 proxy 对象会跟着宿主对象一起销毁），然后用一个单例对象每隔一段时间就发出一个 ping 通知，如果宿主对象应当被销毁但是实际上却没有被销毁（出现了内存泄漏），那么其绑定的 proxy 对象就能响应 ping 通知——发出一个 pong 通知。

## 一些细节

1. 什么时候去给要监听的对象绑定一个 proxy 对象呢？

理论上来讲，给要监听的对象绑定一个 proxy 对象的最好时机，是在宿主对象被创建的时候。但是，一般情况下，Controller 是作为根节点的角色出现的，所以我们只需要从 Controller 入手，而且我们在创建了 Controller 之后，要么通过 push、要么通过 present 来展示这个新建的 Controller 对象。

因此，对于 Controller 类型的对象来说，PLeakSniffer 是在 Controller 对象被 push 或者 present 时，为其绑定了一个 weak 引用的 proxy 对象。

对于 Controller 对象的属性，PLeakSniffer 是在 Controller 对象的 viewDidAppear 方法被调用时才去为其属性绑定 proxy 对象的。

2. 如何判断被监听的对象是否应该被销毁（invalid）？

对于 UIViewController 对象，理论上只能以下三种情况才能存活：        
- window 上的 rootController
- 存在 navigation Controller 的栈中
- 被 present 出来时

对于 UIView 及其子类的对象，如果它还在 view 层级中或者被 Controller 持有的，就说明还处于正常的生命周期。

对于 NSObject 子类的对象，如果它被 view 或者 Controller 持有，就说明还处于正常的生命周期。
