# Advanced Apple Debugging & Reverse Engineering

这本书主要介绍了 LLDB 常用的调试命令、汇编语言、Ptrace、动态库、使用 Python 实现自定义 LLDB 命令以及 DTrace 等技术，个人认为前三个部分（Section）最重要，尤其是第二部分，非常推荐，还有第四部分的前两章关于自定义 LLDB 命令脚本的开发以及调试也值得学习一下，第四部分剩下的内容和第五部分只需要了解即可。


## 第一部分 LLDB 命令
### 1. Getting Started

#### 1.1 Disabling Rootless 

1. 重启 macOS；
2. 启动时按住 Command+R，进入 Recovery Mode；
3. 找到 Utilities 菜单，选择 terminal；
4. 执行 `csrutil disable; reboot`；
5. 测试一下：`lldb -n Finder`；


执行 `lldb -n Finder` 时，遇到两个 python 错误：
- NameError: name 'run_one_line' is not defined
  - 解决：执行 `easy_install six`
- ImportError:cannot import name_remove_dead_weakref
  - 原因：系统同时装了两个 python 2 
  - 解决：执行 brew remove python@2 --ignore-dependencies

#### 1.2 Attaching LLDB to Xcode

1. 打开终端，查看当前终端会话名：
```
~ $ tty
/dev/ttys027
```

2. 在终端上新开一个用于执行 LLDB 的 tab，用 LLDB 启动 Xcode（后面的 `-e /dev/ttys027 --` 表示将 `stderr` 输出到 `/dev/ttys027`）：

```
(lldb) file /Applications/Xcode.app/Contents/MacOS/Xcode
(lldb) process launch -e /dev/ttys027 --
```

3. 启动 Xcode 后，创建一个新项目。

延伸：
> 查看 Xcode10 App 是否使用了 Swift：
> ```
> (lldb) script print "\n".join([i.file.basename for i in lldb.target.modules if i.FindSection("__swift4_typeref")])
> ```


4. 在 LLDB 的 tab 上输入 `ctrl+C` 来暂停 debugger，并设置断点：
```
(lldb) b -[NSView hitTest:]
Breakpoint 1: where = AppKit`-[NSView hitTest:], address =
0x000000010338277b
```

5. 恢复 Xcode 的运行：
```
(lldb) continue
```

6. 点击 Xcode 上的面板，断点被触发，此时可以打印 `-[NSView hitTest:]` 的第一个参数：
```
(lldb) po $rdi
```

7. 修改断点：
```
breakpoint modify 1 -c '(BOOL)[$rdi isKindOfClass:(id)NSClassFromString(@"IDESourceEditor.IDESourceEditorView")]'
```

然后再重新执行 `continue`。

8. 点击代码编辑区，断点被触发，然后打印参数：
```
(lldb) po $rdi
 IDESourceEditorView: Frame: (0.0, 0.0, 1140.0, 393.0), Bounds: (0.0,
0.0, 1140.0, 393.0) contentViewOffset: 0.0
```

9. 打印参数的指针格式：
```
 (lldb) p/x $rdi
 (unsigned long) $3 = 0x00007f96f10b3a00
```

我们也可以直接通过访问地址来查看对象：
```
 (lldb) po 0x00007f96f10b3a00
  IDESourceEditorView: Frame: (0.0, 0.0, 1140.0, 393.0), Bounds: (0.0,
0.0, 1140.0, 393.0) contentViewOffset: 0.0
```

10. 现在可以通过下面的命令隐藏你的代码了（按下 Enter 键可以不断切换隐藏/显示，因为 Enter 键可以执行上一条命令）：

```
(lldb) po [$rdi setHidden:!(BOOL)[$rdi isHidden]]; [CATransaction flush]
```

### 2. Help & Apropos

#### 1.1 The "help" command

执行 `help` 命可以看到所有可用的 LLDB 命令：
```
(lldb) help
```

而且，所有可用的命令都有一些子命令，以 `breakpoint` 为例：
```
(lldb) help breakpoint

Commands for operating on breakpoints (see 'help b' for shorthand.)
Syntax: breakpoint
The following subcommands are supported:
  clear   -- Delete or disable breakpoints matching the specified
             source file and line.
  command -- Commands for adding, removing and listing LLDB commands
             executed when a breakpoint is hit.
  delete  -- Delete the specified breakpoint(s).  If no breakpoints are
             specified, delete them all.
  disable -- Disable the specified breakpoint(s) without deleting them.
             If none are specified, disable all breakpoints.
  enable  -- Enable the specified disabled breakpoint(s). If no
             breakpoints are specified, enable all of them.
  list    -- List some or all breakpoints at configurable levels of
             detail.
  modify  -- Modify the options on a breakpoint or set of breakpoints
             in the executable.  If no breakpoint is specified, acts on
             the last created breakpoint.  With the exception of -e, -d
             and -i, passing an empty argument clears the modification.
  name    -- Commands to manage name tags for breakpoints
  read    -- Read and set the breakpoints previously saved to a file
             with "breakpoint write".
  set     -- Sets a breakpoint or set of breakpoints in the executable.
  write   -- Write the breakpoints listed to a file that can be read in
             with "breakpoint read".  If given no arguments, writes all
             breakpoints.
For more help on any particular subcommand, type 'help <command>
<subcommand>'.
```


接下来，我们查看一下 `breakpoint name` 的文档：
```
(lldb) help breakpoint name

   Commands to manage name tags for breakpoints
Syntax: breakpoint name
The following subcommands are supported:
      add    -- Add a name to the breakpoints provided.
      delete -- Delete a name from the breakpoints provided.
      list   -- List either the names for a breakpoint or the breakpoints
for a given name.
For more help on any particular subcommand, type 'help <command>
<subcommand>'.
```


#### 1.2 The "apropos" command

`apropos` 命令就跟搜索引擎一样，你可以用它来根据关键字查询你想要的 LLDB 命令。


比如，我们搜索关键字 `swift`：
```
(lldb) apropos swift

The following commands may relate to 'swift':
  swift    -- A set of commands for operating on the Swift Language
Runtime.
  demangle -- Demangle a Swift mangled name
  refcount -- Inspect the reference count data for a Swift object
The following settings variables may relate to 'swift':
  target.swift-framework-search-paths -- List of directories to be
searched when locating frameworks for Swift.
  target.swift-module-search-paths -- List of directories to be searched
when locating modules for Swift.
  target.use-all-compiler-flags -- Try to use compiler flags for all
modules when setting up the Swift expression parser, not just the main
executable.
```

我们还可以用 `apropos` 命令来搜索“句子”，不过要用 `""` 将“句子”包起来，以 `reference count`为例：

```
(lldb) apropos "reference count"
The following commands may relate to 'reference count':
  refcount -- Inspect the reference count data for a Swift object
```

### 3. Attaching with LLDB

#### 3.1 Attaching to an existing process

最简单的方式是直接指定可执行文件的名称：
```
~ $ lldb -n Xcode
```

另一种方式是指定进程 ID：
```
~ $ pgrep -x Xcode
88398
~ $ lldb -p 88398
```


注：`-p` 表示使用 pid，`-n` 表示使用 executable name。

#### 3.2 Attaching to a future process


使用 `-w` 参数，可以让 LLDB 附加到一个将要开启的进程上，以 Finder 为例：
```
lldb -n Finder -w
```

然后再新开一个 tab，重启 Finder：
```
pkill Finder
```


延伸：
> 按下 `Ctrl+D` 组合键可以退出当前的 LLDB 会话。


还有另一种方式可以将 LLDB 绑定到一个将要开启的进程上，那就是先指定可执行文件的路径然后再启动进程：

```
lldb -f /System/Library/CoreServices/Finder.app/Contents/MacOS/Finder
(lldb) process launch
```

### 3.3 Options while launching


`process launch` 命令可以使用选项。

以 `ls` 为例：
```
~ $ lldb -f /bin/ls
(lldb) target create "/bin/ls"
Current executable set to '/bin/ls' (x86_64).
```

执行不带选项的 `process launch` 命令时：
```
(lldb) process launch
Process 47794 launched: '/bin/ls' (x86_64)
Applications	Downloads	Music		cache_dir
Desktop		Library		Pictures	development
Documents	Movies		Public
Process 47794 exited with status = 0 (0x00000000)
```

#### `-w` 选项

通过 `-w` 选项来指定启动进程的位置：
```
(lldb) process launch -w /Applications
```

上面的操作相当于：
```
$ cd /Applications
$ ls
```

#### `--` 选项

我们也可以直接传参数给要启动的程序：
```
 (lldb) process launch -- /Applications
```


上面的操作相当于：
```
$ ls /Applications
```

#### `-X` 选项

`-X` 选项可以帮你展开参数，比如 `~`：

```
(lldb) process launch -X true -- ~/Desktop
```


上面的命令有一个更短的快捷命令：`run`：
```
(lldb) run ~/Desktop
```

`run` 就相当于 `process launch -X true --`：

```
(lldb) help run
...
Command Options Usage:
  run [<run-args>]
'run' is an abbreviation for 'process launch -X true --'
```

#### `-e` 、 `-o` 和 `-i` 选项

`-e` 用来指定输出错误信息的位置 `stderr`。
`-o` 用来指定 `stdout` 输出的目标文件。
`-i` 用来指定 `stdin` 输出的目标文件。


### 4. Stopping in Code

#### 4.1 Unix 信号


#### 4.2 Xcode 断点

- Symbolic breakpoints
- Exception Breakpoint
- Swift Error Breakpoint


#### 4.3 使用 `image lookup` 命令查找可执行文件中的函数或方法
 
 - `-n` 选项
 - `-rn` 选项


使用 `-n` 选项精确查找：
```
(lldb) image lookup -n "-[UIViewController viewDidLoad]"
1 match found in /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore:
        Address: UIKitCore[0x0000000000ac813c] (UIKitCore.__TEXT.__text + 11295452)
        Summary: UIKitCore`-[UIViewController viewDidLoad]
```


