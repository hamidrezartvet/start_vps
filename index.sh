#!/bin/bash
sudo apt update && sudo apt upgrade -y

#here we install apache2
sudo apt install apache2 -y

#then we change apache2 folder access
sudo chmod -R 755 /var/www
sudo mkdir -p /var/www/html
sudo chown -R $USER:$USER /var/www/html

#here we install php
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.2 -y
sudo apt-get install -y php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath
sudo apt-get install libapache2-mod-php8.2 -y
sudo a2enmod php8.2
sudo update-alternatives --set php /usr/bin/php8.2 -y
sudo service apache2 restart
echo '<<<<apache and php installed installed!>>>>'

#download file and put in html folder
wget  -O /var/www/html "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/index.php"
wget  -O /var/www/html "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/check.php"

#here we have importing setting
sudo  mkdir /etc/hrtvpn
wget  -O    /etc/hrtvpn "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/hrtvpn.txt"

#PAM setting files
sudo  rm -r /etc/pam.d/sshd
sudo  rm -r /etc/sshd/sshd_config
wget  -P /etc/pam.d/                            "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/sshd"
wget  -P /etc/ssh/                              "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/sshd_config"
wget  -P /usr/lib/x86_64-linux-gnu/security/    "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/pam_hrtvpn_backend.so"
sudo  chmod 644 /usr/lib/x86_64-linux-gnu/security/pam_hrtvpn_backend.so
sudo  chown root:root /usr/lib/x86_64-linux-gnu/security/pam_hrtvpn_backend.so
sudo  mkdir /var/www/banner
wget -P /var/www/banner "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/magicpc.txt"
wget -P /var/www/       "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/banner.txt"
wget -P /var/www/       "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/banner.conf"

echo '<<<<necessary files downloaded!>>>>'

#here we set bbr for data performance
sudo echo 'net.ipv4.tcp_window_scaling = 1'         >> /etc/sysctl.conf
sudo echo 'net.core.rmem_max = 16777216'            >> /etc/sysctl.conf
sudo echo 'net.core.wmem_max = 16777216'            >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_rmem = 4096 87380 16777216' >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_wmem = 4096 16384 16777216' >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_low_latency = 1'            >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_slow_start_after_idle = 0'  >> /etc/sysctl.conf
sudo echo 'net.core.default_qdisc = fq'             >> /etc/sysctl.conf
sudo echo 'net.ipv4.tcp_congestion_control = bbr'   >> /etc/sysctl.conf
sudo sysctl -p
sudo sysctl net.ipv4.tcp_congestion_control
echo '<<<<ssh setting updated!>>>>'

#here we install fai2ban for protection
sudo apt install fail2ban -y
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
echo '<<<<fail2ban installed!>>>>'

#here we install udpport
udpport=8400
sudo apt update -y
sudo apt install git cmake -y
git clone https://github.com/ambrop72/badvpn.git /root/badvpn
mkdir /root/badvpn/badvpn-build
cd  /root/badvpn/badvpn-build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 &
wait
make &
wait
cp udpgw/badvpn-udpgw /usr/local/bin
cat >  /etc/systemd/system/videocall.service << ENDOFFILE
[Unit]
Description=UDP forwarding for badvpn-tun2socks
After=nss-lookup.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --loglevel none --listen-addr 127.0.0.1:$udpport --max-clients 999
User=videocall

[Install]
WantedBy=multi-user.target
ENDOFFILE
useradd -m videocall
systemctl enable videocall
systemctl start videocall
echo '<<<<voice call installed!>>>>'

#here we install package for syncing users
echo '<<<<jq installation start>>>>'
sudo apt-get install jq -y
echo '<<<<jq installation finished>>>>'

sudo systemctl restart ssh

# #at the end we reboot server
# sudo reboot