# Shell 脚本学习总结


## 其他总结

- [Linux Shell 相关知识点](https://github.com/ShannonChenCHN/iOSLevelingUp/issues/2#issuecomment-338358993)
- [《The Linux Command Line》学习笔记](https://github.com/ShannonChenCHN/what-is-computer-science/blob/master/posts/The-Linux-Command-Line.md)


## 一、初识 Shell

参考：
- https://www.runoob.com/linux/linux-shell.html
- TLCL 第 24 章

### 1. Shell 与 Shell script

shell 是程序，shell 脚本是为 shell 编写的脚本程序。

### 2. Shell 环境

- Shell 编程需要一个文本编辑器和一个能解释执行的脚本解释器
- Linux 的 shell 有很多种
  - bash
  - zsh


尽管都是源自于 Unix，但是 Linux 是基于 GNU 的，而 Mac 是基于 BSD 的，所以 Mac 上的命令行跟 Linux 上还是有些细微差别的。

参考：
- https://github.com/ShannonChenCHN/iOSDevLevelingUp/issues/2#issuecomment-402622014

### 3. Hello World

shell 脚本文件的第一行是 `#!/bin/bash`，`#!`是一个约定的标记，通过其后路径所指定的程序，来告诉系统这个脚本需要什么解释器来执行，也就是使用哪一种 shell。

#### 3.1 运行 shell 的两种方法：

**（1）作为可执行程序**

首先保存成 `sh` 文件，然后 cd 到文件所在目录，执行 `chmod +x ./test.sh` 命令是脚本具有执行权限，然后再使用命令 `./<脚本文件名>` 执行该脚本。

注意点：一定要写成 `./test.sh`，而不是 `test.sh`。

**（2）作为解释器参数**

直接运行解释器，其参数就是 shell 脚本的文件名：

```
/bin/sh test.sh

```

#### 3.2 注释


### 4. 如何让系统能够自动搜索到脚本文件的位置

- 参考
  - TLCL 第 11 章、24 章

## 二、变量和常量

- 变量
  - 命名规则
  - 给变量赋值
  - 读取/使用变量
  - 只读变量
  - 删除变量
  - 变量类型
    - 局部变量
    - 环境变量
    - shell 变量
- 数字
- 字符串
  - 单引号、双引号
  - 拼接
  - 获取字符串长度
  - 截取子字符串
  - 查找子字符串
- 数组
  - 定义数组
  - 读取数组
  - 获取数组长度


使用变量时需要加 `$`，`$`后面加`{}`，比如 `${var1}` 表示使用变量 var1

参考：
  - TLCL 第 25 章、34 章、35 章
  - https://www.runoob.com/linux/linux-shell-array.html
  - https://www.runoob.com/linux/linux-shell-variable.html

## 三、基本运算符

原生bash不支持简单的数学运算，但是可以通过其他命令来实现，例如 awk 和 expr，expr 最常用。

expr 是一款表达式计算工具，使用它能完成表达式的求值操作。

- 算数运算符
  - `+`
  - `-` 
  - `*`
  - `/`
  - `%`
  - `=`
  - `==`
  - `!=`
- 关系运算符
  - `-eq`
  - `-ne`
  - `-gt`
  - `-lt`
  - `-ge`
  - `-le`
- 布尔运算符
  - `!`
  - `-o`
  - `-a`
- 逻辑运算符
  - `&&`
  - `||`
- 字符串运算符
  - `=`
  - `!=`
  - `-z`
  - `-n`
  - `$`
- 文件测试运算符

参考：
- https://www.runoob.com/linux/linux-shell-basic-operators.html

## 四、流程控制

- if 语句
  - if
  - if-else
  - if-elif-else
- test 命令
  - 表达式
    - 文件表达式
    - 字符串表达式
    - 整数表达式
  - test 命令的增强版 `[[ expression ]]`
  - 专门处理整数的复合命令 `(( expression ))`
  - 控制运算符
    - `command1 && command2`
    - `command1 || command2`
- for 循环
  - for-in
- while 循环
- until 循环
- case 分支
- 跳出循环
  - break
  - continue
  - esac

参考：
- https://www.runoob.com/linux/linux-shell-process-control.html
- TLCL 第 27 章、29 章、31 章、33 章


## 五、函数


- 参考
  - TLCL 第 26 章
  - https://www.runoob.com/linux/linux-shell-func.html

## 六、用户交互


- 接收和处理命令行参数
  - 参考：
    - TLCL 第 32 章
    - https://www.runoob.com/linux/linux-shell-passing-arguments.html
- 读取键盘输入
  - 参考
    - TLCL 第 28 章

## 七、错误定位和调试

参考：
- TLCL 第 30 章
- [Shell脚本调试技术 - IBM](https://www.ibm.com/developerworks/cn/linux/l-cn-shell-debug/index.html)
- [如何调试BASH脚本](https://coolshell.cn/articles/1379.html)


## 九、文件包含

参考：
- https://www.runoob.com/linux/linux-shell-include-file.html

## 八、shell 补充


- echo 命令和 printf 命令
  - 参考：
    - https://www.runoob.com/linux/linux-shell-echo.html
    - https://www.runoob.com/linux/linux-shell-printf.html
- 输入/输出重定向
  - 参考：https://www.runoob.com/linux/linux-shell-io-redirections.html



## 十、Coding style Guide

- 格式
- 命名规范
- 注释
- [Shell Style Guide - Google](https://google.github.io/styleguide/shell.xml)



  
  
### 参考资料
- [Shell 教程 - 菜鸟教程](http://www.runoob.com/linux/linux-shell.html)
- 《The Linux Command Line》（中文版：《Linux 命令行大全》）（推荐阅读）
- [学习 shell 有什么好书推荐？](https://www.zhihu.com/question/19745611)
- [Shell脚本编程总结及速查手册](https://ghui.me/post/2016/06/shell-handbook/)
- [10分钟入门Shell脚本编程](https://juejin.im/post/5a6378055188253dc332130a)
- [Shell脚本调试技术 - IBM](https://www.ibm.com/developerworks/cn/linux/l-cn-shell-debug/index.html)
- [如何调试BASH脚本](https://coolshell.cn/articles/1379.html)
- [Shell Style Guide - Google](https://google.github.io/styleguide/shell.xml)
