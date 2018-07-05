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
echo "=========查找字符串==========="
expr index "$myname" S
expr index "$myname" w
echo `expr index "$greeting" C`

# 数组
echo "=========数组==========="
array=("name" "age" "height" "sex")
echo ${array[2]}
echo ${array[@]} # 获取数组所有元素
echo ${#array[@]} # 数组长度



:<<EOF
echo "=========这里被注释了==========="
EOF