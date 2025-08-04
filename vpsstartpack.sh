#!/bin/bash

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot detect OS - /etc/os-release not found."
    exit 1
fi

set_sep() {
read -n 1 -s -r -p "按任意键继续..."
echo "++++++++++++++++++++++++++++"
echo ""
echo ""
echo "++++++++++++++++++++++++++++"
}

go_menu() {
read -n 1 -s -r -p "按任意键返回主菜单..."
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
    read -p "是否修改虚拟内存配置？(y/n/q) " changeswap
    if [[ "$changeswap" == "y" || "$changeswap" == "Y" ]]; then
      read -p "请输入要配置的虚拟内存大小 (GB) " swapsize
      swapoff /swapfile
      rm /swapfile
      fallocate -l ${swapsize}G /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      free -h
    elif [[ "$changeswap" == "q" || "$changeswap" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 跳过虚拟内存设置 ...................."
    fi
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

adddockeradminer() {
  if docker ps -a --format '{{.Names}}' | grep -q '^adminer$'; then
    echo "++++++++++ Adminer 已安装 ...................."
  else
    echo "++++++++++ Adminer 未安装 ...................."
  
    read -p "是否安装 Adminer docker ？(y/n/q) " adminer
    if [[ "$adminer" == "y" || "$adminer" == "Y" ]]; then
      docker run -d --name adminer --restart=always -p 8011:8080 --net dockernet -e ADMINER_DEFAULT_SERVER=mysql adminer
    elif [[ "$docknet" == "q" || "$docknet" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 跳过 Adminer 安装 ...................."
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
  
    read -p "是否安装 Lighttpd 和 PHP 7.4 ？(y/n/q) " httpd
    # if isInstalled "caddy" "version"; then
    #  read -p "Caddy 已经安装，如果需要安装 Lighttpd，Lighttpd 的端口将被改成 1080，是否继续安装？(y/n) " httpd1080
    #  if [[ "$httpd1080" == "y" || "$httpd1080" == "Y" ]]; then
    #    echo "++++++++++ 继续安装 Lighttpd，端口改为 1080 ...................."
    #  else
    #    echo "++++++++++ 跳过 Lighttpd 和 PHP 安装 ...................."
    #    return 0
    #  fi
    # fi

    if [[ "$httpd" == "y" || "$httpd" == "Y" ]]; then
      if ! isInstalled "lighttpd"; then
        apt install lighttpd -y
      fi

      aptphp
      
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

      # if [[ "$httpd1080" == "y" || "$httpd1080" == "Y" ]]; then
      #  sed -i "s/= 80/= 1080/g" /etc/lighttpd/lighttpd.conf
      # fi
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
  echo "*******安装 Caddy 和 PHP******"
  echo "*                          *"
  echo "****************************"
  if ! isInstalled "caddy" "version"; then
    read -p "是否安装 Caddy ？(y/n/q) " caddy
    if [[ "$caddy" == "y" || "$caddy" == "Y" ]]; then
      # 安装依赖
      apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
      # 添加 Caddy GPG key
      curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
      # 添加 Caddy repository to sources list
      curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
      apt update
      apt install caddy -y
      systemctl enable caddy
      systemctl restart caddy
      aptphp
    
    elif [[ "$caddy" == "q" || "$caddy" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 跳过 Caddy 安装 ...................."
    fi
  fi
}

aptphp() {
  echo "****************************"
  echo "*                          *"
  echo "*******安装 PHP******"
  echo "*                          *"
  echo "****************************"
  if isInstalled "php"; then
    echo "******已安装的 PHP 版本******"
    update-alternatives --list php
    echo "****************************"
  fi
    read -p "是否安装 PHP ？(y/n/q) " php
    if [[ "$php" == "y" || "$php" == "Y" ]]; then
      PS3="请选择 PHP 的版本："
      select ver in "php 7.4" "php 8.2"
      do
        if [ "$ID" = "ubuntu" ]; then
          apt update && sudo apt upgrade -y
          apt install software-properties-common -y
          add-apt-repository ppa:ondrej/php
          apt update
        fi
        if [[ "$REPLY" == 1 ]]; then
          echo "++++++++++ 安装 php 7.4 ...................."
          apt update
          apt install php7.4 php7.4-cli php7.4-common php7.4-fpm php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php7.4-bcmath -y
          php -v
          break
        elif [[ "$REPLY" == 2 ]]; then
          echo "++++++++++ 安装 php 8.2 ...................."
          apt update
          apt install php8.2 php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath -y
          php -v
          break
        else
          echo "++++++++++ 跳过 PHP 安装 ...................."
        fi
      done
    
    elif [[ "$php" == "q" || "$php" == "Q" ]]; then
      exit
    else
      echo "++++++++++ 跳过 php 安装 ...................."
    fi
}

aptcaddyonly() {
  echo "****************************"
  echo "*                          *"
  echo "******** 安装 Caddy *******"
  echo "*                          *"
  echo "****************************"
  if ! isInstalled "caddy" "version"; then
    read -p "是否安装 Caddy ？(y/n/q) " caddy
    if [[ "$caddy" == "y" || "$caddy" == "Y" ]]; then
      # 安装依赖
      apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
      # 添加 Caddy GPG key
      curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
      # 添加 Caddy repository to sources list
      curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
      apt update
      apt install caddy -y
      systemctl enable caddy
      systemctl restart caddy
    
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

aptcaddyorlighttp() {
  if ! isInstalled "caddy" "version" && ! isInstalled "lighttpd" && ! isInstalled "php"; then
    echo "Web 服务器"
    echo "1) Lighttpd 和 PHP"
    echo "2) Caddy 和 PHP"
    echo "3) 仅安装 Caddy"
    echo "0) 跳过安装 Web 服务器"
    
    read -p "请选择要安装的 Web 服务器（直接回车跳过安装）：" choice
    
    case $choice in
        1)
            echo "++++++++++ 安装 Lighttpd 和 PHP ...................."
            aptlighttpd
            ;;
        2)
            echo "++++++++++ 安装 Caddy 和 PHP ...................."
            aptcaddy
            ;;
        3)
            echo "++++++++++ 安装 Caddy ...................."
            aptcaddyonly
            ;;
        0)  
            echo "++++++++++ 跳过 Web 服务器和 PHP 安装 ...................."
            ;;
        *)
            echo "++++++++++ 跳过 Web 服务器和 PHP 安装 ...................."
            ;;
    esac
  fi
}

updatesys_run() {
  updatesys
  go_menu
}
apttools_run() {
  apttools
  go_menu
}
addswap_run() {
  addswap
  go_menu
}
aptdocker_run() {
  aptdocker
  go_menu
}
settzone_run() {
  settzone
  go_menu
}
sethost_run() {
  sethost
  go_menu
}
addnonrootusr_run() {
  addnonrootusr
  go_menu
}
adddockernet_run() {
  adddockernet
  go_menu
}
aptmariadb_run() {
  aptmariadb
  go_menu
}
adddockeradminer_run() {
  adddockeradminer
  go_menu
}
aptlighttpd_run() {
  aptlighttpd
  go_menu
}
aptcaddy_run() {
  aptcaddy
  go_menu
}
aptphp_run() {
  aptphp
  go_menu
}
aptcaddyonly_run() {
  aptcaddyonly
  go_menu
}
aptcertbot_run() {
  aptcertbot
  go_menu
}
addphpinfo_run() {
  addphpinfo
  go_menu
}



order_run() {
clear
  echo "*********************************************************************************"
  echo "*                                                                               *"
  echo "*************************开始运行VPS初始设置一键脚本*****************************"
  echo "*            https://github.com/tigerzioo/vps_startpack                         *"
  echo "*            y：确认安装配置；n：跳过此项安装配置；q：退出脚本                      *"
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
    adddockeradminer
    set_sep
    aptcaddyorlighttp
    set_sep
    aptphp
    set_sep
    aptcertbot
    
    echo "*********************************************************************************"
    echo "*                                                                               *"
    echo "*********************脚本运行完成，如果需要还可以重新执行脚本********************"
    echo "*            https://github.com/tigerzioo/vps_startpack                         *"
    echo "*********************************************************************************"
    echo ""
}

# Main menu function
main_menu() {
    while true; do
        clear
clear
  echo "*********************************************************************************"
  echo "*                                                                               *"
  echo "*************************开始运行VPS初始设置一键脚本*****************************"
  echo "*            https://github.com/tigerzioo/vps_startpack                         *"
  echo "*            y：确认安装配置；n：跳过此项安装配置；q：退出脚本                   *"
  echo "*********************************************************************************"
        echo "===== 主菜单 ====="
        echo "1 - 升级更新系统软件包"
        echo "2 - 安装常用工具 sudo curl apt"
        echo "3 - 设置 swap 虚拟内存"
        echo "4 - 安装 docker 和 docker-compose"
        echo "5 - 更改时区"
        echo "6 - 更改主机名"
        echo "7 - 创建 非root 用户"
        echo "8 - 创建 Docker 网络"
        echo "9 - 安装 MariaDB 数据库"
        echo "10 - 安装 Adminer"
        echo "11 - 安装 Lighttpd 和 PHP"
        echo "12 - 安装 Caddy 和 PHP"
        echo "13 - 安装 PHP 7.4/8.2"
        echo "14 - 安装 Caddy"
        echo "15 - 安装 CertBot"
        echo "99 - 顺序运行全部"
        echo "0 - 退出"
        echo -n "请选择: "
        read selection
        case $selection in
            1) updatesys_run ;;
            2) apttools_run ;;
            3) addswap_run ;;
            4) aptdocker_run ;;
            5) settzone_run ;;
            6) sethost_run ;;
            7) addnonrootusr_run ;;
            8) adddockernet_run ;;
            9) aptmariadb_run ;;
            10) adddockeradminer_run ;;
            11) aptlighttpd_run ;;
            12) aptcaddy_run ;;
            13) aptphp_run ;;
            14) aptcaddyonly_run ;;
            15) aptcertbot_run ;;
            99) order_run ;;
            0) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid selection"; press_enter ;;
        esac
    done
}

# Start the script by calling the main menu
main_menu
