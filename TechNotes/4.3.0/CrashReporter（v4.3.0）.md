# Crash Reporter


	
#### 1.崩溃监控的原理：

 - 监听崩溃，崩溃发生的原因有三类：
 	- 理论上应该可以 try-catch 到的、但没有处理的 UncaughtException：可以通过 NSSetUncaughtExceptionHandler() 注册监听异常
 	- 指针问题引发的崩溃：可以依赖 Linux/Unix 信号处理机制实现监听（`signal(int signo, void * handler)`和`sigaction(int signo, void handler, void pre_handler) `）
 	- 内存占用过高导致进程被系统杀掉：监听 didReceiveMemoryWarning 方法
 	
 - 采集崩溃信息：可以从监听函数的行参（NSException 对象）获取当前异常堆栈信息
 - 分析崩溃信息:对于 iOS 应用的崩溃堆栈，需要进行堆栈地址的符号化处理，这个处理过程使用系统的atos工具，借助iOS应用的符号调试信息文件dSYM 就可以完成。

#### 2.相关开源框架和平台：

开源框架：

- [KSCrash](https://github.com/kstenerud/KSCrash)：使用较广泛，现在仍然在维护中
- [PLCrashReporter](https://www.plcrashreporter.org)：很久不更新了

平台：

- [友盟统计](http://dev.umeng.com/analytics/reports/errors#2)
- [BugHUD](http://bughd.com/doc/index)（实际上就是用的 KSCrash 框架）
- [Crashlytics](http://try.crashlytics.com/)（Fabric）
- [Bugly](http://bugly.qq.com/)

#### 3.选用第三方平台的考察点：

	- 免费
	- 方便追踪和分析 bug
	- 不存在审核被拒风险
	
#### 4.第三方平台对比

|  | [Bugly](http://bugly.qq.com/) | [BugHUD](http://bughd.com/doc/index) |  [Crashlytics(Fabric)]((http://try.crashlytics.com/)) | [友盟](http://dev.umeng.com/analytics/reports/errors#2) |
| --------- | --- | -----| ---- | ---- |
| 简介 | 腾讯出品，在国内应用的比较多。Bugly 崩溃监控分析服务源于鹅厂内部，在经历通公司内终端应用的合作和持续打磨后，于2014年对外提供面向开发者的服务。Bugly的崩溃监控分析，除了关注崩溃捕获以外，还提供自动化堆栈解析，动态归类，实时统计，监控告警等功能，特有的ANR/卡顿监控分析，专属的游戏脚本错误监控分析和用户留存分析等功能。并且，Bugly服务平台持续开放更多研发流程相关的工具/服务给大家使用，诸如内测分发，CI等。 | fir.im 旗下产品，基于开源框架 KSCrash | Crashlytics国外知名的崩溃监控分析服务，被Twitter收购后并入Fabric服务，目前Fabric提供Answers(统计分析)、Beta(内测发布)、Crashlytics(崩溃监控)服务。崩溃问题的堆栈分析做的比较赞 | 国内移动统计分析服务平台，提供统计分析、更新，分享，推送等服务，其中，错误分析也是在统计分析的基础上添加。|
| 收费标准 | 免费  | 免费 | 免费 | 免费|
| 主要功能 | 监控崩溃、监控卡顿、上报错误、上报自定义日志、支持自定义标签、符号表管理| 监控崩溃、上报自定义异常 |  | |
|收集信息 | 崩溃次数、影响用户、app 版本、用户id、发生时间、机型、系统版本、出错堆栈、页面跟踪、跟踪日志、符号表  、自定义 log| 出错堆栈、崩溃次数、app 版本、发生时间、影响设备 |  | |
| 崩溃上报时机 | 上报卡顿：在App从后台切换到前台时，执行上报。上报崩溃：如果 crash 是发生在 SDK 初始化之前，发生崩溃会立即上报（猜测，待确认）。上报日志：默认值为BuglyLogLevelSilent，即关闭日志记录功能。如果设置为BuglyLogLevelWarn，则在崩溃时会上报Warn、Error接口打印的日志  | 发生崩溃会立即上报，如果上报不成功将会在在第二次启动时上报。 |  | |
| SDK 接入 | 支持 pod 安装，在application:didFinishLaunchingWithOptions: 方法中初始化 SDK，可添加自定义日志| 支持 pod 安装，在application:didFinishLaunchingWithOptions: 方法中初始化 SDK，可以设置自定义参数、Exception |  | |
| 使用体验 | 在后台能看到除了崩溃本身相关的信息之外、还有跟踪日志、页面浏览记录、使用时长等，自己上报错误日志 | 功能比较简单，虽然能看到跟每个崩溃相关的信息，但是维度单一 |  | |
|技术支持| 论坛、微信公众号、QQ 群 | 微博 |||
| 是否存在被拒风险 | 如果是热修复版本，意味着使用了 JSPatch |  |  | |
| 实现机制,能捕获哪些异常 | 注册监听 NSSetUncaughtExceptionHandler() 和 Linux/Unix 信号 | BugHD 通过注册 NSUnCaughtExceptionHandler 监听未被 try catch 的 Objective C(简称 OC)代码异常。 BugHD 通过注册 SIGABRT/SIGBUS/SIGFPE/SIGILL/SIGSEGV/SIGTRAP 几个 unix 信号，监听 C 代码引发的系统异常信号。 |  | N/A|
|FAQ | [常见问题汇总](http://bugly.qq.com/bbs/forum.php?mod=viewthread&tid=291&extra=page%3D1)，[iOS 常见问题](https://bugly.qq.com/docs/user-guide/faq-ios/?v=20170322165254)| | | |
|使用案例|QQ、微信、qq 音乐、美丽说||||
|SDK 大小|(55.2M - 48.2M) ≈ 7 M||||

整体来说，各个服务平台崩溃监控采集上报能力基本相当，不乏部分基于开源框架开发而来。
但崩溃监控分析服务，除了需要关注监控崩溃问题的场景数据以外，还需考量额外辅助信息的全面性，场景覆盖，实时性和分析统计的能力。

综合比较，Crashlytics 因为服务器在国外，所以不太稳定，暂不考虑；友盟是以统计业务为主的，crash 分析后台使用起来也比不太友好。
Bugly 相比 BugHD 和 友盟 的优点在于以下几个方面：
- 平台功能强大，除了跟踪 bug，还有上报自定义错误（日志）、异常，以及监控卡顿的功能。
- 收集的崩溃信息比较全面，除了崩溃本身的信息之外，还记录了一些页面信息、用户停留时长、跟踪日志等辅助信息，更利于定位问题。
- 在技术支持方面，Bugly 有专门的论坛、微信公众号和活跃的 QQ 群。
- 使用者广泛，腾讯自家的产品也在用，国内许多产品也选择 bugly。
- 技术实力上，腾讯有更强的技术储备和人力。
- 个人使用经历上，之前使用过 Bugly，通过 Bugly 来记录、分析崩溃和上传日志，感觉都还不错，具体有什么坑还没碰到过。没用过BugHD，但是看过 BugHD 的演示 Demo，比较简单，更多地是用来单纯查看 crash 记录的。

#### 5.问题

	5.1 Crash 堆栈不可读，需要上传符号表？
	上报的崩溃堆栈是应用部分只有地址信息的，需要配置符号表才能对上报的崩溃进行符号化，或者可以开启进程内还原。

	5.2 什么是符号表？
	iOS 的应用编译的时候生产的 dSYM 文件，一般在 build 目录下，名称为 *.app.dSYM 的一个目录。 BugHD 或者 bugly 会对这个符号表文件进行解析，取出有用的信息，得到一个较小的新符号表用于上传。
	

#### 6.崩溃预防措施：

- 记录每一次发生崩溃的原因，减少同样问题的重复发生
- [AvoidCrash](https://github.com/chenfanfang/AvoidCrash)
- 常见崩溃原因：
	- 数组越界
	- 内存溢出
	- 内存管理（访问已经释放掉的对象）
	- CPU 暴增
	- 未知选择器
	- API 不兼容
	- 处理字符串时索引越界
	- 传空值，比如往 NSDictionary 或者 NSArray 中插入 nil
	- 解析服务端返回的 JSON 数据后，出现 NSNull，间接引起的崩溃
	- block 回调时没有判空
	- [How Not to Crash](http://inessential.com/hownottocrash)
	- [iOS崩溃crash大解析](http://www.jianshu.com/p/1b804426d212)

#### 7.参考：

- [漫谈iOS Crash收集框架](https://nianxi.net/ios/ios-crash-reporter.html)


- [iOS 启动连续闪退保护方案](https://wereadteam.github.io/2016/05/23/GYBootingProtection/)
- [iOS开发技巧－崩溃调试](http://www.jianshu.com/p/77660e626874)
- [iOS Crash文件的解析](http://www.cnblogs.com/smileEvday/p/Crash1.html)
- [做一个 App 前需要考虑的几件事](http://limboy.me/tech/2016/07/06/starting-an-app.html)
- [移动开发之崩溃监控分析服务](https://mp.weixin.qq.com/s?__biz=MzIwMTQwNTA3Nw==&mid=402317533&idx=1&sn=37eefadfe316b8fc90864040fb5ca0b3&scene=1&srcid=0425oAcZTTkDUaHglFlqFtpQ&key=b28b03434249256b8137e5241f6eba74060807263aea8b493f5572765e6cb19c1d8bef0a6547ee98e5b437bee9555064&ascene=0&uin=MTIzNzM4NjQ2MQ%3D%3D&devicetype=iMac+MacBookPro9%2C2+OSX+OSX+10.10.5+build(14F1713)&version=11020201&pass_ticket=2wgjdLryUUo52ASfF6DaNPOQc2vVXFEUCZskzBjI5GHyvyMdAHNY1KQyxr3XvRm9)