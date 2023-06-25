**以下内容基于CentOS 7，建议使用MobaXterm等SSH工具远程连接，比图形化界面更好用**
如有问题，恳请指正~
> 2023-6-25更新：添加操作日志；nginx调整conf.d的路径；添加redis-cli软链接；
> 2023-6-17更新：nginix结合部署需要，添加了一些内容
> 2023-6-15更新：springboot 6 不支持 tomcat 9 ,故改为安装tomcat 10 (不过tomcat 10 不支持 java 8 ,老项目请斟酌)  
# 前置工作（可选）
## 添加操作日志
```
vi /etc/profile
```
在末尾追加以下内容
```
# 操作日志
history
USER=`whoami`
USER_IP=`who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`
if [ "$USER_IP" = "" ]; then
USER_IP=`hostname`
fi
if [ ! -d /var/log/history ]; then
mkdir /var/log/history
chmod 777 /var/log/history
fi
if [ ! -d /var/log/history/${LOGNAME} ]; then
mkdir /var/log/history/${LOGNAME}
chmod 300 /var/log/history/${LOGNAME}
fi
export HISTSIZE=4096
DT=`date +"%Y%m%d_%H:%M:%S"`
export HISTFILE="/var/log/history/${LOGNAME}/${USER}@${USER_IP}_$DT"
chmod 600 /var/log/history/${LOGNAME}/*history* 2>/dev/null
```
操作日志在/var/log/history里面
## 修改SSH端口
```
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_backup
vi /etc/ssh/sshd_config
systemctl restart sshd
```
## 添加普通用户
```
adduser raymond
passwd raymond
```
## 添加sudo权限
```
su
cd /etc
chmod u+x sudoers
vi sudoers
chmod u-x sudoers
su raymond
```
## 升级系统软件
```
sudo yum update
```
## 安装net-tools
```
sudo yum install net-tools
ifconfig
```
## 安装wget
```
sudo yum install wget
```
# 安装Git
```
sudo yum install git
git --version
```
# 安装JDK 17
```
cd ~
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
sudo rpm -ivh jdk-17_linux-x64_bin.rpm
java -version
```
# 安装Tomcat 10
> springboot 6 不支持 tomcat 9
```
cd ~
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.10/bin/apache-tomcat-10.1.10.tar.gz
cd /usr/local/
sudo mkdir tomcat
cd tomcat/
sudo tar -zxvf ~/apache-tomcat-10.1.10.tar.gz -C ./
cd /etc/rc.d/init.d/
sudo touch tomcat
sudo chmod +x tomcat
sudo vi tomcat
```
配置自启动
```
#!/bin/bash
#chkconfig:- 20 90
#description:tomcat
#processname:tomcat
TOMCAT_HOME=/usr/local/tomcat/apache-tomcat-10.1.10
case $1 in
    start) su root $TOMCAT_HOME/bin/startup.sh;;
    stop) su root $TOMCAT_HOME/bin/shutdown.sh;;
    *) echo "require start|stop" ;;
esac
```
启动服务，开放8080端口
```
sudo service tomcat start
sudo chkconfig --add tomcat
sudo chkconfig tomcat on
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo systemctl restart firewalld.service
sudo firewall-cmd --reload
```
# 安装Nginx
```
cd ~
wget https://nginx.org/download/nginx-1.24.0.tar.gz
cd /usr/local/
sudo mkdir nginx
cd nginx
sudo tar -zxvf ~/nginx-1.24.0.tar.gz -C ./
sudo yum -y install pcre-devel
sudo yum -y install openssl openssl-devel
cd nginx-1.24.0/
sudo ./configure
sudo make && sudo make install
cd /lib/systemd/system/
sudo vi nginx.service
```
配置自启动
```
[Unit]
Description=nginx service
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
启动服务，开放80和4443端口
```
sudo systemctl enable nginx
sudo systemctl start nginx.service
sudo systemctl status nginx.service
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo systemctl restart firewalld.service
sudo firewall-cmd --reload
```
添加自定义配置目录conf.d、项目文件目录www
```
sudo mkdir /usr/local/nginx/conf/conf.d
sudo mkdir /usr/local/nginx/www
sudo vi /usr/local/nginx/conf/nginx.conf
```
在http{......}里面的最后添加如下配置
```
include /usr/local/nginx/conf/conf.d/*.conf;
```
# 安装Maven
```
cd ~
wget https://dlcdn.apache.org/maven/maven-3/3.9.2/binaries/apache-maven-3.9.2-bin.tar.gz
cd /opt/
sudo mkdir maven
cd maven/
sudo tar -zxvf ~/apache-maven-3.9.2-bin.tar.gz -C ./
cd apache-maven-3.9.2/conf/
sudo vi settings.xml
```
添加阿里云镜像
```
    <mirror>
     <id>alimaven</id>
     <name>aliyun maven</name>
     <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
     <mirrorOf>central</mirrorOf>
    </mirror>
```
配置环境变量
```
sudo vi /etc/profile
```
添加以下内容
```
export MAVEN_HOME=/opt/maven/apache-maven-3.9.2
export PATH=$MAVEN_HOME/bin:$PATH
```
重新加载配置文件
```
sudo -s
source /etc/profile
su raymond
cd ~
mvn -v
```
# 安装Python 3
```
cd ~
wget https://www.python.org/ftp/python/3.9.13/Python-3.9.13.tgz
tar -zxvf Python-3.9.13.tgz
sudo yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make
cd Python-3.9.13/
sudo ./configure prefix=/usr/local/python3
sudo make && sudo make install
sudo ln -s /usr/local/python3/bin/python3 /usr/bin/python3
sudo ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
```
# 安装Node 16
> Centos 7不支持Node 18
```
cd ~
wget https://nodejs.org/download/release/latest-v16.x/node-v16.20.1-linux-x64.tar.gz
cd /usr/local/
sudo mkdir node
cd node/
sudo tar -zxvf ~/node-v16.20.1-linux-x64.tar.gz -C ./
cd ~
vi .bash_profile
```
添加环境变量
```
export PATH=/usr/local/node/node-v16.20.1-linux-x64/bin:$PATH
```
重新加载配置文件
```
source ~/.bash_profile
node -v
npm -v
```
# 安装Redis
```
cd ~
wget https://github.com/redis/redis/archive/7.0.11.tar.gz
cd /usr/local/
sudo mkdir redis
cd redis
sudo tar -zxvf ~/redis-7.0.11.tar.gz -C ./
cd redis-7.0.11/
sudo make && sudo make install
cd utils/
sudo vi ./install_server.sh
```
注释掉 下面的代码
```
#bail if this system is managed by systemd
#_pid_1_exe="$(readlink -f /proc/1/exe)"
#if [ "${_pid_1_exe##*/}" = systemd ]
#then
#       echo "This systems seems to use systemd."
#       echo "Please take a look at the provided example service unit files in this directory, and adapt and install them. Sorry!"
#       exit 1
#fi
```
开始安装
```
sudo ./install_server.sh
```
全部选择默认即可，由于executable path没有默认项，故输入/usr/local/bin/redis-server
```
sudo systemctl restart redis_6379.service
systemctl status redis_6379.service
sudo vi /etc/redis/6379.conf
```
将 bind 127.0.0.1 修改为 0.0.0.0
> 命令模式下按/搜索，按n下一个，按N上一个  

开放6379端口
```
sudo systemctl restart redis_6379.service
sudo firewall-cmd --zone=public --add-port=6379/tcp --permanent
sudo systemctl restart firewalld.service
sudo firewall-cmd --reload
```
添加软连接
```
sudo ln -s /usr/local/bin/redis-cli /usr/bin/redis-cli
```
下面的为添加密码（选做）
```
sudo vi /etc/redis/6379.conf
# 将 #requirepass foobared 的注释去掉，将 foobared 改为⾃⼰的密码
systemctl restart redis_6379.service
```
# 安装Mysql 8
查看glibc版本
```
/lib64/libc.so.6
```
下载对应的版本并安装
```
cd ~
wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.33-linux-glibc2.12-x86_64.tar.xz
sudo yum remove $(rpm -qa | grep mariadb)
sudo tar -xvJf mysql-8.0.33-linux-glibc2.12-x86_64.tar.xz -C /usr/local/
sudo mv /usr/local/mysql-8.0.33-linux-glibc2.12-x86_64 /usr/local/mysql
sudo groupadd mysql
sudo useradd -g mysql mysql
cd /usr/local/mysql/
sudo mkdir data
sudo chown -R mysql:mysql ./
sudo vi /etc/my.cnf
```
编写配置文件
```
[mysql]
default-character-set=utf8mb4
socket=/var/lib/mysql/mysql.sock

