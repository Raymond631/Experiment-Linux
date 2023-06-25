#!/bin/bash

HOSTNAME="localhost"
PORT="3306"
USERNAME="Raymond"
PASSWORD="123456"
DBNAME="jpetstore"

# 拉取后端源码
cd ~
git clone https://gitee.com/raymond_li/JPetStore_Customer.git
cd JPetStore_Customer
#创建数据库
create_db_sql="create database IF NOT EXISTS ${DBNAME}"
mysql -h${HOSTNAME} -P${PORT} -u${USERNAME} -p${PASSWORD} -e "${create_db_sql}"
mysql -u$USERNAME -p$PASSWORD $DBNAME < sql/jpetstore.sql
# 后端打包并部署到tomcat中
mvn clean package
sudo rm /usr/local/tomcat/apache-tomcat-10.1.10/webapps/jpetstore.war
sudo rm -r /usr/local/tomcat/apache-tomcat-10.1.10/webapps/jpetstore
sudo cp target/jpetstore.war /usr/local/tomcat/apache-tomcat-10.1.10/webapps/

# 拉取前端源码
cd ~
git clone https://gitee.com/raymond_li/JPetStore_Vue.git
cd JPetStore_Vue
# 前端下载依赖并打包
npm install --unsafe-perm --registry=https://registry.npm.taobao.org
npm run build
sudo cp -r dist /usr/local/nginx/www/jpetstore
# 添加nginx自定义配置文件
sudo vi /usr/local/nginx/conf/conf.d/jpetstore.conf
sudo systemctl restart nginx.service

# 删除源码
cd ~
sudo rm -r JPetStore_Customer
sudo rm -r JPetStore_Vue
sudo systemctl restart tomcat