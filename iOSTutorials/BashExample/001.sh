#!/bin/bash

# 打印字符串
echo "This a Shell Script file!"


echo "===================="
# for 循环中打印文件名
for file in $(ls ~/DeskTop); do
    echo ${file}
done

echo "===================="

# 拼接字符串
myname="Shannon"
myfamilyname="Chen"
greeting="Hello, ${myname} "$myfamilyname""
echo ${greeting}

# 字符串长度
echo "=========字符串长度==========="
stringlength=${#myname}
echo "length of my name is ${stringlength}"

# 截取字符串
echo "=========截取字符串==========="
echo ${greeting:0:5}



# 查找字符串
echo `expr index "$greeting" Chen`

array=($myname $myfamilyname $greeting)
echo ${array[2]}
echo ${array[@]}

echo ${#array[@]}