#!/bin/bash
rpm -Uvh http://repo.mysql.com/mysql57-community-release-el7-8.noarch.rpm
yum -y install mysql-community-server
systemctl enable mysqld
systemctl start mysqld

# 显示密码
echo "默认密码是: "
grep 'temporary password' /var/log/mysqld.log

# 修改密码
echo "修改密码: 进入数据库后执行命令: ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass'"
#ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!'; 
