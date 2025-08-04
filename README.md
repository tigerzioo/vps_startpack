VPS初始设置一键脚本 （只支持 ubuntu 和 debian 系统）

功能：\
升级更新系统软件包\
安装常用工具\
添加 Swap 虚拟内存\
安装 docker 和 docker-compose\
更改系统时区\
更改主机名\
创建 非root 用户\
创建 docker 网络\
安装 MariaDB 数据库\
安装 MySQL 数据库\
安装 Adminer 数据库管理工具\
安装 Lighttpd 和 PHP\
安装 Caddy 和 PHP\
安装 PHP7.4 / php8.2 \
安装 Adminer\
安装 CertBot\

如果没有安装cURL，请先用下面命令安装。
```
apt install curl -y
```
\
运行一键脚本
```
curl -sS -O https://raw.githubusercontent.com/tigerzioo/vps_startpack/main/vpsstartpack.sh && bash vpsstartpack.sh
```
或者
```
bash <(curl -s https://raw.githubusercontent.com/tigerzioo/vps_startpack/main/vpsstartpack.sh)
```
