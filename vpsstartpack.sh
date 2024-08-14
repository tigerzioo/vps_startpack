echo "********系统更新升级......"
apt-get update && apt-get upgrade
echo "********安装sudo，curl......"
apt install sudo curl

echo "********安装docker和docker-compose......"
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
apt-get install docker-compose

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
