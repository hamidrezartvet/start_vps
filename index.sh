#!/bin/bash
apt update && sudo apt upgrade -y

#here we install apache2
sudo apt install apache2

#then we change apache2 folder access
sudo chmod -R 755 /var/www
sudo mkdir -p /var/www/your_domain_1/public_html
sudo chown -R $USER:$USER /var/www/your_domain_1/public_html

#here we restart apache service
sudo systemctl reload apache2
sudo systemctl restart apache2

#here we get apache2 status
sudo systemctl status apache2