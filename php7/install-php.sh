#!/bin/bash

systemctl stop php-fpm
php_version=7.0.9
cur_dir=$(pwd)

# 安装依赖
yum -y install libxml2-devel openssl-devel libcurl-devel libmcrypt-devel gd-devel postgresql-devel

# 编译安装
groupadd www-data
useradd -r -g www-data -s /bin/false www-data
curl -O http://cn.php.net/distributions/php-$php_version.tar.gz
tar -zxvf php-$php_version.tar.gz
cd php-$php_version
./configure --prefix=/usr/local/php-$php_version \
--with-config-file-path=/usr/local/php-$php_version/etc \
--enable-fpm \
--enable-opcache \
--enable-mysqlnd \
--enable-mbstring \
--enable-sockets \
--with-fpm-user=www-data \
--with-fpm-group=www-data \
--with-pdo-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-mysql-sock=/var/lib/mysql/mysql.sock \
--with-pgsql \
--with-pdo-pgsql \
--with-gd \
--with-zlib \
--with-curl \
--with-mcrypt \
--with-openssl
make && make install

# 添加快捷方式
rm -f /usr/local/php
rm -f /usr/bin/php
rm -f /usr/bin/phpize
rm -f /usr/bin/pear
rm -f /usr/bin/pecl
ln -sf /usr/local/php-$php_version/ /usr/local/php
ln -sf /usr/local/php/bin/php /usr/bin/php
ln -sf /usr/local/php/bin/phpize /usr/bin/phpize
ln -sf /usr/local/php/bin/pear /usr/bin/pear
ln -sf /usr/local/php/bin/pecl /usr/bin/pecl

# 配置php
mv -f php.ini-production /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
mv -f /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
sed -i 's,;pid = run/php-fpm.pid.*,pid = run/php-fpm.pid,g' /usr/local/php/etc/php-fpm.conf
mv -f /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's,listen = 127.0.0.1:9000,listen = var/run/php-fpm.sock,g' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/;listen.owner = www-data/listen.owner = nginx/g' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/;listen.group = www-data/listen.group = nginx/g' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' /usr/local/php/etc/php-fpm.d/www.conf

# systemd
rm -f /lib/systemd/system/php-fpm.service
cp $cur_dir/php-fpm.service /lib/systemd/system/php-fpm.service
systemctl enable php-fpm
systemctl start php-fpm

# 安装composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
composer config -g repo.packagist composer https://packagist.phpcomposer.com   #添加中国全量镜像地址
