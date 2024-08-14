#!/bin/bash

echo "********系统更新升级......"
apt-get update -y && apt-get upgrade -y
echo "********安装sudo，curl......"
apt install sudo curl -y

echo "********安装docker和docker-compose......"
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
apt-get install docker-compose -y

echo "********更改时区到美国中部时区......"
timedatectl set-timezone America/Chicago

current_hostname=$(hostname)
echo -e "当前主机名: $current_hostname"
echo "------------------------"
read -p "请输入新的主机名（直接回车不更改）: " new_hostname

if [ -n "$new_hostname" ] && [ "$new_hostname" != "0" ]; then
  hostnamectl set-hostname "$new_hostname"
  sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
  sed -i "1 s/localhost/localhost $new_hostname/" /etc/hosts
  systemctl restart systemd-hostnamed
else
  echo "未更改主机名。"
fi

echo "------------------------"
read -p "创建新用户（直接回车不创建）: " new_user
if [ -n "$new_user" ] && [ "$new_user" != "0" ]; then
  adduser "$new_user"
  usermod -aG sudo "$new_user"
else
  echo "未创建用户。"
fi

read -p "是否创建Docker网络？(y/n) " docknet
if [[ "$docknet" == "y" || "$docknet" == "Y" ]]; then
  docker network create --subnet=172.18.0.0/24 dockernet
fi

read -p "是否安装MariaDB？(y/n) " maria
if [[ "$maria" == "y" || "$maria" == "Y" ]]; then
  apt install mariadb-server -y
  mysql_secure_installation
fi

read -p "是否安装Lighttpd和PHP？(y/n) " httpd
if [[ "$httpd" == "y" || "$httpd" == "Y" ]]; then
  apt install lighttpd php-cgi -y
  
  # Enable PHP CGI module
  echo "" >> /etc/lighttpd/lighttpd.conf
  echo "# Enable PHP CGI module" >> /etc/lighttpd/lighttpd.conf
  echo "server.modules += (" >> /etc/lighttpd/lighttpd.conf
  echo "  \"mod_fastcgi\"," >> /etc/lighttpd/lighttpd.conf
  echo ")" >> /etc/lighttpd/lighttpd.conf

  echo "" >> /etc/lighttpd/lighttpd.conf
  echo "# Handle PHP scripts" >> /etc/lighttpd/lighttpd.conf
  echo "fastcgi.server = ( \".php\" =>" >> /etc/lighttpd/lighttpd.conf
  echo "  ((" >> /etc/lighttpd/lighttpd.conf
  echo "    \"socket\" => \"/var/run/lighttpd/php.socket\"," >> /etc/lighttpd/lighttpd.conf
  echo "    \"bin-path\" => \"/usr/bin/php-cgi\"" >> /etc/lighttpd/lighttpd.conf
  echo "  ))" >> /etc/lighttpd/lighttpd.conf
  echo ")" >> /etc/lighttpd/lighttpd.conf

  systemctl restart lighttpd
fi

read -p "是否安装CertBot？(y/n) " cbot
if [[ "$cbot" == "y" || "$cbot" == "Y" ]]; then
  apt install certbot
fi

read -p "是否创建PHP测试网页？(y/n) " phpinfo
if [[ "$phpinfo" == "y" || "$phpinfo" == "Y" ]]; then
  touch /var/www/html/infotest.php
  echo "<?php phpinfo() ?>" >> /var/www/html/infotest.php
  ipv4_address=$(curl -s ipv4.ip.sb)
  echo "PHP测试网页：http://$ipv4_address/infotest.php"
  echo "如果网页能成功加载，就说明Lighttpd和PHP的运动环境安装成功。"
fi
