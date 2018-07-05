#!/bin/bash



# 函数
foo() {
    echo "Do something"

    echo "输入第一个数字："
    read aNum
    echo "输入第二个数字："
    read anotherNum 

    echo "总共有 $# 个参数"
    echo "第一个参数是： $1"

    return $(($aNum+$anotherNum))
}
foo 56 # 所有函数必须在被调用前就已经定义好，所以一般将函数放在脚本开始的部分
echo "输入的两个数字之和为 $?"  # 函数返回值在调用该函数后通过 $? 来获得

