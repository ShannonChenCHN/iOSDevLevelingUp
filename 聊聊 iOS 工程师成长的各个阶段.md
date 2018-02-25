# 聊聊 iOS 工程师成长的各个阶段

深度和广度，擅长的领域
学习模式
方法论

### 1. 入门到 1 年以内

#### 技术和能力
- C 语言
- 对基础的 Objective-C 语法都要过一遍
- 把 Foundation 和 UIKit 框架中的常用 API 都学一遍，如 UIViewController / UIView / UIScrollView / UIImageView / UITableView
- 对于实现一个 APP 需要的基础知识有所了解：内存管理，block，网络请求，数据存储，多线程
- 还有一些跟事件传递相关的基础概念，比如 KVO / MVC / Delegate / DataSource
- 知道如何使用 MVC 开发
- 能按照代码规范去写代码

#### 工具
- Git，SVN
- Charles
- Reveal

#### 书籍
- C 程序设计语言
- Objective-C 程序设计
- Objective-C Programming（Big Nerd Ranch）
- iOS Programming（Big Nerd Ranch）
- 苹果官方教程 Start Developing iOS Apps Today
- 斯坦福的公开课

#### 学习手段
- 最开始以视频教程为主
- 书本结合
- 中文博客为主
- 官方文档

#### 输出
- 大量练习
- 记笔记



### 2. 一到两年

#### 技术和能力
- 在工作中实践，并且更加深入的了解 Objective-C 基础
- 更深刻地理解面向对象，了解 POP，AOP
- 会使用 CocoaTouch 框架中的各种 API
- 会查阅官方文档
- 会通过 Stack Overflow、google 查找问题的答案
- 对于常用的设计模式、内存管理、Blocks 的使用、图像操作、网络请求和管理、多线程应该比较熟悉了，而不再仅仅是了解
- 对于 CALayer、Animation、UIScrollView、UITableView、UICollectionView、ViewController Container 则非常熟悉，对「非常熟悉」的定义是：不打开 Xcode，脑子里就能把相应的知识点复述出来 80% ，比如这个类有哪些方法，Delegate / DataSource 有哪些方法，怎么使用，如果要实现某个效果，应该怎么做
- 会自己封装一些小控件
- 知道如何去设计 API
- 对前端和服务端开发等其他技术栈有所接触

#### 工具
- chisel Facebook 出品的 LLDB 助手，用于调试很方便
- class-dump
- Hopper
- Instruments

#### 书籍
- Effective Objective-C 2.0  这本书肯定要看
- 《Objective-C 高级编程》这本书也是一定要看的
- objc-zen-book 也值得推荐
- iOS 开发进阶

#### 其他资源
- 订阅一些优质资源，比如 objc.io，NSHipster，RayWenderlich，iOS Dev Weekly
- 还有一些大 v 的博客和公众号
- WWDC
- 阅读官方文档成为常态
- 英文文章
- GitHub 开源代码

#### 输出
- 能够写一些比较正式的文章，能够比较系统地描述自己是如何解决一个问题和实现一个功能的
- 有自己的开源项目
- 内部分享

### 3. 两到三年

#### 技术和能力

如果你是非计算机专业的，估计就会遇到瓶颈了，这个时候基础知识就显得很重要，不太了解的就需要补一补了：

- 算法和数据结构
- 网络、HTTP、TCP/IP
- 计算机系统原理
- 对架构和设计模式都有更加深入和全面的了解
- MVC、MVP、MVVM、VIPER
- 数据库

除此之外，在深度方面也应该更进一步：

- Runloop
- 对于底层的实现会有更深入的了解，对于你所使用的框架也应该有了更深入的了解
- 各种 Core 开头的 Framework 至少可以说出个大概
- 熟练使用各种工具
- 正经的代码写过数万行
- 文档都翻烂了
- 如果别人让你实现某个功能，能说出业界都是怎么做的，能在较短的时间内给出不错的实现方案，并且足够细致，甚至精细到如何使用 Core Graphic 去画某个图像
- 能够独立设计一个缓存系统、列表框架、网络层等等这样的完整系统
- 有自己的解决问题的方法论和靠谱的学习方法

在广度方面：

- 前端
- 服务端
- 其他语言

在编码实践方面：

- 代码能力明显提升，能写出一手优雅的代码
- 随着解决难题的经验越来越丰富，开始能很快定位问题，并解决问题

#### 书籍
- Objective-C 编程之道
- iOS 7 Programming Pushing the Limits
- iOS Core Animation Advanced Techniques 
- 图解 HTTP
- 图解 TCP/IP
- 网络是怎样连接的
- 数据结构和算法分析
- 程序员的自我修养
- 程序是怎样跑起来的
- 计算机是怎样跑起来的


#### 其他资源
- 读过一些常用框架的源码以及 Apple 官方开源过的源码
  - 第三方
     - AFNetworking
     - SDWebImage
     - Mantle
     - MBProgressHUD
     - YTKNetwork
     - MJRefresh
     - WebViewJavaScriptBridge
     - Aspects
  - Apple 官方开源
     - runtime
     - Core Fundation

#### 输出
- 博客输出已成为常态
- 大量造轮子
- 能够独立设计一个缓存系统、列表框架这样的完整框架，GitHub 上至少有一个 star 数过百的开源项目
- 参与过别人的优秀开源项目
- 正式的分享会

### 3 到 5 年

- 基础知识不论何时都需要补
- 对架构应该是有自己的独到见解了
- 随便说一个功能点，能说的上可能涉及到那些技术点，会遇到什么坑，业界各大厂都是怎么做的，各个方案的优缺点是什么
- 有自己擅长的领域，比如架构，音视频，图像处理等
- 至少对某个技术有过深入研究，并且有自己的成果，可以称得上精通，也就是有自己的优势
- 软实力：团队协作能力、抗压能力、性格特征和心理成熟度、沟通能力、写作能力和表达能力
- 有自己的优势，有明显的差异性，也就是能别人所不能

### 总结

上面这些要求都是一家之言，仅仅是一个大概的总结，其实能力与年限的匹配并没有严格的区分，非得要求多少年经验就要具备什么能力。

> 我觉得无论学习什么，「速成」的心态是最要不得的，这只会让自己变得浮躁，一知半解，整个过程也很难让自己的元学习能力得到提升。慢慢来，攻占一个城后，再去打下一个，这时心态也会平和许多。

就像 Limboy 说的那样，速成的心态是最忌讳的，这样会很容易浮躁，结果什么都没有学到，走马观花一般。自己应该知道自己处于哪个阶段，应该掌握哪些知识，具备哪些能力，擅长哪些方面。只有脚踏实地，一步一个脚印才能走得稳，走得远。

### 参考：

- http://www.cnblogs.com/zuoxiaolong/p/life51.html
- http://limboy.me/tech/2014/12/31/learning-ios.html
- https://www.bignerdranch.com/blog/leveling-up/
- [iOS 开发技术栈与进阶](http://blog.cnbang.net/tech/3354/)
- [如何面试iOS工程师](http://blog.cnbang.net/internet/3245/)
- [程序员的成长阶梯和级别定义](https://mp.weixin.qq.com/s/9H2qCQG3Qy5SFiR8h9n2YQ)