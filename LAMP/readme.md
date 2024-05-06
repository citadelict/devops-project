Deploying a LAMP Stack on AWS EC2

Table of Contents

* Introduction
* Launch and Connect to EC2
* Install Apache
* Install MySQL
* Install PHP
* Testing the LAMP Stack
* Configure Security Groups
* Conclusion


1. Introduction

The LAMP stack is a widely used open-source web development platform consisting of Linux, Apache, MySQL, and PHP. This documentation outlines the steps to deploy a LAMP stack on an AWS EC2 instance, including the necessary code snippets for each step.

Launch and Connect to EC2

Launch an EC2 instance with the Amazon Linux 2 AMI and the t2.micro instance type.
Set up a security group allowing SSH and HTTP traffic.
Connect to the instance using the SSH key pair :

    !ssh -i /path/to/key.pem ec2-user@<ipaddress>

2. Install Apache

        sudo apt update
        sudo apt install apache2

3. Install Mysql

       sudo install mysql-server
       sudo start mysql
       sudo mysql_secure_installation

4. Install PHP

       sudo apt install php libapache2-mod-php php-mysql
       sudo systemctl restart apache2

5. create a demo index.html page

       sudo nano /var/www/chidiaustin/index.html

6. create a basic php.info page to display php version

       sudo nano /var/www/chidiaustin/info.php

        <?php
           phpinfo();

CONCLUSION

these are the basic steps involved in setting up a Lamp Stack for web developement in aws ec2 instance
        
   

     
