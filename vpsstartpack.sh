#!/bin/bash

set_sep() {
echo "++++++++++++++++++++++++++++"
echo ""
echo ""
echo "++++++++++++++++++++++++++++"
}

updatesys() {
  echo "****************************"
  echo "*                          *"
  echo "********系统更新升级********"
  echo "*                          *"
  echo "****************************"

  read -p "是否升级更新系统软件包？(y/n) " upsys
  if [[ "$upsys" == "y" || "$upsys" == "Y" ]]; then
    apt-get update -y && apt-get upgrade -y
  fi
}

apttools() {
  echo "****************************"
  echo "*                          *"
  echo "******安装sudo curl apt*****"
  echo "*                          *"
  echo "****************************"
  read -p "是否安装常用工具？(y/n) " instool
  if [[ "$instool" == "y" || "$instool" == "Y" ]]; then
    apt install sudo curl apt -y
  fi
}

aptdocker() {
  echo "****************************"
  echo "*                          *"
  echo "*安装docker和docker-compose*"
  echo "*                          *"
  echo "****************************"
  
  read -p "是否安装docker和docker-compose？(y/n) " dock
  if [[ "$dock" == "y" || "$dock" == "Y" ]]; then
    echo "********安装docker和docker-compose......"
    # install docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh ./get-docker.sh

    # install docker-compose
    # apt-get install docker-compose -y
    curl -SL https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "++++++++++++++++++++安装完成...................."
    docker -v
    docker-compose --version
  fi
}

settzone() {
  echo "****************************"
  echo "*                          *"
  echo "**********更改时区**********"
  echo "*                          *"
  echo "****************************"
  # timedatectl set-timezone America/Chicago
  
  # 获取当前系统时区
  timezone=$(timedatectl | grep "Time zone" | awk '{print $3}')
  
  # 获取当前系统时间
  current_time=$(date +"%Y-%m-%d %H:%M:%S")
  
  # 显示时区和时间
  echo "当前系统时区：$timezone"
  echo "当前系统时间：$current_time"

  read -p "是否更改系统时区？(y/n) " chgzone
  if [[ "$chgzone" == "y" || "$chgzone" == "Y" ]]; then
    echo ""
    echo "时区切换"
    echo "亚洲------------------------"
    echo "1. 中国上海时间              2. 中国香港时间"
    echo "3. 日本东京时间              4. 韩国首尔时间"
    echo "欧洲------------------------"
    echo "5. 英国伦敦时间             6. 法国巴黎时间"
    echo "7. 德国柏林时间             8. 俄罗斯莫斯科时间"
    echo "9. 荷兰阿姆斯特丹时间       10. 西班牙马德里时间"
    echo "美洲------------------------"
    echo "11. 美国西部时间             12. 美国东部时间"
    echo "13. 美国中部时间             14. 美国山地时间"
    echo "15. 加拿大时间               16. 墨西哥时间"
    echo "------------------------"
    read -p "请输入你的选择: " sub_choice
      
    case $sub_choice in
        1) timedatectl set-timezone Asia/Shanghai ;;
        2) timedatectl set-timezone Asia/Hong_Kong ;;
        3) timedatectl set-timezone Asia/Tokyo ;;
        4) timedatectl set-timezone Asia/Seoul ;;
        5) timedatectl set-timezone Europe/London ;;
        6) timedatectl set-timezone Europe/Paris ;;
        7) timedatectl set-timezone Europe/Berlin ;;
        8) timedatectl set-timezone Europe/Moscow ;;
        9) timedatectl set-timezone Europe/Amsterdam ;;
        10) timedatectl set-timezone Europe/Madrid ;;
        11) timedatectl set-timezone America/Los_Angeles ;;
        12) timedatectl set-timezone America/New_York ;;
        13) timedatectl set-timezone America/Chicago ;;
        14) timedatectl set-timezone America/Denver ;;
        15) timedatectl set-timezone America/Vancouver ;;
        16) timedatectl set-timezone America/Mexico_City ;;
    esac
    timezone=$(timedatectl | grep "Time zone" | awk '{print $3}')
    echo "更改后系统时区：$timezone"
  fi
}

