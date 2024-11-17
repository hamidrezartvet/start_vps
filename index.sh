#!/bin/bash
sudo apt update && sudo apt upgrade -y

#here we install apache2
sudo apt install apache2 -y

#then we change apache2 folder access
sudo chmod -R 755 /var/www
sudo mkdir -p /var/www/your_domain_1/public_html
sudo chown -R $USER:$USER /var/www/your_domain_1/public_html

#here we install php
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.2 -y
sudo apt-get install -y php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath
sudo apt-get install libapache2-mod-php8.2 -y
sudo a2enmod php8.2
sudo update-alternatives --set php /usr/bin/php8.2 -y
sudo service apache2 restart

#install getit and nano
sudo apt install nano -y

#download file and put in html folder
wget  -P /var/www/html "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/index.php"
wget  -P /var/www/html "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/check.php"
wget  -P /var/www/html "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/getOnlineUsers.sh"
wget  -P /var/www/html "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/firewall.txt"


#here we install iptables
sudo apt-get install iptables

#then we ban ip list
if [ -f "/var/www/html/firewall.txt" ]; then
    for IP in $(cat /var/www/html/firewall.txt); do iptables -A INPUT -s $IP/32 -d 0/0 -j DROP; done
    echo "File exists."
else
    wget  -P /var/www/html "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/firewall.txt"
    for IP in $(cat /var/www/html/firewall.txt); do iptables -A INPUT -s $IP/32 -d 0/0 -j DROP; done
    echo "File does not exist."
fi
echo 'ip list blocked!';

#here we set bbr for data performance
sudo echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf
sudo echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
sudo echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_rmem = 4096 87380 16777216' >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_wmem = 4096 16384 16777216' >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_low_latency = 1' >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_slow_start_after_idle = 0' >> /etc/sysctl.conf
sudo echo 'net.core.default_qdisc = fq' >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_congestion_control = bbr' >> /etc/sysctl.conf
sudo sysctl -p
sudo sysctl net.ipv4.tcp_congestion_control


#here we block iran ip
sudo apt-get install curl unzip perl xtables-addons-common libtext-csv-xs-perl libmoosex-types-netaddr-ip-perl iptables-persistent -y 

url="https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/i.txt"
allcount=$(curl -s "$url" | wc -l)
curl -s "$url"  | while IFS= read -r line; do
((++line_number))
iptables -A OUTPUT -p tcp  --dport 80 -d $line -j DROP
iptables -A OUTPUT -p tcp  --dport 443 -d $line -j DROP
clear
echo "Iran IP Blocking ( List 1 ) : $line_number / $allcount "
done
sudo iptables-save | sudo tee /etc/iptables/rules.v4
echo 'Iran ip blocked!'

# #at the end we reboot server
sudo reboot