使用 `-rn` 选项进行正则匹配查找：
```
(lldb) image lookup -rn test
2 matches found in /Users/xianglongchen/Library/Developer/Xcode/DerivedData/Signals-cvgzyljlwqgaebdbcipdyffhlpsr/Build/Products/Debug-iphonesimulator/Signals.app/Signals:
        Address: Signals[0x00000001000063c0] (Signals.__TEXT.__text + 17072)
        Summary: Signals`Signals.DetailViewController.test() throws -> () at DetailViewController.swift:48        Address: Signals[0x00000001000063c0] (Signals.__TEXT.__text + 17072)
        Summary: Signals`Signals.DetailViewController.test() throws -> () at DetailViewController.swift:48
...
```

#### 4.4 创建断点

#### （1）`b` 命令

使用 `b` 命令：

```
(lldb) b -[UIViewController viewDidLoad]
Breakpoint 1: where = UIKit`-[UIViewController viewDidLoad], address =
0x0000000102bbd788
```

上面的 `Breakpoint 1` 表示的是断点 ID。


#### （2）Regex breakpoints

正则表达式断点 `rbreak` 命令是 `breakpoint set -r %1` 的缩写。

格式：
```
rbreak <regular-expresion>
```

比如，我们可以用 `rbreak` 命令：

```
 (lldb) rb SwiftTestClass.name.setter
```

来代替需要更长的完整参数的 `b` 命令：
```
 (lldb) b Breakpoints.SwiftTestClass.name.setter : Swift.ImplicitlyUnwrappedOptional<Swift.String>
```


`rbreak` 命令还可以简写成 `rb`：

```
(lldb) rb name\.setter
```


#### （3）断点范围限制

我们可以通过 `-f` 选项来限定断点作用的文件范围：
```
(lldb) rb name\.setter -f DetailViewController.swift
```


`-s` 选项可以将断点限制到某个指定的 library 中（下面的 `Commons` 是一个 framework）：
```
(lldb) rb . -s Commons
```

#### （4）其他更多选项

`-L` 选项用来指定断点所作用的语言：

```
(lldb) breakpoint set -L swift -r . -s Commons
```

根据源码匹配条件设置断点：

```
 (lldb) breakpoint set -p "if let" -f MasterViewController.swift -f DetailViewController.swift
```

使用 `-c` 选项设置条件断点：

先 dump 一下可执行文件，看一下 sections 信息：

```
(lldb) image dump sections Signals
Sections for '/Users/xianglongchen/Library/Developer/Xcode/DerivedData/Signals-cvgzyljlwqgaebdbcipdyffhlpsr/Build/Products/Debug-iphonesimulator/Signals.app/Signals' (x86_64):
  SectID     Type             Load Address                             Perm File Off.  File Size  Flags      Section Name
  ---------- ---------------- ---------------------------------------  ---- ---------- ---------- ---------- ----------------------------
  0x00000100 container        [0x0000000000000000-0x0000000100000000)* ---  0x00000000 0x00000000 0x00000000 Signals.__PAGEZERO
  0x00000200 container        [0x000000010f662000-0x000000010f672000)  r-x  0x00000000 0x00010000 0x00000000 Signals.__TEXT
  0x00000001 code             [0x000000010f663b90-0x000000010f66df40)  r-x  0x00001b90 0x0000a3b0 0x80000400 Signals.__TEXT.__text
  0x00000002 code             [0x000000010f66df40-0x000000010f66e1aa)  r-x  0x0000bf40 0x0000026a 0x80000408 Signals.__TEXT.__stubs
  ...
  ...
```

找到其中的 `__TEXT` 段的信息，设置条件断点：
```
 (lldb) breakpoint set -n "-[UIView setTintColor:]" -c "*(uintptr_t*)$rsp
<= 0x000000010f672000 && *(uintptr_t*)$rsp >= 0x000000010f662000"
```


#### 4.5 编辑断点


查看所有断点：
```
 (lldb) breakpoint list
Current breakpoints:
1: file = '/Users/xianglongchen/Downloads/Advanced.Apple.Debugging.&.Reverse.Engineering.v2.0/04-Stopping in Code/starter/Signals/Signals/MasterViewController.swift', line = 43, exact_match = 0, locations = 1, resolved = 1, hit count = 1

  1.1: where = Signals`Signals.MasterViewController.viewDidLoad() -> () + 163 at MasterViewController.swift:44, address = 0x000000010f664123, resolved, hit count = 1 

2: file = '/Users/xianglongchen/Downloads/Advanced.Apple.Debugging.&.Reverse.Engineering.v2.0/04-Stopping in Code/starter/Signals/Signals/MasterViewController.swift', line = 46, exact_match = 0, locations = 1, resolved = 1, hit count = 0

  2.1: where = Signals`Signals.MasterViewController.viewDidLoad() -> () + 617 at MasterViewController.swift:46, address = 0x000000010f6642e9, resolved, hit count = 0 
```


查看 ID 为 1 的断点：
```
(lldb) breakpoint list 1
1: file = '/Users/xianglongchen/Downloads/Advanced.Apple.Debugging.&.Reverse.Engineering.v2.0/04-Stopping in Code/starter/Signals/Signals/MasterViewController.swift', line = 43, exact_match = 0, locations = 1, resolved = 1, hit count = 1

  1.1: where = Signals`Signals.MasterViewController.viewDidLoad() -> () + 163 at MasterViewController.swift:44, address = 0x000000010f664123, resolved, hit count = 1 
```

更简洁的格式查看单个断点：
```
(lldb) breakpoint list 1 -b
1: file = '/Users/xianglongchen/Downloads/Advanced.Apple.Debugging.&.Reverse.Engineering.v2.0/04-Stopping in Code/starter/Signals/Signals/MasterViewController.swift', line = 43, exact_match = 0, locations = 1, resolved = 1, hit count = 1
```

通过指定多个断点 ID 或者 ID 范围来查看多个断点：
```
(lldb) breakpoint list 1 3
(lldb) breakpoint list 1-3
```

#### 4.6 删除断点

格式：
```
breakpoint delete [-Df] [<breakpt-id | breakpt-id-list>]
```

删除 ID 为 1 的断点：
```
(lldb) breakpoint delete 1
```

删除所有断点：
```
(lldb) breakpoint delete
```

### 5. Expression


#### 5.1 格式化 `p` 命令和 `po` 命令

`po` 命令实际上是 `expression -O --` 的精简版，`-O` 选项表示的是打印目标对象的 description 方法的结果。

`p` 命令是 `expression --` 的精简版，相比 `po` 命令，少了一个 `-O` 选项。`p` 命令输出的格式取决于 LLDB 类型系统。


自定义类中 `description` 方法和 `debugDescription` 方法的实现对 `po` 命令的输出会产生影响。


#### LLDB 中对变量的引用

执行下面的命令，得到如下的结果：
```
(lldb) p self
(Signals.MasterViewController) $R2 = 0x00007fb71fd04080 {
  UIKit.UITableViewController = {
    baseUIViewController@0 = <extracting data from value failed>
    ...
    ...
```

接下来我们就可以直接引用 `$R2` 变量了（**即便后面不再在当前这次断点的 debugging session 了，仍然可以使用它**）：
```
(lldb) p $R2
```


#### 5.2 Swift vs Objective-C debugging contexts

在调试 Swift 和 Objective-C 混编的应用时，实际上有两种 debugging context：
- a non-Swift debugging context 
- a Swift context


debugging contexts 有以下三种情况：     
- 当你的断点停止在 Objective-C 代码时，LLDB 使用的是 non-Swift (Objective-C) debugging context
- 当你的断点停止在 Swift 代码时，LLDB 使用的是 Swift context
- 如果是非断点暂停程序的运行（比如点击了调试面板的暂停按钮），LLDB 默认使用的是 non-Swift (Objective-C) debugging context


你可以通过使用 `-l` 选项来指定语言为 Objective-C，以强制使用 Objective-C context：

```
 (lldb) expression -l objc -O -- [UIApplication sharedApplication]
```

#### 5.3 User defined variables


除了查看程序代码中已经定义的变量外，我们还可以像在 Chrome 的 console 中定义变量一样，在 LLDB debugging context 中定义临时变量，变量名必须以 `$` 开头：

```
(lldb) po id $test = [NSObject new]
(lldb) po $test
<NSObject: 0x60000001d190>
```

#### 5.4 类型格式化


`-G` 表示使用 GDB 的格式，`x` 表示十六进制：
```
(lldb) expression -G x -- 10
(int) $0 = 0x0000000a
```

下面是更简单的方式打印十六进制格式的数据：
```
(lldb) p/x 10
```

查看二进制格式：
```
(lldb) p/t 10
```

查看字符的 ACII 值：
```
(lldb) p/d 'D'
```


**常用格式对应的选项**：
- x: hexadecimal 
- d: decimal
- u: unsigned decimal 
- o: octal
- t: binary
- a: address
- c: character constant
- f: float
- s: string

更详细的可以查看 GDB 官方文档。


LLDB 也有自己的格式化，比如：        
```
(lldb) expression -f Y -- 1430672467
(int) $0 = 53 54 46 55             STFU
```