[client]
port=3306
default-character-set=utf8mb4

[mysqld]
port=3306
socket=/var/lib/mysql/mysql.sock
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
max_connections=1000
max_connect_errors=100
character-set-server=utf8mb4
default-storage-engine=INNODB
default_authentication_plugin=mysql_native_password
lower_case_table_names = 1
interactive_timeout = 1800
wait_timeout = 1800
lock_wait_timeout = 3600
tmp_table_size = 64M
max_heap_table_size = 64M
```
开始安装
```
sudo mkdir /var/lib/mysql
sudo chmod 777 /var/lib/mysql
cd /usr/local/mysql/
sudo ./bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data

# 记住最后一行root@localhost:后面的密码，首次登录用

sudo cp ./support-files/mysql.server /etc/init.d/mysqld
sudo vi /etc/init.d/mysqld
```
修改basedir=和datadir=为下面的内容
```
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
```
配置自启动
```
sudo chmod +x /etc/init.d/mysqld
sudo chkconfig --add mysqld
sudo chkconfig --list mysqld
sudo service mysqld start
vi ~/.bash_profile
```
添加环境变量
```
export PATH=$PATH:/usr/local/mysql/bin
```
重新加载配置文件
```
source ~/.bash_profile
mysql -u root -p
```
进入mysql交互模式
```
alter user user() identified by "123456";  # 修改root密码
create user 'Raymond'@'%' identified with mysql_native_password by '123456';  # 添加新用户
grant all privileges on *.* to 'Raymond'@'%';
flush privileges;
```
退出mysql模式，继续输入命令开放3306端口
```
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo systemctl restart firewalld.service
sudo firewall-cmd --reload
```

# 安装Docker
```
sudo yum install -y docker
sudo systemctl start docker.service
sudo docker version
sudo systemctl enable docker.service
sudo vi /etc/docker/daemon.json
```
添加网易云镜像（可以自行选择镜像）
```
{
    "registry-mirrors": ["http://hub-mirror.c.163.com"]
}
```
添加用户组
```
sudo systemctl daemon-reload
sudo systemctl restart docker.service
sudo groupadd docker
sudo usermod -aG docker ${USER}
sudo systemctl restart docker
su root
su ${USER}
```
安装docker-compose
```
cd ~
wget https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-linux-x86_64
sudo cp docker-compose-linux-x86_64 /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose version
```