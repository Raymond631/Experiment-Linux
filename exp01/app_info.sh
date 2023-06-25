#!/bin/bash

echo "This is app_info.sh"

# 定义nginx和mysql的访问地址
nginx_server='http://127.0.0.1'
mysql_server='127.0.0.1'

Nginx_info(){
    # -m 最大传输时间
    # -s slient模式,不输出任何东西
    # -w %{http_code} 控制额外输出
    # -o 把curl返回的网页写到垃圾回收站[/dev/null](屏蔽原有输出信息);
	status_code=$(curl -m 5 -s -w %{http_code} ${nginx_server}/nginx_status -o /dev/null)
    # [ ]是test命令的简写(两端有空格)
    # -eg 相等; -ge 大于等于; -o 逻辑或
	if [ ${status_code} -eq 000 -o ${status_code} -ge 500 ]; then
		echo -e "Check Nginx Server Error!"
		echo -e "Response Status Code is :${status_code}"
	else
		echo -e "Check Nginx Server OK!"
        # 访问http://192.168.3.186/nginx_staus
		curl -s ${nginx_server}/nginx_status
	fi
}

MySQL_info(){
    # -z 使用零输入/输出模式，只在扫描通信端口时使用
    # -w<超时秒数> 设置等待连线的时间。
    # 扫描3306端口,判断mysql是否启动
	nc -z -w2 ${mysql_server} 3306 &> /dev/null
    # $? 获取上一个命令的退出状态,0为正常退出
	if [ $? -eq 0 ]; then
		echo -e "Connect MySQL Server ${mysql_server}:3306 OK"
        # -e 执行各种sql
        # 2>/dev/null 将错误输出流重定向到垃圾桶
        # grep 筛选
        # head -1 第一行
        # $2 第二个单词
		mysql_uptimes=$(mysql -uRaymond -p1027@LiLei -h${mysql_server} -e "show status" 2>/dev/null | grep "Uptime" | head -1 | awk '{print $2}')
		echo -e "MySQL Uptime: ${mysql_uptimes}"
	else
		echo -e "Connect MySQL Server ${mysql_server}:3306 Failure!"
	fi
}

# 调用函数
Nginx_info
MySQL_info
