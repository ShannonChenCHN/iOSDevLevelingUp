# Shell Script


## 简介
### 1. Shell 与 Shell script

shell 是程序，shell 脚本是为 shell 编写的脚本程序。

### 2. Shell 环境

- Shell 编程需要一个文本编辑器和一个能解释执行的脚本解释器
- Linux 的 shell 有很多种



Mac 上的

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



## Shell 变量

命名规则
给变量赋值
读取/使用变量
只读变量
删除变量
变量类型

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


使用变量时需要加 “$”，￥后面加 {}


## Shell 传递参数


## Shell 基本运算符

原生bash不支持简单的数学运算，但是可以通过其他命令来实现，例如 awk 和 expr，expr 最常用。

expr 是一款表达式计算工具，使用它能完成表达式的求值操作。

- 算数运算符
- 关系运算符
- 布尔运算符
- 字符串运算符
- 文件测试运算符


## Shell echo 命令


## Shell printf 命令


## Shell 流程控制

- if-else
  - if
  - if-else
  - if-elif-else
- for 循环
  - for-in
- while 语句
- until 循环
- case 
- 跳出循环
  - break
  - continue
  - esac

## 调试

- [Shell脚本调试技术 - IBM](https://www.ibm.com/developerworks/cn/linux/l-cn-shell-debug/index.html)
- [如何调试BASH脚本](https://coolshell.cn/articles/1379.html)


### 问题

见 [这里](https://github.com/ShannonChenCHN/iOSLevelingUp/issues/2#issuecomment-338358993)。

  
  
### 参考资料
- [Shell 教程 - 菜鸟教程](http://www.runoob.com/linux/linux-shell.html)
- [学习 shell 有什么好书推荐？](https://www.zhihu.com/question/19745611)
- [Shell脚本编程总结及速查手册](https://ghui.me/post/2016/06/shell-handbook/)
- [10分钟入门Shell脚本编程](https://juejin.im/post/5a6378055188253dc332130a)
