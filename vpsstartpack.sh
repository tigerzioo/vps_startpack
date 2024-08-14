echo "********系统更新升级......"
apt-get update && apt-get upgrade
echo "********安装sudo，curl......"
apt install sudo curl

echo "********安装docker和docker-compose......"
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
apt-get install docker-compose

current_hostname=$(hostname)
echo -e "当前主机名: $current_hostname"
echo "------------------------"
read -p "请输入新的主机名（直接回车不变动）: " new_hostname

hostnamectl set-hostname "$new_hostname"
sed -i "s/$current_hostname/$new_hostname/g" /etc/hostname
systemctl restart systemd-hostnamed