- B: boolean
- b: binary
- y: bytes
- Y: bytes with ASCII
- c: character
- C: printable character
- F: complex float
- s: c-string
- i: decimal
- E: enumeration
- x: hex
- f: float
- o: octal
- O: OSType
- U: unicode16
- u: unsigned decimal 
- p: pointer


更多信息见 [LLDB 官方文档](http://lldb.llvm.org/varformats.html)。


### 6. Thread, Frame & Stepping Around


#### 6.1 Stack 101 


```


0xFFFFFFFF
.
.
.
Stack start ->   ┏━━━━━━━━━━━━━━━━━━━┓
                 ┃      First Frame  ┃
                 ┃                   ┃
                 ┣━━━━━━━━━━━━━━━━━━━┫
                 ┃     Second Frame  ┃
                 ┃                   ┃
Stack pointer -> ┣━━━━━━━━━━━━━━━━━━━┫
                 ┃     Third  Frame  ┃
                 ┃                   ┃
                 ┗━━━━━━━━━━━━━━━━━━━┛
.
.
.
.
0x00000000


```

栈是从高地址向低地址增长，栈指针指向栈顶。


#### 6.2 Examining the stackʼs frames

ARM 架构的指令和 x86_64 架构的指令是不一样的，这也就意味着在 iOS 设备和模拟器上调试同一套代码时看到的汇编代码也是不一样的。


查看线程的函数调用堆栈信息：
```
(lldb) thread backtrace
```

使用 `bt` 命令也能达到同样的效果：
```
(lldb) bt
```

查看当前的 stack frame 信息：

```
(lldb) frame info
frame #0: 0x000000010ba1f8dc
Signals`MasterViewController.viewWillAppear(animated=false,
self=0x00007fd286c0af10) at MasterViewController.swift:50
```

上面的 `frame #0` 表示的是 frame 序号为 0，我们可以查看指定的 frame 信息：
```
(lldb) frame select 1
```

#### 6.3 Stepping

重新启动：
```
(lldb) run
```

#### 6.3.1 step over


```
(lldb) next
```

#### step in

```
(lldb) step
```


当当前函数没有 debug symbols 时，`step` 命令的效果跟 `next` 的效果是一样的，LLDB 会直接跳过。

不过我们可以通过设置一个选项来 step in 没有 debug symbols 的函数。

查看是否开启了 `step-in-avoid-nodebug` 模式：
```
 (lldb) settings show target.process.thread.step-in-avoid-nodebug
 YES
```

上面的结果打印为 YES，说明遇到没有 debug symbols 的函数时，LLDB 会跳过该函数，不过我们可以强制 step in：
```
 (lldb) step -a0
```


#### step out


```
(lldb) finish
```

#### 6.4 Examining data in the stack

在断点处执行 `frame variable` 命令，可以查看当前 frame 的变量信息：
```
 (lldb) frame variable
 (Bool) animated = false
(Signals.MasterViewController) self = 0x00007fb3d160aad0 {
  UIKit.UITableViewController = {
    baseUIViewController@0 = <extracting data from value failed>
    _tableViewStyle = 0
    _keyboardSupport = nil
    _staticDataSource = nil
    _filteredDataSource = 0x000061800005f0b0
    _filteredDataType = 0
}
  detailViewController = nil
}
```

`frame variable` 的结果不仅包含了在 Xcode debug 面板左侧的 Variables View 中显示的信息，而且还包含了一些私有变量的信息。


`-F` 选项的使用：
```
(lldb) frame variable -F self
self = 0x00007fff5540eb40
self =
self =
self =
self = {}
self.detailViewController = 0x00007fc728816e00
self.detailViewController.some =
self.detailViewController.some =
self.detailViewController.some = {}
self.detailViewController.some.signal = 0x00007fc728509de0
```


其他相关的子命令还有 `thread until`、`thread jump` 和 `thread return` 等子命令。

### 7. Image


`image` 命令是 `target modules` 的别名，这个命令主要用来查看 modules 中的信息，包括公开的和私有的类、方法。modules 就是加载到内存中并在一个进程中执行的代码，modules 可以又二进制可执行文件、framework 和 plugin 组成，大多数情况下，这些 modules 都是以 dynamic library 的形式存在的。

#### 7.1 modules


查看当前已加载的所有 modules：
```
(lldb) image list
[  0] 1E1B0254-4F55-3985-92E4-B2B6916AD424 0x000000010e7e7000 /Users/
derekselander/Library/Developer/Xcode/DerivedData/Signals-
atjgadijglwyppbagqpvyvftavcw/Build/Products/Debug-iphonesimulator/
Signals.app/Signals
[  1] 002B0442-3D59-3159-BA10-1C0A77859C6A 0x000000011e7c8000 /usr/lib/
dyld
[  2] E991FA37-F8F9-39BB-B278-3ACF4712A994 0x000000010e817000 /
Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/
Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/
Contents/Resources/RuntimeRoot/usr/lib/dyld_sim
```


根据名称查看指定的 module：
```
(lldb) image list Foundation
[  0] D153C8B2-743C-36E2-84CD-C476A5D33C72 0x000000010eb0c000 /
Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/
Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/
Contents/Resources/RuntimeRoot/System/Library/Frameworks/
Foundation.framework/Foundation
```


如上所示，一个 module 信息包括三部分：UUID、该 module 在当前进程地址空间中的地址，该 module 在磁盘上的位置。



查看 UIKit 模块的符号表信息：
```
(lldb) image dump symtab UIKit -s address
```


查看所有关于 `-[UIViewController viewDidLoad]` 实例方法的信息：
```
(lldb) image lookup -n "-[UIViewController viewDidLoad]"
```

根据正则表达式来查询以 `[UIViewController ` 开头的方法：
```
(lldb) image lookup -rn '\[UIViewController\ '
```



在指定模块中查找指定方法：
```
  (lldb) image lookup -rn _block_invoke Signals
```

#### 调试 block 

在下面的 block 处断点：
```
__38-[UnixSignalHandler appendSignal:sig:]_block_invoke_2
```

然后再执行：
```
(lldb) frame variable
(__block_literal_5 *)  = 0x0000608000275e80
(int) sig = 23
(siginfo_t *) siginfo = 0x00007fff587525e8
(UnixSignalHandler *) self = 0x000061800007d440
(UnixSignal *) unixSignal = 0x000000010bd9eebe
```

上面的 `__block_literal_5 *` 表示 block 的类型。

查看可执行文件中 block 的结构体信息：
```
(lldb) image lookup -t  __block_literal_5
Best match found in /Users/derekselander/Library/Developer/Xcode/
DerivedData/Signals-efqxsbqzgzcqqvhjgzgeabtwfufy/Build/Products/Debug-
iphonesimulator/Signals.app/Frameworks/Commons.framework/Commons:
id = {0x100000cba}, name = "__block_literal_5", byte-size = 52, decl =
UnixSignalHandler.m:123, compiler_type = "struct __block_literal_5 {
    void *__isa;
    int __flags;
    int __reserved;
    void (*__FuncPtr)();
    __block_descriptor_withcopydispose *__descriptor;
    UnixSignalHandler *const self;
    siginfo_t *siginfo;
int sig; }"
```

我们可以根据 block 地址和类型来查看 block 的类型信息：

```
(lldb) po ((__block_literal_5 *)0x0000608000275e80)
<__NSMallocBlock__: 0x0000608000275e80>
```

我们可以根据 block 地址和类型来查看 block 的成员变量：
```
 (lldb) p/x ((__block_literal_5 *)0x0000618000070200)->__FuncPtr
```

#### 7.2 Snooping around

接上节。


查看一下 `__NSMallocBlock__` 的实现：
```
(lldb) image lookup -rn __NSMallocBlock__
```

没有输出，表示 `__NSMallocBlock__` 没有重写任何父类的方法。

查看 `__NSMallocBlock__` 的父类：
```
(lldb) po [__NSMallocBlock__ superclass]
__NSMallocBlock
```


再查看一下 `__NSMallocBlock` 的实现：
```
(lldb) image lookup -rn __NSMallocBlock
5 matches found in /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation:
        Address: CoreFoundation[0x0000000000195f00] (CoreFoundation.__TEXT.__text + 1655504)
        Summary: CoreFoundation`-[__NSMallocBlock retain]        Address: CoreFoundation[0x0000000000195f20] (CoreFoundation.__TEXT.__text + 1655536)
        Summary: CoreFoundation`-[__NSMallocBlock release]        Address: CoreFoundation[0x0000000000195f30] (CoreFoundation.__TEXT.__text + 1655552)
        Summary: CoreFoundation`-[__NSMallocBlock retainCount]        Address: CoreFoundation[0x0000000000195f40] (CoreFoundation.__TEXT.__text + 1655568)
        Summary: CoreFoundation`-[__NSMallocBlock _tryRetain]        Address: CoreFoundation[0x0000000000195f50] (CoreFoundation.__TEXT.__text + 1655584)
        Summary: CoreFoundation`-[__NSMallocBlock _isDeallocating]
```

看上去 `__NSMallocBlock` 的实现只有跟内存管理有关。

再来看看 `__NSMallocBlock` 的父类：
```
(lldb) po [__NSMallocBlock superclass]
NSBlock
```

查看一下 `NSBlock` 的实现：

```
(lldb) image lookup -rn 'NSBlock\ '
Address: CoreFoundation[0x000000000018fd80] (CoreFoundation.__TEXT.__text
+ 1629760)
        Summary: CoreFoundation`-[NSBlock invoke]
```


### 8. Persisting & Customizing Commands


#### 8.1 Persisting Commands

当 LLDB 被启动时，它会去查找一些初始化文件，我们可以通过修改这些文件来添加自定义设置和自定义命令。

LLDB 启动时要到以下 3 个路径查找初始化文件：    
- `~/.lldbinit-lldb` （命令行中使用）和 `~/.lldbinit-Xcode` （Xcode 中使用）
- `~/.lldbinit`（命令行和 Xcode 中都可以使用）
- LLDB 被调用的目录下的 `~/.lldbinit`

推荐使用第 2 种方式。

#### 8.2 创建 `.lldbinit` 文件

1. 创建 `~/.lldbinit` 文件。

2. 在其中添加下面的内容：

```
command alias -H "Yay_Autolayout will get the root view and recursively
dump all the subviews and their frames" -h "Recursively dump views" --
Yay_Autolayout expression -l objc -O -- [[[[[UIApplication
sharedApplication] keyWindow] rootViewController] view]
recursiveDescription]
```

上面的代码使用 `command alias` 命令为 `expression -l objc -O -- [[[[[UIApplication sharedApplication] keyWindow] rootViewController] view] recursiveDescription]` 创建了一个叫做的 `Yay_Autolayout` 的别名，`-H` 和 `-h` 表示使用说明。

#### 8.3 可以带参数的命令别名

为 `expression -l objc -O --` 创建一个叫做 `cpo` 的别名：
```
command alias cpo expression -l objc -O --
```

### 9. Regex Commands

#### 9.1 command regex

`command regex` 和 `command alias` 的作用很像，但是这个命令支持正则表达式。

`command regex` 也可以加入到 `.lldbinit` 文件中。

格式如下：     
```
s/<regex>/<subst>/
```

以下面的为例：

```
 (lldb) command regex rlook 's/(.+)/image lookup -rn %1/'
```

这样的话，执行下面两段命令的效果是一样的：

```
(lldb) rlook FOO
(lldb) image lookup -rn FOO
```

#### 9.2 Executing complex logic

```
(lldb) command regex -- tv 's/(.+)/expression -l objc -O -- @import QuartzCore; [%1 setHidden:!(BOOL)[%1 isHidden]]; (void)[CATransaction flush];/'
```


#### 9.3 Chaining regex inputs


```
 (lldb) command regex getcls 's/(([0-9]|\$|\@|\[).*)/cpo [%1 class]/' 's/(.+)/expression -l swift -O -- type(of: %1)/'
```

上面的命令添加到 `.lldbinit` 后，`getcls` 命令就可以支持以下几种参数了：
```
(lldb) getcls @"hello world"
__NSCFString

(lldb) getcls @[@"hello world"]
__NSSingleObjectArrayI

(lldb) getcls [UIDevice currentDevice]
UIDevice

(lldb) cpo [UIDevice currentDevice]
<UIDevice: 0x60800002b520>

(lldb) getcls 0x60800002b520
UIDevice

(lldb) getcls self

```


#### 9.4 Supplying multiple parameters


使用正则表达式可以操作多个参数：
```
 (lldb) command regex flip 's/(\w+) (\w+)/expression -lobjc -O -- @"%2 %1"/'
```

```
(lldb) flip hello world
world hello
```

## 第二部分 汇编语言

### 10. Assembly Register Calling Convention

#### 10.1 Assembly 101

#### 10.2 x86_64 register calling convention

#### 10.3 Objective-C and registers


#### 10.4 Putting theory to practice


```
register read
General Purpose Registers:
       rax = 0x000000010000c0a0  (void *)0x001d80010000c249
       rbx = 0x0000600002c0d900
       rcx = 0x0000000000000000
       rdx = 0x0000000000000000
       rdi = 0x0000600002c0d900
       rsi = 0x00007fff2e6c291e  "viewDidLoad"
       rbp = 0x00007ffeefbfe340
       rsp = 0x00007ffeefbfe308
        r8 = 0x0000000000000010
        r9 = 0x0000000000000000
       r10 = 0x0000000000000006
       r11 = 0x00007fff2dc26c11  AppKit`-[NSViewController viewDidLoad]
       r12 = 0x000000010130f1e0
       r13 = 0x0000600002c0d900
       r14 = 0x0000000000000058
       r15 = 0x000000010130f1e0
       rip = 0x00007fff2dc26c11  AppKit`-[NSViewController viewDidLoad]
    rflags = 0x0000000000000246
        cs = 0x000000000000002b
        fs = 0x0000000000000000
        gs = 0x0000000000000000
```

```
(lldb) po $rdi
<Registers.ViewController: 0x600002c0d900>

(lldb) po $rsi
140733972228382

(lldb) po (char *)$rsi
"viewDidLoad"

(lldb) po (SEL)$rsi
"viewDidLoad"
```



带参数的方法：
```
(lldb) b -[NSResponder mouseUp:]
Breakpoint 2: where = AppKit`-[NSResponder mouseUp:], address = 0x00007fff2dcda6a6
(lldb) c
Process 69624 resuming
2019-03-14 18:00:06.475319+0800 Registers[69624:5760047] [default] Unable to load Info.plist exceptions (eGPUOverrides)
(lldb) register read
General Purpose Registers:
       rax = 0x0000000000000048
       rbx = 0x0000600003e00400
       rcx = 0x0000000000000008
       rdx = 0x0000600003301ea0
       rdi = 0x0000600003304a00
       rsi = 0x00007fff2e6be04f  "mouseUp:"
       rbp = 0x00007ffeefbff100
       rsp = 0x00007ffeefbfecc8
        r8 = 0x0000000000000000
        r9 = 0x0000000000000000
       r10 = 0x000000000000004f
       r11 = 0x00007fff2dcda6a6  AppKit`-[NSResponder mouseUp:]
       r12 = 0x00007fff5c6c1a00  libobjc.A.dylib`objc_msgSend
       r13 = 0x00007fff2e688e56  "retain"
       r14 = 0x00007fff889e6578  AppKit`NSWindow._lastLeftHit
       r15 = 0x00007fff889e64f0  AppKit`NSWindow._wFlags
       rip = 0x00007fff2dcda6a6  AppKit`-[NSResponder mouseUp:]
    rflags = 0x0000000000000246
        cs = 0x000000000000002b
        fs = 0x0000000000000000
        gs = 0x0000000000000000

(lldb) po $rdi
<NSView: 0x600003304a00>

(lldb) po $rdx
NSEvent: type=LMouseUp loc=(180.328,32.207) time=285912.6 flags=0 win=0x600003e00400 winNum=17662 ctxt=0x0 evNum=8600 click=1 buttonNumber=0 pressure=0 deviceID:0x40000003ba42fb1 subtype=NSEventSubtypeTouch

(lldb) po [$rdx class]
NSEvent
```

在不重启程序的前提下，将 window 改成红色：
```
(lldb) breakpoint set -o true -S "-[NSWindow mouseDown:]"
Breakpoint 3: where = AppKit`-[NSWindow mouseDown:], address = 0x00007fff2dd9b30b
(lldb) po [$rdi setBackgroundColor:[NSColor redColor]]
0x0000000000000001
```
## 11. Assembly & Memory

https://apple.stackexchange.com/questions/12666/how-to-check-whether-my-intel-based-mac-is-32-bit-or-64-bit

https://www.pc841.com/wenda/92764.html


## 12. Assembly and the Stack



### 12.4 Observing RBP & RSP in action

`StackWalkthrough` 函数的源代码：
```assembly
.globl _StackWalkthrough

_StackWalkthrough:
      push  %rbp
      movq  %rsp, %rbp
      movq  $0x0, %rdx
      movq  %rdi, %rdx
      push  %rdx
      movq  $0x0, %rdx
      pop   %rdx
      pop   %rbp
      ret
```

调用 `StackWalkthrough` 函数的源代码：
```swift
    override func awakeFromNib() {
        super.awakeFromNib()
        StackWalkthrough(5)
    }
```

1. 在 `StackWalkthrough(5)` 处添加断点，运行的程序在断点处暂停后，通过 `Debug\Debug Workflow\Always Show Disassembly` 显示汇编代码：
```
Registers`ViewController.awakeFromNib():
    0x100003ae0 <+0>:   push   rbp
    0x100003ae1 <+1>:   mov    rbp, rsp
    0x100003ae4 <+4>:   sub    rsp, 0x30
    0x100003ae8 <+8>:   mov    qword ptr [rbp - 0x8], 0x0
    0x100003af0 <+16>:  mov    qword ptr [rbp - 0x8], r13
    0x100003af4 <+20>:  mov    rdi, r13
    0x100003af7 <+23>:  mov    qword ptr [rbp - 0x20], r13
    0x100003afb <+27>:  call   0x100008f40               ; symbol stub for: objc_retain
    0x100003b00 <+32>:  xor    ecx, ecx
    0x100003b02 <+34>:  mov    edi, ecx
    0x100003b04 <+36>:  mov    qword ptr [rbp - 0x28], rax
    0x100003b08 <+40>:  call   0x100003a50               ; type metadata accessor for Registers.ViewController at <compiler-generated>
    0x100003b0d <+45>:  mov    rdi, qword ptr [rbp - 0x20]
    0x100003b11 <+49>:  mov    qword ptr [rbp - 0x18], rdi
    0x100003b15 <+53>:  mov    qword ptr [rbp - 0x10], rax
    0x100003b19 <+57>:  mov    rsi, qword ptr [rip + 0x9588] ; "awakeFromNib"
    0x100003b20 <+64>:  lea    rdi, [rbp - 0x18]
    0x100003b24 <+68>:  mov    qword ptr [rbp - 0x30], rdx
    0x100003b28 <+72>:  call   0x100008f34               ; symbol stub for: objc_msgSendSuper2
    0x100003b2d <+77>:  mov    rdi, qword ptr [rbp - 0x20]
    0x100003b31 <+81>:  call   0x100008fa0               ; symbol stub for: swift_unknownRelease
    0x100003b36 <+86>:  mov    edi, 0x5
->  0x100003b3b <+91>:  call   0x100001f40               ; StackWalkthrough
    0x100003b40 <+96>:  add    rsp, 0x30
    0x100003b44 <+100>: pop    rbp
    0x100003b45 <+101>: ret  
```

设置 LLDB 命令别名：
```
(lldb) command alias dumpreg register read rsp rbp rdi rdx
```

查看寄存器状态（`rdi` 的值就是参数的值 `5`）：
```
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4e0
     rbp = 0x00007ffeefbfe510
     rdi = 0x0000000000000005
     rdx = 0x0040000000000000
```

2. 执行 LLDB 命令 `si` 进入 `StackWalkthrough` 函数，并查看寄存器中的值（注意栈指针 `rsp` 的变化）：
```
(lldb) si
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4d8
     rbp = 0x00007ffeefbfe510
     rdi = 0x0000000000000005
     rdx = 0x0040000000000000
```

> 延伸：`si` 命令是 `thread step-inst` 的别名，用来让 LLDB 执行下一条指令，然后再暂停 debugger。

此时 Xcode 中显示的汇编源码如下：
```
Registers`StackWalkthrough:
->  0x100001f40 <+0>:  push   rbp
    0x100001f41 <+1>:  mov    rbp, rsp
    0x100001f44 <+4>:  mov    rdx, 0x0
    0x100001f4b <+11>: mov    rdx, rdi
    0x100001f4e <+14>: push   rdx
    0x100001f4f <+15>: mov    rdx, 0x0
    0x100001f56 <+22>: pop    rdx
    0x100001f57 <+23>: pop    rbp
    0x100001f58 <+24>: ret 
```

因为 `call` 指令执行时，首先会将其调用的函数返回后要执行的下一条指令的地址（在这个例子中就是 `0x100003b40`）压入栈中，然后再跳到要执行的函数中。所以，在执行了上面的命令 `si` 后，RSP 所指向的值也发生了变化，可以通过下面的命令验证一下：
```
(lldb) x/gx $rsp
0x7ffeefbfe4d8: 0x0000000100003b40
```

3. 再继续往下执行，并查看寄存器中的值（注意栈指针 `rsp` 的变化）：
```
(lldb) si
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4d0
     rbp = 0x00007ffeefbfe510
     rdi = 0x0000000000000005
     rdx = 0x0040000000000000
```

此时 Xcode 中显示的汇编源码如下：
```
Registers`StackWalkthrough:
    0x100001f40 <+0>:  push   rbp
->  0x100001f41 <+1>:  mov    rbp, rsp
    0x100001f44 <+4>:  mov    rdx, 0x0
    0x100001f4b <+11>: mov    rdx, rdi
    0x100001f4e <+14>: push   rdx
    0x100001f4f <+15>: mov    rdx, 0x0
    0x100001f56 <+22>: pop    rdx
    0x100001f57 <+23>: pop    rbp
    0x100001f58 <+24>: ret
```

上面的 `push rbp` 指令是把 rbp 的值压入栈中，所以下面两条命令得到的结果应该是一样的。

RSP 所指向的栈中的内容：
```
(lldb) x/gx $rsp
0x7ffeefbfe4d0: 0x00007ffeefbfe510
```

rbp 的值：
```
(lldb) p/x $rbp
(unsigned long) $2 = 0x00007ffeefbfe510
```

4. 再继续往下执行，并查看寄存器中的值（注意指针 `rbp` 的变化）：
```
(lldb) si
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4d0
     rbp = 0x00007ffeefbfe4d0
     rdi = 0x0000000000000005
     rdx = 0x0040000000000000
(lldb) p (BOOL)($rbp == $rsp)
(BOOL) $4 = YES
```

此时 Xcode 中显示的汇编源码如下：
```
Registers`StackWalkthrough:
    0x100001f40 <+0>:  push   rbp
    0x100001f41 <+1>:  mov    rbp, rsp
->  0x100001f44 <+4>:  mov    rdx, 0x0
    0x100001f4b <+11>: mov    rdx, rdi
    0x100001f4e <+14>: push   rdx
    0x100001f4f <+15>: mov    rdx, 0x0
    0x100001f56 <+22>: pop    rdx
    0x100001f57 <+23>: pop    rbp
    0x100001f58 <+24>: ret 
```

`mov    rbp, rsp` 指令是将 rsp 的值赋给 rbp，所以我们可以从上面的打印结果看到，rsp 和 rbp 的值一样了。

5. 再继续往下执行，并查看寄存器中的值（注意寄存器 `rbx` 的变化）：

```
(lldb) si
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4d0
     rbp = 0x00007ffeefbfe4d0
     rdi = 0x0000000000000005
     rdx = 0x0000000000000000
```

此时 Xcode 中显示的汇编源码如下：
```
Registers`StackWalkthrough:
    0x100001f40 <+0>:  push   rbp
    0x100001f41 <+1>:  mov    rbp, rsp
    0x100001f44 <+4>:  mov    rdx, 0x0
->  0x100001f4b <+11>: mov    rdx, rdi
    0x100001f4e <+14>: push   rdx
    0x100001f4f <+15>: mov    rdx, 0x0
    0x100001f56 <+22>: pop    rdx
    0x100001f57 <+23>: pop    rbp
    0x100001f58 <+24>: ret  
```

`mov    rdx, 0x0` 指令所做的就是让 rdx 的值变成了 0。

6. 再继续往下执行，并查看寄存器中的值（注意寄存器 `rbx` 的变化）：
```
(lldb) si
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4d0
     rbp = 0x00007ffeefbfe4d0
     rdi = 0x0000000000000005
     rdx = 0x0000000000000005
```

此时 Xcode 中显示的汇编源码如下：
```
Registers`StackWalkthrough:
    0x100001f40 <+0>:  push   rbp
    0x100001f41 <+1>:  mov    rbp, rsp
    0x100001f44 <+4>:  mov    rdx, 0x0
    0x100001f4b <+11>: mov    rdx, rdi
->  0x100001f4e <+14>: push   rdx
    0x100001f4f <+15>: mov    rdx, 0x0
    0x100001f56 <+22>: pop    rdx
    0x100001f57 <+23>: pop    rbp
    0x100001f58 <+24>: ret
```

`mov    rdx, rdi` 这条指令所做的是将 rdi 的值赋给 rdx，所以我们可以看到 rdx 的值也变成了 5。


7. 再继续往下执行，并查看寄存器中的值（注意栈指针 `rsp` 的变化）：
```
(lldb) si
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4c8
     rbp = 0x00007ffeefbfe4d0
     rdi = 0x0000000000000005
     rdx = 0x0000000000000005
(lldb) p/x $rsp
(unsigned long) $5 = 0x00007ffeefbfe4c8
(lldb) x/gx $rsp
0x7ffeefbfe4c8: 0x0000000000000005
```

此时 Xcode 中显示的汇编源码如下：
```
Registers`StackWalkthrough:
    0x100001f40 <+0>:  push   rbp
    0x100001f41 <+1>:  mov    rbp, rsp
    0x100001f44 <+4>:  mov    rdx, 0x0
    0x100001f4b <+11>: mov    rdx, rdi
    0x100001f4e <+14>: push   rdx
->  0x100001f4f <+15>: mov    rdx, 0x0
    0x100001f56 <+22>: pop    rdx
    0x100001f57 <+23>: pop    rbp
    0x100001f58 <+24>: ret
```

`push   rdx` 指令所做的是将 rdx 的值压入栈中，所以我们可以从上面打印的结果可以看到，栈指针 rbp 的值减小了，其所指向的内容也变成了 rdx 的值，也就是 5。

8. 再继续往下执行，并查看寄存器中的值（注意寄存器 `rdx` 的变化）：
```
(lldb) si
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4c8
     rbp = 0x00007ffeefbfe4d0
     rdi = 0x0000000000000005
     rdx = 0x0000000000000000
```

此时 Xcode 中显示的汇编源码如下：
```
Registers`StackWalkthrough:
    0x100001f40 <+0>:  push   rbp
    0x100001f41 <+1>:  mov    rbp, rsp
    0x100001f44 <+4>:  mov    rdx, 0x0
    0x100001f4b <+11>: mov    rdx, rdi
    0x100001f4e <+14>: push   rdx
    0x100001f4f <+15>: mov    rdx, 0x0
->  0x100001f56 <+22>: pop    rdx
    0x100001f57 <+23>: pop    rbp
    0x100001f58 <+24>: ret
```
`mov    rdx, 0x0` 指令将 rdx 的值设置为 0。

9. 再继续往下执行，并查看寄存器中的值（注意栈指针 `rsp` 和寄存器 `rdx` 的变化）：
```
(lldb) si
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4d0
     rbp = 0x00007ffeefbfe4d0
     rdi = 0x0000000000000005
     rdx = 0x0000000000000005
```


此时 Xcode 中显示的汇编源码如下：
```
Registers`StackWalkthrough:
    0x100001f40 <+0>:  push   rbp
    0x100001f41 <+1>:  mov    rbp, rsp
    0x100001f44 <+4>:  mov    rdx, 0x0
    0x100001f4b <+11>: mov    rdx, rdi
    0x100001f4e <+14>: push   rdx
    0x100001f4f <+15>: mov    rdx, 0x0
    0x100001f56 <+22>: pop    rdx
->  0x100001f57 <+23>: pop    rbp
    0x100001f58 <+24>: ret 
```

`pop    rdx` 指令将栈顶的内容弹出并设置给 rdx，同时将 rsp 指针值增加 0x8。从上面的打印结果可以看到 rdx 的值又变回了 5。

此时 RSP 所指向的栈中的内容，就是之前 push 到栈中的 rbp 的值：
```
(lldb) x/gx $rsp
0x7ffeefbfe4d0: 0x00007ffeefbfe510
```


10. 再继续往下执行，并查看寄存器中的值（注意栈指针 `rsp` 和寄存器 `rbp` 的变化）：
```
(lldb) si
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4d8
     rbp = 0x00007ffeefbfe510
     rdi = 0x0000000000000005
     rdx = 0x0000000000000005
```

此时 Xcode 中显示的汇编源码如下：

```
Registers`StackWalkthrough:
    0x100001f40 <+0>:  push   rbp
    0x100001f41 <+1>:  mov    rbp, rsp
    0x100001f44 <+4>:  mov    rdx, 0x0
    0x100001f4b <+11>: mov    rdx, rdi
    0x100001f4e <+14>: push   rdx
    0x100001f4f <+15>: mov    rdx, 0x0
    0x100001f56 <+22>: pop    rdx
    0x100001f57 <+23>: pop    rbp
->  0x100001f58 <+24>: ret
```

`pop    rbp` 指令将栈顶的内容弹出并设置给 rbp，同时将 rsp 指针值增加 0x8。从上面的打印结果可以看到 rbp 的值又变回了 `0x00007ffeefbfe510`。

此时 RSP 所指向的栈中的内容，就是之前执行 call 时 push 到栈中值，即 call 指令后面的指令：
```
(lldb) x/gx $rsp
0x7ffeefbfe4d8: 0x0000000100003b40
```


11. 最后再执行 `ret` 这条指令，并查看寄存器中的值（注意栈指针 `rsp` 和寄存器 `rip` 的变化）：
```
(lldb) si
(lldb) dumpreg
     rsp = 0x00007ffeefbfe4e0
     rbp = 0x00007ffeefbfe510
     rdi = 0x0000000000000005
     rdx = 0x0000000000000005
(lldb) cpx $rip
(unsigned long) $9 = 0x0000000100003b40
```

此时 Xcode 中显示的汇编源码如下：
```
Registers`ViewController.awakeFromNib():
    0x100003ae0 <+0>:   push   rbp
    0x100003ae1 <+1>:   mov    rbp, rsp
    0x100003ae4 <+4>:   sub    rsp, 0x30
    0x100003ae8 <+8>:   mov    qword ptr [rbp - 0x8], 0x0
    0x100003af0 <+16>:  mov    qword ptr [rbp - 0x8], r13
    0x100003af4 <+20>:  mov    rdi, r13
    0x100003af7 <+23>:  mov    qword ptr [rbp - 0x20], r13
    0x100003afb <+27>:  call   0x100008f40               ; symbol stub for: objc_retain
    0x100003b00 <+32>:  xor    ecx, ecx
    0x100003b02 <+34>:  mov    edi, ecx
    0x100003b04 <+36>:  mov    qword ptr [rbp - 0x28], rax
    0x100003b08 <+40>:  call   0x100003a50               ; type metadata accessor for Registers.ViewController at <compiler-generated>
    0x100003b0d <+45>:  mov    rdi, qword ptr [rbp - 0x20]
    0x100003b11 <+49>:  mov    qword ptr [rbp - 0x18], rdi
    0x100003b15 <+53>:  mov    qword ptr [rbp - 0x10], rax
    0x100003b19 <+57>:  mov    rsi, qword ptr [rip + 0x9588] ; "awakeFromNib"
    0x100003b20 <+64>:  lea    rdi, [rbp - 0x18]
    0x100003b24 <+68>:  mov    qword ptr [rbp - 0x30], rdx
    0x100003b28 <+72>:  call   0x100008f34               ; symbol stub for: objc_msgSendSuper2
    0x100003b2d <+77>:  mov    rdi, qword ptr [rbp - 0x20]
    0x100003b31 <+81>:  call   0x100008fa0               ; symbol stub for: swift_unknownRelease
    0x100003b36 <+86>:  mov    edi, 0x5
    0x100003b3b <+91>:  call   0x100001f40               ; StackWalkthrough
->  0x100003b40 <+96>:  add    rsp, 0x30
    0x100003b44 <+100>: pop    rbp
    0x100003b45 <+101>: ret 
```

`ret` 指令所做的是将栈顶的保存的内容 pop 出来，也就是 `call` 后面的指令对应的地址，然后再将 rsp 增加 0x8。


## 第三部分 深入程序的底层

## 13. Hello, Ptrace

- System calls
- The Foundation of attachment, ptrace
- ptrace arguments
- Creating around PT_DENY_ATTACH
- Other anti-debugging techniques

## 14. Dynamic Frameworks

### 14.1 动态库简介
- 什么是静态库？
  - 可以在运行时加载到进程内存中运行的代码
- 为什么需要动态库？
  - 节省内存空间，多个不同的进程可以共享同一个动态库
  - 更新动态库时，依赖它的程序无须重新编译
- 从 iOS 8 开始，苹果放宽了动态库使用的限制，允许开发者在 app 中使用第三方的动态库，这意味着我们可以在不同的 iOS extension 之间共享 framework，比如 Today Extension 和 Action Extension。

### 14.2 检测一个二进制可执行文件中用到的 framework

- 负责加载动态库的程序叫做动态链接器 dyld。

- 使用 `otool -L` 查看二进制文件 `DeleteMe` 中链接的动态库

```
$ otool -L /Users/xianglongchen/Library/Developer/Xcode/DerivedData/DeleteMe-cfvigoormjpbaoebptogdzvtelbt/Build/Products/Debug-iphonesimulator/DeleteMe.app/DeleteMe
/Users/xianglongchen/Library/Developer/Xcode/DerivedData/DeleteMe-cfvigoormjpbaoebptogdzvtelbt/Build/Products/Debug-iphonesimulator/DeleteMe.app/DeleteMe:
  /System/Library/Frameworks/CallKit.framework/CallKit (compatibility version 1.0.0, current version 1.0.0)
  /System/Library/Frameworks/Social.framework/Social (compatibility version 1.0.0, current version 87.0.0)
  /System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1556.0.0)
  /usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
  /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.200.5)
  /System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 61000.0.0)
```

从上面的打印结果可以看出，动态库都是保存在这些目录下的：
```
/System/Library/Frameworks/
/usr/lib/
```

- 使用 `otool -l` 查看二进制文件 `DeleteMe` 的 load commands

```
otool -l /Users/xianglongchen/Library/Developer/Xcode/DerivedData/DeleteMe-cfvigoormjpbaoebptogdzvtelbt/Build/Products/Debug-iphonesimulator/DeleteMe.app/DeleteMe
/Users/xianglongchen/Library/Developer/Xcode/DerivedData/DeleteMe-cfvigoormjpbaoebptogdzvtelbt/Build/Products/Debug-iphonesimulator/DeleteMe.app/DeleteMe:
Mach header
      magic cputype cpusubtype  caps    filetype ncmds sizeofcmds      flags
 0xfeedfacf 16777223          3  0x00           2    22       2856 0x00200085
 ...
Load command 12
          cmd LC_LOAD_WEAK_DYLIB
      cmdsize 80
         name /System/Library/Frameworks/CallKit.framework/CallKit (offset 24)
   time stamp 2 Thu Jan  1 08:00:02 1970
      current version 1.0.0
compatibility version 1.0.0
Load command 13
          cmd LC_LOAD_DYLIB
      cmdsize 80
         name /System/Library/Frameworks/Social.framework/Social (offset 24)
   time stamp 2 Thu Jan  1 08:00:02 1970
      current version 87.0.0
compatibility version 1.0.0
Load command 14
          cmd LC_LOAD_DYLIB
      cmdsize 88
         name /System/Library/Frameworks/Foundation.framework/Foundation (offset 24)
   time stamp 2 Thu Jan  1 08:00:02 1970
      current version 1556.0.0
compatibility version 300.0.0
 ...
```

从上面的打印结果可以看到， CallKit 的 cmd 是 LC_LOAD_WEAK_DYLIB，而 Social 的 cmd 是 LC_LOAD_DYLIB，这说明 CallKit 是可选的，而 Social 是必需的。


### 14.3 修改 load command


我们可以通过命令 `install_name_tool` 来修改和增加 framework load command。

比如，将 `DeleteMe` 中的 CallKit 库换成 NotificationCenter 库，操作命令如下：
```
install_name_tool -change /System/Library/Frameworks/CallKit.framework/CallKit /System/Library/Frameworks/NotificationCenter.framework/NotificationCenter /Users/derekselander/Library/Developer/CoreSimulator/Devices/
D0576CB9-42E1-494B-B626-B4DB75411700/data/Containers/Bundle/Application/474C8786-CC4F-4615-8BB0-8447DC9F82CA/DeleteMe.app/DeleteMe
```



### 14.4 在运行时加载 framework


在 Xcode 中运行 DeleteMe，pause，然后用 `process load` 命令加载动态库 `Speech`：
```
(lldb) process load /Applications/Xcode.app/Contents/Developer/Platforms/
iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk//System/
Library/Frameworks/Speech.framework/Speech
```

实际上我们不需要指定具体的 framework 地址，`dyld` 会自动在一些目录下搜索，所以像下面这样也可以加载动态库：
```
(lldb) process load MessageUI.framework/MessageUI
 Loading "MessageUI.framework/MessageUI"...ok
Image 1 loaded.
```


延伸：如何获取系统动态库的位置和二进制执行文件 DeleteMe 在模拟器中的位置？

```
(lldb) image list CallKit
[  0] 0484D8BA-5CB8-3DD3-8136-D8A96FB7E15B 0x0000000102d10000 /
Applications/Xcode.app/Contents/Developer/Platforms/
iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/
Library/Frameworks/CallKit.framework/CallKit
```

```
$ pgrep -fl DeleteMe
61175 /Users/derekselander/Library/Developer/CoreSimulator/Devices/D0576CB9-42E1-494B-B626-B4DB75411700/data/Containers/Bundle/Application/474C8786-CC4F-4615-8BB0-8447DC9F82CA/DeleteMe.app/Delet

```

### 14.5 探索 framework

在 `~/.lldbinit` 文件中添加以下几个命令正则别名：
```
command regex dump_stuff "s/(.+)/image lookup -rn '\+\[\w+(\(\w+\))?\ \w+\]$' %1 /"
command regex ivars 's/(.+)/expression -lobjc -O -- [%1 _ivarDescription]/'
command regex methods 's/(.+)/expression -lobjc -O -- [%1 _shortMethodDescription]/'
command regex lmethods 's/(.+)/expression -lobjc -O -- [%1 _methodDescription]/'
```

查看 Social 动态库中的所有不带参数的类方法：
```
(lldb) dump_stuff Social
71 matches found in /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/Social.framework/Social:
        Address: Social[0x000000000000262c] (Social.__TEXT.__text + 0)
        Summary: Social`+[SLInternalComposeServiceHostContext _extensionAuxiliaryVendorProtocol]        Address: Social[0x0000000000002698] (Social.__TEXT.__text + 108)
        Summary: Social`+[SLInternalComposeServiceHostContext _extensionAuxiliaryHostProtocol]        Address: Social[0x000000000000281a] (Social.__TEXT.__text + 494)
        ...

```

查看一个对象的所有的实例变量：
```
(lldb) ivars [SLFacebookUpload new]
<SLFacebookUpload: 0x600000056320>:
in SLFacebookUpload:
  _uploadID (NSString*): nil
  _uploadType (long): 0
  _totalBytes (unsigned long): 0
  _transferredBytes (unsigned long): 0
in NSObject:
  isa (Class): SLFacebookUpload (isa, 0x103914078)
```

查看一个对象或者类自己实现的方法：
```
(lldb) methods SLFacebookUpload
<SLFacebookUpload: 0x10f75f078>:
in SLFacebookUpload:
    Class Methods:
        + (BOOL) supportsSecureCoding; (0x10f6e3b5b)
    Properties:
        @property (retain, nonatomic) NSString* uploadID;  (@synthesize
uploadID = _uploadID;)
        ...
        @property (nonatomic) unsigned long transferredBytes;
(@synthesize transferredBytes = _transferredBytes;)
    Instance Methods:
        - (id) uploadID; (0x10f6e3b63)
        ...
        - (void) setTotalBytes:(unsigned long)arg1; (0x10f6e3bd3)
(NSObject ...)
```


查看一个对象或者类所有的方法：
```
(lldb) lmethods SLFacebookUpload
<SLFacebookUpload: 0x10f75f078>:
in SLFacebookUpload:
    Class Methods:
        + (BOOL) supportsSecureCoding; (0x10f6e3b5b)
    Properties:
        @property (retain, nonatomic) NSString* uploadID;  (@synthesize
uploadID = _uploadID;)
        ...
        @property (nonatomic) unsigned long transferredBytes;
(@synthesize transferredBytes = _transferredBytes;)
    Instance Methods:
        - (id) uploadID; (0x10f6e3b63)
        ...
        - (void) setTotalBytes:(unsigned long)arg1; (0x10f6e3bd3)
in NSObject:
    Class Methods:
        + (id) CKSQLiteClassName; (0x126ecbb5e)
        ...
        + (BOOL) isFault; (0x10fd08a6d)
    Properties:
        @property (retain, nonatomic) NSArray* accessibilityCustomRotors;
        ...
    @property (readonly, copy) NSString* debugDescription;
Instance Methods:
    - (id) mf_objectWithHighest:(^block)arg1; (0x126776a76)
    ...
    - (BOOL) isFault; (0x10fd08a70)
```

### 14.6 在 iOS 设备上加载动态库

## 15. Hooking & Executing Code with `dlopen` & `dlsym`

### 15.1 The Objective-C runtime vs. Swift & C


### 15.2 Setting up your Project

### 15.3 Easy mode: hooking C functions


由于 C 不是像 OC 那样的动态语言，所以如果我们要 hook C 函数的话，就需要在该函数加载到内存之前就进行拦截。而动态库的链接就发生在程序启动时，所以我们可以通过创建动态库并在其中拦截 C 函数来实现 hook。

> 问题：链接后，进程中就有了两个 `getenv` 函数（假设我们 hook 的是 `getenv` 函数），那 CPU 怎么知道去找那个函数执行呢？

1. 创建动态库；

2. 在动态库中实现 `getenv` 函数，并通过 `dlopen` 和 `dlsym` 来调用原始的实现；

我们可以通过调用 dlopen 和 dlsym 在运行时加载动态库，并调用动态库中的函数。

dlopen 的函数声明如下，返回值为要加载的动态库的引用：
```
extern void * dlopen(const char * __path, int __mode);
```

dlsym 的函数声明如下，返回值为要调用的函数的地址：
```
extern void * dlsym(void * __handle, const char * __symbol);

```

示例：
```
void *handle = dlopen("/usr/lib/system/libsystem_c.dylib", RTLD_NOW);
char * (*real_getenv)(const char *) = dlsym(handle, "getenv");
char *home_path = real_getenv("HOME");

```

3. 在应用程序中引入前面创建的动态库，并调用 `getenv` 函数，cmd+R 运行，此时调用的 `getenv` 就是 hook 后的实现了。

### 15.4 Hard mode: hooking Swift methods


hook Swift 方法有个问题：   
- `dlsym` 函数只会返回一个函数的地址，而 Swift 中的方法不像 C 函数，Swift 中的方法属于某个类或结构体，所以，我们需要将 `dlsym` 返回的 C 函数转成 Swift 方法
- Swift 方法在编译时会进行符号修饰（mangle），所以最终的函数名跟源代码中的方法名不一样


hook Swift 方法的过程（以动态库 HookingSwift 的 originalImage 方法为例）：

1. 找到要 hook 的实际方法名，也就是编译后的方法名。

编译运行项目后，pause，执行下面的命令：
```
 (lldb) image lookup -rn HookingSwift.*originalImage
 1 match found in /Users/derekselander/Library/Developer/Xcode/
DerivedData/Watermark-eztayvulqnjphfeqxjisvyqebwbz/Build/Products/Debug-
iphonesimulator/Watermark.app/Frameworks/HookingSwift.framework/
HookingSwift:
        Address: HookingSwift[0x00000000000013e0]
(HookingSwift.__TEXT.__text + 448)
        Summary: HookingSwift`HookingSwift.CopyrightImageGenerator.
(originalImage in _71AD57F3ABD678B113CF3AD05D01FF41).getter :
Swift.Optional<__ObjC.UIImage> at CopyrightImageGenerator.swift:36
```

其中的 `0x00000000000013e0` 就是该函数所在的地址。

接着，再从 HookingSwift 动态库的符号表中查找该函数对应的符号：
```
 (lldb) image dump symtab -m HookingSwift
 ...
 [    6]     17 D X Code            0x00000000000013e0
0x00000000000000e0 0x000f0000
_T012HookingSwift23CopyrightImageGeneratorC08originalD033_71AD57F3ABD678B113CF3AD05D01FF41LLSo7UIImageCSgfg
 ...
```

上面的 `_T012HookingSwift23CopyrightImageGeneratorC08originalD033_71AD57F3ABD678B113CF3AD05D01FF41LLSo7UIImageCSgfg` 就是我们想要的符号。

2. 调用 dlopen 和 dlsym 函数获取要 hook 的函数地址，并将函数转成 Swift 方法进行调用（方法所属的对象作为函数的第一个参数）：

```
if let handle = dlopen("./Frameworks/HookingSwift.framework/HookingSwift", RTLD_NOW) {
  let sym = dlsym(handle, "_TFC12HookingSwift23CopyrightImageGeneratorgP33_71AD57F3ABD678B113CF3AD05D01FF4113originalImageGSqCSo7UIImage_")!
  print("\(sym)")

  typealias privateMethodAlias = @convention(c) (Any) -> UIImage? // 1
  let originalImageFunction = unsafeBitCast(sym, to:privateMethodAlias.self) // 2
  let imageGenerator = CopyrightImageGenerator()
  let originalImage = originalImageFunction(imageGenerator) // 3
  self.imageView.image = originalImage // 4
}
```
## 16. Exploring and Method Swizzling Objective-C Frameworks


## 第四部分 自定义 LLDB 命令

## 17. Hello Script Bridging

LLDB 有多种方式来创建自定义命令：
- `commnad alias`：缺点是不能带参数
- `command regex`：对于多行命令、多个参数、可选参数的情况实现起来不太方便
- LLDB script bridging：LLDB 提供的 Python 接口，用来扩展 LLDB debugger


### 17.1 Credit where credit due


系统自带了一个牛逼闪闪的脚本，其中实现了 `malloc_info -s`、`obj_refs -O`、`ptr_refs` 等命令来查看对象使用的内存状态：
```
/Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A/Resources/Python/lldb/macosx/heap.py
```

> 注：这个脚本本身的实现也非常值得研究学习一下。

通过下面的命令可以将上面的脚本加载到当前的 LLDB 环境中：
```
 (lldb) command script import lldb.macosx.heap
```


### 17.2 Creating your first LLDB Python script

首先，创建 `~/lldb` 目录：
```shell
$ mkdir ~/lldb
```

然后在该目录下创建一个 python 脚本：
```shell
touch ~/lldb/helloworld.py
```

在上面新建的脚本中添加如下内容：
```python
def your_first_command(debugger, command, result, internal_dict):
  print ("hello world!")
```

在你的 LLDB 会话中，导入我们在上面新建的脚本（这里是为了告诉 LLDB 我们要从哪里（路径）添加一个脚本）：
```shell
(lldb) command script import ~/lldb/helloworld.py
```

接着再导入 helloworld 模块（Python 中的模块概念，具体介绍见[这里](https://github.com/ShannonChenCHN/APythonTour/issues/6)）：
```shell
(lldb) script import helloworld
```

此时，我们就可以在 LLDB 中使用 helloworld 模块了，下面这个命令是打印出 helloworld 模块中所有的方法：
```shell
(lldb) script dir(helloworld)
 ['__builtins__', '__doc__', '__file__', '__name__', '__package__', 'your_first_command']
```

最后，我们再以 `your_first_command` 函数作为输入，添加一条新的 LLDB 命令 `yay`：
```
 (lldb) command script add -f helloworld.your_first_command yay
```

这样，我们就可以在 LLDB 中直接通过调用 `yay` 命令来实现 `helloworld.your_first_command` 函数的调用了：
```
(lldb) yay
hello world!
```

### 17.3 Setting up commands efficiently

上一节中是手动导入我们的自定义脚本，实际上有更方便的方式。

LLDB 有一个 hook 函数 `__lldb_init_module`，当我们的模块加载到 LLDB 环境中时，这个函数就会被调用。

在我们前面创建的 `helloworld.py` 中添加下面的函数：

```python
def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand('command script add -f helloworld.your_first_command yay')
```

> debugger 是一个 LLDB `SBDebugger` 的对象实例，调用 `debugger.HandleCommand` 函数执行命令就相当于在 LLDB 命令行中直接输入命令。

然后再在 `~/.lldbinit` 文件中最后添加下面这条命令：
```
command script import ~/lldb/helloworld.py
```

这样，我们就可以直接在 LLDB 中使用 `yay` 命令了。

## 18. Debugging Script Bridging


### 18.1 初识 pdb 

跟 Objective-C 代码的 debugger LLDB 一样，Python 也有自己的 debugger pdb。


打开 `~/lldb/helloworld.py` 文件，修改 `your_first_command` 函数：
```python
def your_first_command(debugger, command, result, internal_dict):
    import pdb; pdb.set_trace()
    print ("hello world")
```

> 注：在 Xcode 中的 LLDB 环境不支持使用 pdb 调试 Python，pdb 调试只支持在命令行中的 LLDB 环境。

```
$ lldb
(lldb) yay woot
> /Users/derekselander/lldb/helloworld.py(3)your_first_command()
-> print ("hello world")
(Pdb)
```

当使用 Python 创建 LLDB 命令时，在所定义的 Python 函数中一般会有 3 个特定的参数：`debugger`，`command`，`result`：
```
(Pdb) command
'woot'
(Pdb) debugger
<lldb.SBDebugger; proxy of <Swig Object of type 'lldb::SBDebugger *' at 0x10d1dc570> >
(Pdb) result
<lldb.SBCommandReturnObject; proxy of <Swig Object of type 'lldb::SBCommandReturnObject *' at 0x10d323510> >
(Pdb) internal_dict
*** SystemExit: -1
```

跟 LLDB 一样，pdb 中也提供了 `c` 和 `continue` 命令以继续执行。


### 18.2 pdb 调试实战


打开模拟器的照片应用，然后启动 LLDB：
```
$ lldb -n MobileSlideShow
```

```shell
(lldb) command script import ~/lldb/findclass.py
(lldb) help findclass
     For more information run 'help findclass'  Expects 'raw' input (see 'help raw-input'.)

Syntax: findclass

    The findclass command will dump all the Objective-C runtime classes it knows about.
    Alternatively, if you supply an argument for it, it will do a case sensitive search
    looking only for the classes which contain the input.

    Usage: findclass  # All Classes
    Usage: findclass UIViewController # Only classes that contain UIViewController in name

(lldb) findclass
Traceback (most recent call last):
  File "/Users/xianglongchen/lldb/findclass.py", line 40, in findclass
    raise AssertionError("Uhoh... something went wrong, can you figure it out? :]")
AssertionError: Uhoh... something went wrong, can you figure it out? :]
```


```
(lldb) script import pdb
(lldb) findclass
Traceback (most recent call last):
  File "/Users/xianglongchen/lldb/findclass.py", line 40, in findclass
    raise AssertionError("Uhoh... something went wrong, can you figure it out? :]")
