#!/bin/bash

set_sep() {
read -n 1 -s -r -p "按任意键继续..."
echo "++++++++++++++++++++++++++++"
echo ""
echo ""
echo "++++++++++++++++++++++++++++"
}

isInstalled() {
    if command -v $1 &> /dev/null; then
      echo "++++++++++ $1 已安装 ...................."
      if [ -z "$2" ]; then
        $1 -v
      elif [[ "$2" == "version" ]]; then
        $1 version
      else
        $1 --version
      fi
      return 0
    else
      echo "++++++++++ $1 未安装 ...................."
      return 1
    fi
}


updatesys() {
  echo "****************************"
  echo "*                          *"
  echo "********系统更新升级********"
  echo "*                          *"
  echo "****************************"

  read -p "是否升级更新系统软件包？(y/n/q) " upsys
  if [[ "$upsys" == "y" || "$upsys" == "Y" ]]; then
    apt-get update -y && apt-get upgrade -y
  elif [[ "$upsys" == "q" || "$upsys" == "Q" ]]; then
    exit
  else
    echo "++++++++++ 跳过系统软件包升级更新 ...................."
  fi
}

apttools() {
  echo "****************************"
  echo "*                          *"
  echo "******安装sudo curl apt*****"
  echo "*                          *"
  echo "****************************"
  read -p "是否安装常用工具？(y/n/q) " instool
  if [[ "$instool" == "y" || "$instool" == "Y" ]]; then
    apt install sudo curl apt -y
  elif [[ "$instool" == "q" || "$instool" == "Q" ]]; then
    exit
  else
    echo "++++++++++ 跳过常用工具安装 ...................."
  fi
}

