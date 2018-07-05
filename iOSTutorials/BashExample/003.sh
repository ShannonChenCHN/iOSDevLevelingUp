#!/bin/bash

# 算数表达式

echo "======= 算数表达式 ========="

a=20
b=10

echo "a = $a"
echo "b = $b"

val=`expr $a + $b`
echo "a + b = $val"


val=`expr $a - $b`
echo "a - b = $val"

val=`expr $a \* $b`
echo "a * b = $val"


val=`expr $a / $b`
echo "a / b = $val"


val=`expr $a % $b`
echo "a % b = $val"

if [ $a == $b ]
then
    echo "a 等于 b"
fi

if [ $a != $b ]
then
    echo "a 不等于 b"
fi



# 关系运算符

echo "======= 关系运算符 ========="

if [ $a -eq $b ]
then 
    echo "$a -eq $b : a 等于 b"
else
    echo "$a -eq $b : a 不等于 b"
fi

# 不二运算符

echo "======== 布尔运算符 ========="

if [ $a -lt 100 -a $b -gt 15 ] 
then 
    echo "$a != $b : a 不等于 b"
else 
    echo "$a != $b : a 等于 b"
fi

# 逻辑运算符

echo "======== 逻辑运算符 =========="

if [[ $a -lt 100 && $b -gt 100 ]]
then 
    echo "返回 true"
else 
    echo "返回 false"
fi

# 字符串运算符

echo "============ 字符串运算符 =================="

stringA="abc"
stringB="cde"

if [ $stringA = $stringB ]
then 
    echo "$stringA = $stringB : a 等于 b"
else 
    echo "$stringA = $stringB : a 不等于 b"
fi


if [ -z $stringA ]
then 
    echo "-z $stringA : 字符串长度为 0"
else 
    echo "-z $stringA : 字符串长度不为 0"
fi




# 文件测试运算符

echo "======== 文件检测运算符 ======="

# 文件路径只能用绝对路径？
file="/Users/xianglongchen/Desktop/GitHubRepo/iOSLevelingUp/iOSTutorials/BashExample/003.sh"


if [ -e $file ]
then
    echo "文件存在"
else 
    echo "文件不存在"
fi


if [ -r $file ]
then
    echo "文件可读"
else 
    echo "文件不可读"
fi

if [ -s $file ]
then
    echo "文件不为空"
else 
    echo "文件为空"
fi

if [ -w $file ]
then
    echo "文件可写"
else 
    echo "文件不可写"
fi


if [ -x $file ]
the
    echo "文件可执行"
else 
    echo "文件不可执行"
fi


if [ -d $file ]
then
    echo "文件是目录"
else 
    echo "文件不是目录"
f