AssertionError: Uhoh... something went wrong, can you figure it out? :]
(lldb) script pdb.pm()
> /Users/xianglongchen/lldb/findclass.py(40)findclass()
-> raise AssertionError("Uhoh... something went wrong, can you figure it out? :]")
```

```
(Pdb) l 1, 50
  1   import lldb
  2
  3   def __lldb_init_module(debugger, internal_dict):
  ...
 39        if res.GetError():
 40  ->         raise AssertionError("Uhoh... something went wrong, can you figure it out? :]")

```

打印错误信息（我这边的错误跟原书上的有点不太一样）：
```
(Pdb) print res.GetError()
error: 'objc_getClassList' has unknown return type; cast the call to its declared return type
error: 'objc_getClassList' has unknown return type; cast the call to its declared return type
error: too many arguments to method call, expected 1, have 2
error: while importing modules:
error: Couldn't load top-level module Foundation
```

错误原因如下：
- 前两个错误的原因一样：在 LLDB 中调用函数时，有一个常见的问题是，LLDB 无法得知返回值的类型，所以需要进行类型强制转换
- 第三个错误的原因是，在调用方法 `-[NSMutableString appendFormat:]` 拼接 C 字符串时出错了（我在 Xcode 中试了下没问题，但是不知道为啥这里不行）
- 最后两个错误实际上是一个错误，去掉第一行的 `@import Foundation` 就好了

修改 `~/lldb/findclass.py` 脚本中的代码如下：
```
 codeString = r'''
    int numClasses;
    Class * classes = NULL;
    classes = NULL;
    numClasses = (int)objc_getClassList(NULL, 0);
    NSMutableString *returnString = [NSMutableString string];
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
    numClasses = (int)objc_getClassList(classes, numClasses);

    for (int i = 0; i < numClasses; i++) {
      Class c = classes[i];
      char *clsName = (char *)class_getName(c);
      NSString *clsNameObj = [NSString stringWithUTF8String:clsName];
      [returnString appendString:clsNameObj];
      [returnString appendString:@","];
    }
    free(classes);
    
    returnString;
    '''
