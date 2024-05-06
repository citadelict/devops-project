# update Ec2 instance  and install apache

sudo apt update
sudo install apache2

sudo systemctl start apache2
sudo systemctl enable apache2

# Install MySQL


sudo apt install mysql-server
sudo systemctl start mysql
sudo mysql_secure_installation


# Install PHP


sudo apt install php libapache2-mod-php php-mysql
sudo systemctl restart apache2


# Create a PHP info file
#use vim or nano editor

sudo nano /var/www/chidiaustin/info.php

#write into your new php file

<?php phpinfo();


#visit the ip address/info.php
