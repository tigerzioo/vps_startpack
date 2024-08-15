VPS初始设置一键脚本

如果没有安装cURL，请先用下面命令安装。
```
apt install curl
```

运行一键脚本
```
curl -sS -O https://raw.githubusercontent.com/tigerzioo/vps_startpack/main/vpsstartpack.sh && chmod +x vpsstartpack.sh && ./vpsstartpack.sh
```
或者
```
bash <(curl -s https://raw.githubusercontent.com/tigerzioo/vps_startpack/main/vpsstartpack.sh)
```
