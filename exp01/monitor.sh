#!/bin/bash

# 重置终端字符串输出为“sgr0：正常屏幕”
# $()和``都可以执行命令
reset_terminal=$(tput sgr0)
# 声明关联数组script_array,关联数组用于处理用户选择数字和提示语句
declare -A script_array
#循环变量i，用于关联数组的循环
i=1
#提示语句变量，用于保存提示用户的信息
tips=""

# ls -I <file_name> 列出目标目录中所有的子目录和文件(-I 排除某个文件)
# for ... in $(...) 遍历命令返回值
for script_file in $(ls -I "monitor.sh" ./)
do
  # 修改输出文字的颜色，并输出提示字符串
  echo -e "\e[1;35m" "The Script: ${i} => ${reset_terminal} ${script_file}"
  # 将脚本文件名存入数组
  script_array[${i}]=${script_file}
  # 记录脚本个数,用于输出提示
  tips="${tips} | ${i}"
  # ((...)) 进行整数运算
  # $ 取值
  i=$((i+1))
done

# 无限循环
while true
do
  # 读入一个数字
  # -p 输入提示语句
  read -p "Please input a number [${tips}] (0:exit):" choice
  # [ ]是test的简写,[[ ]]是test的升级版(支持正则表达式)
  # =~ 检测字符串是否符合某个正则表达式
  if [[ ! ${choice} =~ ^[0-9]+ ]]; then
    echo "The input choice is not a Number!!!"
  else
    if [ ${choice} -eq 0 ]; then
      # 输入0
      echo "Bye Bye"
      exit 0
    elif [ ${choice} -lt 1 ] || [ ${choice} -gt 3 ]; then
      # 非法输入
      echo "Please input a number between 1-3!!!"
    else
      # 合法输入
      # 使用/bin/sh执行另一个脚本
      /bin/sh ./${script_array[${choice}]}
    fi
  fi
done