sethost() {
  echo "****************************"
  echo "*                          *"
  echo "********更改主机名**********"
  echo "*                          *"
  echo "****************************"
  current_hostname=$(hostname)
  echo -e "当前主机名: $current_hostname"
  
  read -p "是否更改主机名？(y/n) " chghost
  if [[ "$chghost" == "y" || "$chghost" == "Y" ]]; then
    echo "------------------------"
    read -p "请输入新的主机名（直接回车不更改）: " new_hostname
    
    if [ -n "$new_hostname" ] && [ "$new_hostname" != "0" ]; then
      hostnamectl set-hostname "$new_hostname"
      sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
      
      grep -q "$current_hostname" /etc/hosts
      if [ $? -eq 0 ]; then
          sed -i "s/$current_hostname/$new_hostname/g" /etc/hosts
      else
          sed -i "1 s/localhost/localhost $new_hostname/" /etc/hosts
      fi

      systemctl restart systemd-hostnamed
    else
      echo "未更改主机名。"
    fi
  fi
}

addnonrootusr() {
  echo "****************************"
  echo "*                          *"
  echo "*******创建非root用户*******"
  echo "*                          *"
  echo "****************************"
  read -p "是否创建非root用户？(y/n) " addu
  if [[ "$addu" == "y" || "$addu" == "Y" ]]; then
    echo "------------------------"
    read -p "创建非root用户（直接回车不创建）: " new_user
    if [ -n "$new_user" ] && [ "$new_user" != "0" ]; then
      adduser "$new_user"
      usermod -aG sudo "$new_user"
    else
      echo "未创建用户。"
    fi
  fi
}

adddockernet() {
  echo "****************************"
  echo "*                          *"
  echo "*******创建Docker网络*******"
  echo "*                          *"
  echo "****************************"
  read -p "是否创建Docker网络 (172.18.0.1/24)？(y/n) " docknet
  if [[ "$docknet" == "y" || "$docknet" == "Y" ]]; then
    docker network create --subnet=172.18.0.0/24 dockernet
  fi
}

aptmariadb() {
  echo "****************************"
  echo "*                          *"
  echo "******安装MariaDB数据库*****"
  echo "*                          *"
  echo "****************************"
  read -p "是否安装MariaDB？(y/n) " maria
  if [[ "$maria" == "y" || "$maria" == "Y" ]]; then
    apt install mariadb-server -y
    mysql_secure_installation
  fi
}

aptlighttpd() {
  echo "****************************"
  echo "*                          *"
  echo "******安装Lighttpd和PHP*****"
  echo "*                          *"
  echo "****************************"
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
}

aptcertbot() {
  echo "****************************"
  echo "*                          *"
  echo "*********安装CertBot********"
  echo "*                          *"
  echo "****************************"
  read -p "是否安装CertBot？(y/n) " cbot
  if [[ "$cbot" == "y" || "$cbot" == "Y" ]]; then
    apt install certbot -y
  fi
}

addphpinfo() {
  echo "****************************"
  echo "*                          *"
  echo "*******创建PHP测试网页******"
  echo "*                          *"
  echo "****************************"
  read -p "是否创建PHP测试网页？(y/n) " phpinfo
  if [[ "$phpinfo" == "y" || "$phpinfo" == "Y" ]]; then
    touch /var/www/html/infotest.php
    echo "<?php phpinfo() ?>" >> /var/www/html/infotest.php
    ipv4_address=$(curl -s ipv4.ip.sb)
    echo "PHP测试网页：http://$ipv4_address/infotest.php"
    echo "如果网页成功加载，说明Lighttpd和PHP的运行环境安装成功。"
  fi
}

clear
  echo "*********************************************************************************"
  echo "*                                                                               *"
  echo "*************************开始运行VPS初始设置一键脚本*****************************"
  echo "*            https://github.com/tigerzioo/vps_startpack                         *"
  echo "*********************************************************************************"
updatesys
set_sep
apttools
set_sep
aptdocker
set_sep
settzone
set_sep
sethost
set_sep
addnonrootusr
set_sep
adddockernet
set_sep
aptmariadb
set_sep
aptlighttpd
set_sep
aptcertbot
set_sep
addphpinfo
