VPS初始设置一键脚本 （只支持 ubuntu 和 debian 系统）

功能：\
升级更新系统软件包\
安装常用工具\
添加Swap虚拟内存\
安装docker和docker-compose\
更改系统时区\
更改主机名\
创建非root用户\
创建docker网络\
安装MariaDB数据库\
安装Lighttpd和PHP\
安装CertBot\
创建PHP测试网页

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
