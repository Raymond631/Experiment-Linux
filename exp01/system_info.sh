#!/bin/bash

# 清空终端屏幕
clear

if [[ $# -eq 0 ]];then
  # 操作系统类型
	os=$(uname -o)
	echo -e "OS Type:${os}"
  # 操作系统版本
	os_version=$(cat /etc/centos-release)
	echo -e "OS Version:${os_version}"
  # CPU类型
	architecture=$(uname -m)
	echo -e "Architecture:${architecture}"
  # 内核版本号
	kernel=$(uname -r)
	echo -e "OS Kerner:${kernel}"
  # 主机名
	hostname=$(uname -n)
	echo -e "Hostname:${hostname}"
  # 主机内网IP地址
	internal_ip=$(hostname -I)
	echo -e "Internal IP:${internal_ip}"
  # 主机外网IP地址
  # curl基于url在命令行传输数据
	external_ip=$(curl -s http://ipecho.net/plain)
	echo -e "External IP:${external_ip}"
  # 获取DNS地址
  # grep用于搜索筛选
  # 行匹配语句 awk '' 只能用单引号，$NF表示最后一个单词
	dns=$(cat /etc/resolv.conf | grep -E "\<nameserver[ ]+" | awk '{print $NF}')
  # 给百度发2个ping数据包，并将输出重定向到空设备，测试网络连通性
  # &&表示则（前面的执行成功，后面的才执行），||表示否则（前面的执行失败，后面的才执行）
	ping -c 2 baidu.com &>/dev/null && echo "Internet Connected" || echo "Internet Disconnected"
  # 输出当前登录用户信息
    echo -e "Logged In Users...\n$(who)"
  # 获取内存使用量
	system_memory_usages=$(awk '/MemTotal/{total=$2}/MemFree/{free=$2}END {print (total-free)/1024}' /proc/meminfo)
	echo -e "System Memory Usages:${system_memory_usages} MB"
  # 获取应用内存占用量（即不算cached和buffers）
	app_memory_usages=$(awk '/MemTotal/{total=$2}/MemFree/{free=$2}/^Cache/{cached=$2}/Buffers/{buffers=$2}END {print (total-free-cached-buffers)/1024}' /proc/meminfo)
	echo -e "Applications Memory Usages:${app_memory_usages} MB"
  # 获取系统负载
	cpu_load_average=$(top -n 1 -b | grep "load average:" | awk '{print $10 $11 $12}')
	echo -e "CPU Load Average:${cpu_load_average}"
  # 获取磁盘使用量
 	disk_usages=$(df -hP | grep -vE "Filesystem|tmpfs" | awk '{print $1 " " $5}')
	echo -e "Disk Usages:${disk_usages}"
fi
