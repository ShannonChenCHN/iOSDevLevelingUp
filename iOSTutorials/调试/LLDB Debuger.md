# LLDB Debuger

## 一、基础
1. 帮助命令

`help`


2. 打印对象和简单类型，并使用 expression 命令在调试器中修改它们

`print`、`p`


`expression`、`e`、`po`


`print/<fmt>`、`p/<fmt>`

>  LLDB 的命名空间：任何以美元符开头的东西都是存在于 LLDB 的命名空间的，它们是为了帮助你进行调试而存在的。


3. 声明变量

```
(lldb) e int $a = 2
(lldb) p $a * 19
38
(lldb) e NSArray *$array = @[ @"Saturday", @"Sunday", @"Monday" ]
(lldb) p [$array count]
2
```

4. 流程控制

4.1 continue

`process continue`，`continue`，`c`

4.2 step over

`thread step-over`，`next`，或者 `n` 命令

4.3 step into

`thread step-in`，`step`，或者 `s` 命令

4.4 step out

`thread step-out`，`finish`

4.5 查看栈帧信息（frame 命令）

```
(lldb) frame info
frame #0: 0x0000000100000deb LLDBDebuggerExample`main(argc=1, argv=0x00007ffeefbff5e8) at main.m:29
(lldb) 
```

4.6 Thread Return

调试时，还有一个很棒的函数可以用来控制程序流程：thread return 。它有一个可选参数，在执行时它会把可选参数加载进返回寄存器里，然后立刻执行返回命令，跳出当前栈帧。这意味这函数剩余的部分不会被执行。

```
(lldb) p i
(int) $0 = 99
(lldb) s
(lldb) thread return NO
(lldb) n
(lldb) p even0
```

## 二、断点


1. 管理断点

- 断点导航面板
- LLDB 命令
  - breakpoint list
  - breakpoint enable <breakpointID> 和 breakpoint disable <breakpointID>

2. 创建断点
 
2.1 基础

- 在编辑区域通过可视化操作设置断点
- 要在 LLDB 调试器中创建断点，可以使用 `breakpoint set` 命令。

2.2 条件断点

- 在编辑区域通过可视化操作设置条件断点
- `breakpoint modify -c '<expr>' <breakpoint_id>`，例如，`breakpoint modify -c 'i == 99' 1`

2.3 断点行为

- Shell Command
- Log Message
- Debugger Command


2.4 符号断点

- 通过在断点导航面板底部 “＋” 选择 “Symbolic Breakpoint”，设置符号断点
- 也可以在一个符号 (Symbolic breakpoint，C 语言函数) 上创建断点，而完全不用指定哪一行：`br s -F isEven`，`breakpoint set -F "-[NSArray objectAtIndex:]"`

2.5 异常断点

- 通过在断点导航面板底部 “＋” 选择 “Exception Breakpoint”，设置符号断点


2.6 通过 `bt` 命令查看当前线程的函数堆栈信息

```
(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 2.1 3.1
  * frame #0: 0x0000000103bc86cf LLDBDebuggerPlayground`-[ViewController didSelectButton:](self=0x00007f826a40d170, _cmd="didSelectButton:", sender=0x00007f826a602bb0) at ViewController.m:24
    frame #1: 0x0000000104d70275 UIKit`-[UIApplication sendAction:to:from:forEvent:] + 83
    frame #2: 0x0000000104eed4a2 UIKit`-[UIControl sendAction:to:forEvent:] + 67
    frame #3: 0x0000000104eed7bf UIKit`-[UIControl _sendActionsForEvents:withEvent:] + 450
    frame #4: 0x0000000104eec6ec UIKit`-[UIControl touchesEnded:withEvent:] + 618
    frame #5: 0x0000000104de5bbb UIKit`-[UIWindow _sendTouchesForEvent:] + 2807
    frame #6: 0x0000000104de72de UIKit`-[UIWindow sendEvent:] + 4124
    frame #7: 0x0000000104d8ae36 UIKit`-[UIApplication sendEvent:] + 352
    frame #8: 0x00000001056cd434 UIKit`__dispatchPreprocessedEventFromEventQueue + 2809
    frame #9: 0x00000001056d0089 UIKit`__handleEventQueueInternal + 5957
    frame #10: 0x0000000107647231 CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 17
    frame #11: 0x00000001076e6e41 CoreFoundation`__CFRunLoopDoSource0 + 81
    frame #12: 0x000000010762bb49 CoreFoundation`__CFRunLoopDoSources0 + 185
    frame #13: 0x000000010762b12f CoreFoundation`__CFRunLoopRun + 1279
    frame #14: 0x000000010762a9b9 CoreFoundation`CFRunLoopRunSpecific + 409
    frame #15: 0x0000000109e129c6 GraphicsServices`GSEventRunModal + 62
    frame #16: 0x0000000104d6e5e8 UIKit`UIApplicationMain + 159
    frame #17: 0x0000000103bc878f LLDBDebuggerPlayground`main(argc=1, argv=0x00007ffeec037088) at main.m:14
    frame #18: 0x00000001087d0d81 libdyld.dylib`start + 1
    frame #19: 0x00000001087d0d81 libdyld.dylib`start + 1
```

`bt all` 可以达到一样的效果，区别在于会打印全部线程的状态，而不仅是当前的线程。


## 三、高级技巧

1. 不用断点调试

程序运行时，点击 Xcode 调试条上的暂停按钮暂停 app (这会运行 process interrupt 命令，因为 LLDB 总是在背后运行)。

除了全局变量外，此时没有太多变量可以访问。


我们可以直接直接把已知对象的地址赋值给一个新定义的变量来使用，因为一般引用对象的这个变量都是指针类型（我猜的~）：
```
    (lldb) po [[[UIApplication sharedApplication] keyWindow] recursiveDescription]
<UIWindow: 0x7f82b1fa8140; frame = (0 0; 320 568); gestureRecognizers = <NSArray: 0x7f82b1fa92d0>; layer = <UIWindowLayer: 0x7f82b1fa8400>>
   | <UIView: 0x7f82b1d01fd0; frame = (0 0; 320 568); autoresize = W+H; layer = <CALayer: 0x7f82b1e2e0a0>>
   
   (lldb) e id $myView = (id)0x7f82b1d01fd0
```

2. 查看 view 层级

```
(lldb) po [[[UIApplication sharedApplication] keyWindow] recursiveDescription]
```

3. 更新 UI

当我们在调试器中通过 expression 命令修改了 view 的外观后，并不能马上看到修改后的效果，只有程序继续运行之后才会看到界面的变化。因为改变的内容必须被发送到渲染服务中，然后显示才会被更新。

渲染服务实际上是一个另外的进程 (被称作 backboardd)。这就是说即使我们正在调试的内容所在的进程被打断了，backboardd 也还是继续运行着的。

这意味着你可以运行下面的命令，而不用继续运行程序：

```
(lldb) e (void)[CATransaction flush]
```

使用示例：

```
(lldb) e (void)[$myView setBackgroundColor:[UIColor blueColor]]
(lldb) e (void)[CATransaction flush]
```


## 四、Chisel 工具

## 五、LLDB 和 Python

### 参考
- [How debuggers work: Part 1 - Basics](https://eli.thegreenplace.net/2011/01/23/how-debuggers-work-part-1.html)（[中文翻译](http://blog.jobbole.com/23463/)）
- [与调试器共舞 - LLDB 的华尔兹 - objc.io](https://www.objccn.io/issue-19-2/)
- [调试：案例学习 - objc.io](https://www.objccn.io/issue-19-1/)
- [The LLDB Debugger](http://lldb.llvm.org/)
- [NSLog效率低下的原因及尝试lldb断点打印Log - sunnyxx 的博客](http://blog.sunnyxx.com/2014/04/22/objc_dig_nslog/)
- [使用LLDB调试Swift](http://www.infoq.com/cn/news/2017/10/LLDB-debug-Swift)（[原文](https://medium.com/flawless-app-stories/debugging-swift-code-with-lldb-b30c5cf2fd49)）
- [Chisel-LLDB命令插件，让调试更Easy - 刘坤的技术博客](https://blog.cnbluebox.com/blog/2015/03/05/chisel/)
- [LLDB调试器使用简介 - 南峰子的技术博客](http://southpeak.github.io/2015/01/25/tool-lldb/)