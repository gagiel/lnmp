#!/bin/bash

systemctl stop nginx

nginx_version=1.10.1
cur_dir=$(pwd)

# 安装依赖
yum -y install pcre-devel openssl-devel zlib-devel

# 编译安装
groupadd nginx
useradd -r -g nginx -s /bin/false nginx
curl -O http://nginx.org/download/nginx-$nginx_version.tar.gz
tar -zxvf nginx-$nginx_version.tar.gz
cd nginx-$nginx_version
./configure --prefix=/usr/local/nginx-$nginx_version \
--user=nginx \
--group=nginx \
--with-http_ssl_module
make && make install

# 添加快捷方式
rm -f /usr/local/nginx
ln -s /usr/local/nginx-$nginx_version /usr/local/nginx

# 配置nginx
rm -f /usr/local/nginx/conf/*.default
mkdir -p /var/www/ --context=system_u:object_r:usr_t:s0
mv -f /usr/local/nginx/html /var/www/default
rm -f /usr/local/nginx/conf/nginx.conf
rm -f /usr/local/nginx/conf/nginx.conf
cp $cur_dir/nginx.conf /usr/local/nginx/conf/
mkdir /usr/local/nginx/conf/conf.d/
cp $cur_dir/default.conf /usr/local/nginx/conf/conf.d/

# 设置systemd
rm -f /lib/systemd/system/nginx.service
cp $cur_dir/nginx.service /lib/systemd/system/nginx.service
systemctl enable nginx
systemctl start nginx
