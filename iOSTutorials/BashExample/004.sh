#!/bin/bash

# 显示普通字符串

echo "It is an example"

# 显示转义字符

echo "\"It is a test\""

# 显示变量

echo "Please enter your name."
read name
echo "My name is $name."

# 显示换行
echo -e "OK! \n"    # -e 开启转义
echo "It an example."

# 显示不换行
echo -e "OK! \c"    # -e 开启转义  \c 表示不换行
echo "It an example."


# 显示结果定向至文件
file="/Users/xianglongchen/Desktop/test.txt"
echo "It an example." > $file


# 原样输出字符串，不进行转移或者取变量
echo '$name\"'


# 显示命令执行结果
echo `date`

# printf 

echo "Hello World"
printf "Hello World\n"

printf "%-10s %-8s %-4s\n" 姓名 性别 体重kg
printf "%-10s %-8s %-4.2f\n " 郭靖 男 66.7875
printf "%-10s %-8s %-4.2f\n " 杨过 男 48.7875