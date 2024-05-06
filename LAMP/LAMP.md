INTRODUCTION

The LAMP stack is a popular set of open-source software for building web servers and applications. LAMP stands for Linux, Apache, MySQL, and PHP. In this guide, I will walk through the process of deploying a LAMP stack on an AWS EC2 instance.


1 .Creating EC2 instances on aws
  And understanding how to connect to my instance remoely via SSH   
  ![LAMP 101](https://github.com/citadelict/My-devops-Journey/raw/main/LAMP/images/lamp%20101.png)


2. create apache server via sudo apt install apache2
   ![LAMP 101](https://github.com/citadelict/My-devops-Journey/blob/main/LAMP/install%20apache.png)

  ![LAMP 101](https://github.com/citadelict/My-devops-Journey/blob/main/LAMP/images/apache%20default%20page.png)

3. install mysql
   sudo apt install mysql-server
   sudo systemctl start mysql
   sudo mysql_secure_installation
  ![LAMP 101](https://github.com/citadelict/My-devops-Journey/blob/main/LAMP/images/install%20apache%26mysql.png)

4. install php
   sudo apt install php libapache2-mod-php php-mysql
   sudo systemctl restart apache2

   ![LAMP 101](https://github.com/citadelict/My-devops-Journey/blob/main/LAMP/images/installed%20php.png)

5.  create a virtual host

9. create a demo index.html page
    sudo nano /var/www/chidiaustin/index.html
   
    ![LAMP 101](https://github.com/citadelict/My-devops-Journey/blob/main/LAMP/images/deployed%20html%20index%20page.png)

   configure apache to render php first before html  

11. create a basic php.info page to display php version
    sudo nano /var/www/chidiaustin/info.php
    
    <?php phpinfo();
    
   ![LAMP 101](https://github.com/citadelict/My-devops-Journey/blob/main/LAMP/images/successfully%20deployed%20php%20web%20page.png)