```


修改完 `~/lldb/findclass.py` 脚本后，如果要让修改的内容生效，要么重新启动 LLDB，要么在 LLDB 环境中重新导入该脚本：
```
(lldb) command script import ~/lldb/findclass.py
```

使用组合键 `ctrl+D` 可以退出 pdb。


### 18.3 LLDB 命令的 Debug 选项

当使用 LLDB 的 `expression` 调试代码时，我们可以使用 `-g` 选项来调试参数中的代码，也就是 JIT code，如如上面 `~/lldb/findclass.py` 中的 codeString。


使用 `source list` 或者 `l` 命令可以查看当前调试的源代码：
```
(lldb) source list
```


使用 `gui` 命令可以以 gui 的形式来调试 JIT 代码：
```
(lldb) gui
```

### 18.4 常见问题

#### （1） Python build errors


第一种错误是编译时错误：
```
(lldb) command script import ~/lldb/findclass.py
error: module importing failed: ('unexpected indent', ('/Users/xianglongchen/lldb/findclass.py', 40, 4, '    debugger.GetCommandInterpreter().HandleCommand("expression -lobjc -g -O -- " + codeString, res)\n'))
  File "temp.py", line 1, in <module>
```

原因是第 39 行的代码没有对齐。

#### (2) Python runtime errors or unexpected values

第二种错误是运行时的错误，一般我们可以借助 pdb 进行调试，在源码中预期出现错误的地方加上下面这行代码进行调试：
```python
import pdb; pdb.set_trace()
```

然后再重新加载并执行时，pdb 就会自动在添加断点的地方停止，我们就可以查看变量信息了。

#### (3) JIT code build errors

这里的 JIT code 指的是传给 LLDB 命令作为参数执行的 code，比如上面 `~/lldb/findclass.py` 中的 codeString。

调试 JIT code 的编译错误比较麻烦，JIT 代码运行出错时 debugger 不会提供导致错误的源码的具体位置，我们只能通过错误信息进行推测，并注释掉一部分存在嫌疑的代码来进行排除。

#### (4) JIT code with unexpected results

第四种错误是 JIT 运行时错误，我们可以使用带 `--debug` 或者 `-g` 选项的 `expression` 命令来调试这种错误。


### 19. Script Bridging Classes and Hierarchy
### 20. Script Bridging with Options & Arguments
### 21. Script Bridging with SBValue & Memory


### 22. SB Examples, Improved Lookup
### 23. SB Examples, Resymbolicating a Stripped ObjC Binary
### 24. SB Examples, Malloc Logging

## 第五部分 DTrace

### 25. Hello, DTrace

- 什么是 DTrace？
- DTrace 可以用来干什么？

延伸阅读：    
- http://dtrace.org/guide/preface.html
- https://objccn.io/issue-19-4/
- http://www.brendangregg.com/dtracebook/index.html

#### 25.1 The bad news




### 26. Intermediate DTrace



### 27. DTrace vs objc_msgSend


