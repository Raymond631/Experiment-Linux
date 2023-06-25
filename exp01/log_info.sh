#!/bin/bash

echo "This is log_info.sh"
# 定义nginx日志文件路径
logfile_path="/var/log/nginx/access.log"

# 定义函数
Get_http_status(){
    # cat 读文件
    # | 管道
    # grep 筛选
    # -i 忽略大小写进行匹配
    # -0 只显示匹配PATTERN部分
    # -E 将样式为延伸的正则表达式来使用
    # $2 该行第2个单词
    # 统计"各类"状态码的个数,并将结果保存到http_status_codes中
	http_status_codes=($(cat ${logfile_path} | grep -ioE "HTTP\/1\.[1|0]\"[[:blank:]][0-9]{3}" | awk '{
		if($2>=100&&$2<200)
			{i++}
		if($2>=200&&$2<300)
			{j++}
		if($2>=300&&$2<400)
			{k++}
		if($2>=400&&$2<500)
			{m++}
		if($2>=500)
			{n++}
		}END{print i?i:0,j?j:0,k?k:0,m?m:0,n?n:0,i+j+k+m+n}
		'))
    # 输出结果
	echo -e "The counter http status[100+]:${http_status_codes[0]}"
	echo -e "The counter http status[200+]:${http_status_codes[1]}"
	echo -e "The counter http status[300+]:${http_status_codes[2]}"
	echo -e "The counter http status[400+]:${http_status_codes[3]}"
	echo -e "The counter http status[500+]:${http_status_codes[4]}"
	echo -e "The counter http status[ALL]:${http_status_codes[5]}"
}

# 定义函数
Get_http_codes(){
    # 读取nginx日志文件
    # -v 声明变量
    # 统计"各个"状态码的个数和总请求个数
	http_codes=($(cat ${logfile_path} | grep -ioE "HTTP\/1.[1|0]\"[[:blank:]][0-9]{3}" | awk -v total=0 '{
			if($2!="")
				{code[$2]++;total++}
			else
				{exit}
		}END{print code[404]?code[404]:0,code[500]?codep[500]:0,total}'
  ))
  # 输出结果
	echo -e "The Count of 404:${http_codes[0]}"
	echo -e "The Count of 500:${http_codes[1]}"
	echo -e "The Count of All Request:${http_codes[2]}"
}

# 调用函数
Get_http_status
Get_http_codes