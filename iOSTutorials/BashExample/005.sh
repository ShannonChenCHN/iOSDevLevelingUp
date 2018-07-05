#!/bin/bash

# 流程控制


#if else

a=10
b=20

if [ $a == $b ]
then
    echo "a 等于 b"
elif [ $a -gt $b ]
then
    echo "a 大于 b"
else
    echo "a 小于 b"
fi

if test $[a] -eq $[b]
then 
    echo "两个数字相等"
else 
    echo "两个数字不相等"
fi


# for 循环

echo "=========== for 语句 =============="

for i in 1 2 3 4 5
do 
    echo "The value is: $i"
done


for str in 'This is a string'
do 
    echo "\"$str\""
done

for ((i=0; i<3; i++)); do
    echo "$i"
done


# while 

echo "=========== while 语句 =============="
int=1
while(( $int<=5 ))
do 
    echo $int
    let "int++"
    # 上面这行代码等价于下面这行代码
    # int=`expr $int + 1`
done


# while 循环可以用于读取键盘输入信息

echo "按下 <CTRL-D> 退出"
echo -n "输入你最喜欢的网站名: "
while read FILM
do
    echo "是的！ $FILM 是一个好网站"
done


# until

echo "=========== until 语句 =============="

x=0

until [ ! $x -lt 10 ]
do
    echo $x
    x=`expr $x + 1`
done


# case 语句

echo "=========== case 语句 =============="
echo '输入 1 到 3 之间的数字:'
echo '你输入的数字为：'
read aNum
case $aNum in
    1) echo '你选择了 1'
    ;;
    2) echo '你选择了 2'
    ;;
    3) echo '你选择了 3'
    ;;
    *) echo '你没有选择 1 到 3 之间的数字'
    ;;
esac