addswap() {
  echo "****************************"
  echo "*                          *"
  echo "******设置swap虚拟内存******"
  echo "*                          *"
  echo "****************************"
  free -h
  swap_total=$(free -m | awk 'NR==3{print $2}')

  # Check swap
  if [ "$swap_total" -gt 0 ]; then
    echo "++++++++++ 虚拟内存已设置 ...................."
    # free -b | awk 'NR==2{printf "物理内存：%.0f MB" , ($2/1024/1024)}';
    # echo ""
    # free -m | awk 'NR==3{total=$2; printf "虚拟内存：%d MB",  total}'
    # echo " "
  else
    echo "++++++++++ 虚拟内存还未设置 ...................."
    mem_total=$(free -b | awk 'NR==2{printf "%.0f" , ($2/1024/1024/1024-int($2/1024/1024/1024)>0)?int($2/1024/1024/1024)+1:int($2/1024/1024/1024)}')
    read -p "是否添加 $mem_total GB 虚拟内存？(y/n/q) " addswap
    if [[ "$addswap" == "y" || "$addswap" == "Y" ]]; then
      fallocate -l ${mem_total}G /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
      echo "vm.swappiness=20" >> /etc/sysctl.conf
      echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
      sysctl vm.swappiness=20
      sysctl vm.vfs_cache_pressure=50
      echo "++++++++++ 虚拟内存设置成功 ...................."
      free -h
    elif [[ "$addswap" == "q" || "$addswap" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 跳过虚拟内存设置 ...................."
    fi
  fi
}

aptdocker() {
  echo "****************************"
  echo "*                          *"
  echo "*安装docker和docker-compose*"
  echo "*                          *"
  echo "****************************"

  if ! isInstalled "docker"; then
    read -p "是否安装docker？(y/n/q) " dock
    if [[ "$dock" == "y" || "$dock" == "Y" ]]; then
      echo "++++++++++ 安装docker ...................."
      # install docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh ./get-docker.sh
  
      echo "++++++++++ 安装完成 ...................."
      docker -v
    elif [[ "$dock" == "q" || "$dock" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 跳过 docker 安装 ...................."
    fi
  fi

  if ! isInstalled "docker-compose"; then
    read -p "是否安装docker-compose？(y/n/q) " dockcom
    if [[ "$dockcom" == "y" || "$dockcomd" == "Y" ]]; then
      echo "++++++++++ 安装 docker-compose ...................."
      # install docker-compose
      # apt-get install docker-compose -y
      curl -SL https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
      echo "++++++++++ 安装完成 ...................."
      docker-compose -v
    elif [[ "$dockcom" == "q" || "$dockcom" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 跳过docker-compose安装 ...................."
    fi
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

  read -p "是否更改系统时区？(y/n/q) " chgzone
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
    echo "++++++++++ 更改后系统时区：$timezone ...................."
  elif [[ "$chgzone" == "q" || "$chgzone" == "Q" ]]; then
    exit
  else
    echo "++++++++++ 未更改系统时区 ...................."
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
  
  read -p "是否更改主机名？(y/n/q) " chghost
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
      echo "++++++++++ 主机名更改为：$new_hostname ...................."
   elif [[ "$chghost" == "q" || "$chghost" == "Q" ]]; then
    exit
   else
      echo "++++++++++ 未更改主机名 ...................."
    fi
  else
    echo "++++++++++ 未更改主机名 ...................."
  fi
}

addnonrootusr() {
  echo "****************************"
  echo "*                          *"
  echo "*******创建非root用户*******"
  echo "*                          *"
  echo "****************************"
  echo "当前用户："
  getent passwd {1000..2000} | cut -d: -f1
  read -p "是否创建非root用户？(y/n/q) " addu
  if [[ "$addu" == "y" || "$addu" == "Y" ]]; then
    echo "------------------------"
    read -p "创建非root用户（直接回车不创建）: " new_user
    if [ -n "$new_user" ] && [ "$new_user" != "0" ]; then
      adduser "$new_user"
      usermod -aG sudo "$new_user"
      echo "++++++++++ 创建新用户：$new_user ...................."
    else
      echo "++++++++++ 未创建新用户 ...................."
    fi
  elif [[ "$addu" == "q" || "$addu" == "Q" ]]; then
    exit
  else
    echo "++++++++++ 未创建新用户 ...................."
  fi
}

adddockernet() {
  echo "****************************"
  echo "*                          *"
  echo "*******创建Docker网络*******"
  echo "*                          *"
  echo "****************************"
  if docker network inspect dockernet &> /dev/null; then
    echo "++++++++++ Docker 网络 (172.18.0.1/24) 已创建 ...................."
  else
    read -p "是否创建 Docker 网络 (172.18.0.1/24)？(y/n/q) " docknet
    if [[ "$docknet" == "y" || "$docknet" == "Y" ]]; then
      docker network create --subnet=172.18.0.0/24 dockernet
    elif [[ "$docknet" == "q" || "$docknet" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 未创建 Docker 网络 ...................."
    fi
  fi
}

aptmariadb() {
  echo "****************************"
  echo "*                          *"
  echo "******安装MariaDB数据库*****"
  echo "*                          *"
  echo "****************************"
  
  if ! isInstalled "mariadb" "--version"; then
    read -p "是否安装MariaDB？(y/n/q) " maria
    if [[ "$maria" == "y" || "$maria" == "Y" ]]; then
      PS3="请选择 MariaDB 的版本："
      select ver in "系统自带版本" "11.4"
      do
        if [[ "$REPLY" == 1 ]]; then
          echo "++++++++++ 安装 Mariadb 系统自带版本 ...................."
          apt install mariadb-server -y
          mysql_secure_installation
          break
        elif [[ "$REPLY" == 2 ]]; then
          echo "++++++++++ 安装 Mariadb 11.4 ...................."
          curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.4.3
          apt update
          apt -y install mariadb-server mariadb-client
          mariadb-secure-installation
          echo "++++++++++ Mariadb 安装完成 ...................."
          mariadb --version
          break
        else
          echo "++++++++++ 跳过 Mariadb 安装 ...................."
        fi
      done
    elif [[ "$maria" == "q" || "$maria" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 跳过 Mariadb 安装...................."
    fi
  fi
}

aptlighttpd() {
  echo "****************************"
  echo "*                          *"
  echo "******安装Lighttpd和PHP*****"
  echo "*                          *"
  echo "****************************"

  if ! isInstalled "lighttpd" || ! isInstalled "php"; then
  
    read -p "是否安装 Lighttpd 和 PHP ？(y/n/q) " httpd
    if [[ "$httpd" == "y" || "$httpd" == "Y" ]]; then
      if ! isInstalled "lighttpd"; then
        apt install lighttpd -y
      fi

      if ! isInstalled "php"; then
        apt install php-cgi -y
      fi
    
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

      addphpinfo

      elif [[ "$httpd" == "q" || "$httpd" == "Q" ]]; then
        exit
      else
        echo "++++++++++ 跳过 Lighttpd 和 PHP 安装 ...................."
      fi
    else
      addphpinfo
    fi
  }

aptcaddy() {
  echo "****************************"
  echo "*                          *"
  echo "*******安装 Caddy 反代******"
  echo "*                          *"
  echo "****************************"
  if ! isInstalled "caddy" "version"; then
    read -p "是否安装 Caddy ？(y/n/q) " caddy
    if [[ "$caddy" == "y" || "$caddy" == "Y" ]]; then
      if isInstalled "lighttpd"; then
        echo "***** Lighttpd 已安装，如果继续安装 Caddy，Lighttpd 的端口将被改成 1080，Caddy 将占用 80 端口 ******"
        read -p "是否继续安装 Caddy ？(y/n) " caddy80
        if [[ "$caddy" == "y" || "$caddy" == "Y" ]]; then
          sed -i "s/server.port = 80/server.port = 1080/g" /etc/lighttpd/lighttpd.conf
          systemctl restart lighttpd
        else
          echo "++++++++++ 跳过 Caddy 安装 ...................."
        fi
      fi
      # apt install caddy -y
    elif [[ "$caddy" == "q" || "$caddy" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 跳过 Caddy 安装 ...................."
    fi
  fi

}

aptcertbot() {
  echo "****************************"
  echo "*                          *"
  echo "*********安装CertBot********"
  echo "*                          *"
  echo "****************************"
  if ! isInstalled "certbot" "--version"; then
    read -p "是否安装CertBot？(y/n/q) " cbot
    if [[ "$cbot" == "y" || "$cbot" == "Y" ]]; then
      apt install certbot -y
    elif [[ "$cbot" == "q" || "$cbot" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 跳过 Certbot 安装 ...................."
    fi
  fi
}

addphpinfo() {
  echo "****************************"
  echo "*                          *"
  echo "*******创建PHP测试网页******"
  echo "*                          *"
  echo "****************************"
  if [ -f "/var/www/html/infotest.php" ]; then
    echo "++++++++++ PHP测试网页已存在 ...................."
    echo "http://$ipv4_address/infotest.php"
    echo "如果网页成功加载，说明Lighttpd和PHP的运行环境安装成功。"
    echo "++++++++++++++++++++++++++++++++++++++++"
    echo ""
  else
    read -p "是否创建PHP测试网页？(y/n/q) " phpinfo
    if [[ "$phpinfo" == "y" || "$phpinfo" == "Y" ]]; then
      touch /var/www/html/infotest.php
      echo "<?php phpinfo() ?>" >> /var/www/html/infotest.php
      ipv4_address=$(curl -s ipv4.ip.sb)
      echo "++++++++++ PHP测试网页 ...................."
      echo "http://$ipv4_address/infotest.php"
      echo "如果网页成功加载，说明Lighttpd和PHP的运行环境安装成功。"
      echo "++++++++++++++++++++++++++++++++++++++++"
      echo ""
    elif [[ "$phpinfo" == "q" || "$phpinfo" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 未创建PHP测试网页 ...................."
      echo ""
    fi
  fi
}

clear
  echo "*********************************************************************************"
  echo "*                                                                               *"
  echo "*************************开始运行VPS初始设置一键脚本*****************************"
  echo "*            https://github.com/tigerzioo/vps_startpack                         *"
  echo "*            y：确认安装配置；n：跳过此项安装配置；q：退出脚本                             *"
  echo "*********************************************************************************"

updatesys
set_sep
apttools
set_sep
addswap
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
aptcaddy
set_sep
aptcertbot

echo "*********************************************************************************"
echo "*                                                                               *"
echo "*********************脚本运行完成，如果需要还可以重新执行脚本********************"
echo "*            https://github.com/tigerzioo/vps_startpack                         *"
echo "*********************************************************************************"
echo ""
