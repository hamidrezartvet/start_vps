#!/bin/bash
sudo apt update && sudo apt upgrade -y

#here we install apache2
sudo apt install apache2 -y

#then we change apache2 folder access
sudo chmod -R 755 /var/www
sudo mkdir -p /var/www/your_domain_1/public_html
sudo chown -R $USER:$USER /var/www/your_domain_1/public_html

#here we restart apache service
sudo systemctl reload apache2
sudo systemctl restart apache2

#here we install php
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install php8.2 -y
sudo apt-get install -y php8.2-cli php8.2-common php8.2-fpm php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath
sudo apt-get install libapache2-mod-php8.2 -y
sudo a2enmod php8.2
sudo update-alternatives --set php /usr/bin/php8.2
sudo service apache2 restart

#install getit and nano
sudo apt install nano -y

#download file and put in html folder
wget  -P /var/www/html "https://raw.githubusercontent.com/hamidrezartvet/start_vps/master/index.php"
