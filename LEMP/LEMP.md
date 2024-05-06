## WEB STACK IMPLEMENTATION (LEMP STACK) IN AWS 

### INTRODUCTION

__The LEMP stack is a popular open-source web development platform that consists of four main components: Linux, Nginx, MySQL, and PHP (or sometimes Perl or Python). This documentation outlines the setup, configuration, and usage of the LEMP stack.


## 0. install git bash

  ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/gitbash.png)
   
   

## 1.  Configuring and Installing Lemp Stack into aws EC2 instance : 
  * First update your Ubuntu server list of packages
    
         ```
        sudo apt update
        sudo apt upgrade -y
        ```
  *  Then install nginx webserver
      ```
        sudo apt install nginx
        
        ```
![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/installed%20Nginx.png)  , 
![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/nginx.png)  

  * installing mysql and configuring root password and privileges
    
        
          ```
          sudo apt install mysql-server

     ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/installed%20mysql.png)

 
    

* installing php via php fpm package manager AND TESTING NGINX WITH PHP
  

    ```
    sudo apt install php-fpm php-mysql
     ```
    ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/testing%20php%20with%20nginx.png)  

* Configure Nginx to use php,
  1. open your text editor using nano or vim

                        sudo nano /etc/nginx/sites-available/citatechlem
                          ```
  2. Edit the server config file, heres an example of how it should look

                 # /etc/nginx/sites-available/citatechlemp

              server {
              listen 80;
              server_name citatechlemp www.citatechlemp;
              root /var/www/citatechlemp;
          
              index index.html index.htm index.php;
          
              location / {
                  try_files $uri $uri/ =404;
              }
          
              location ~ \.php$ {
                  include snippets/fastcgi-php.conf;
                  fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
              }
          
              location ~ /\.ht {
                  deny all;
              }
          }
                         
  3. Activate the configuration by linking it to the sites enabled directory

             sudo ln -s /etc/nginx/sites-available/citatechlemp /etc/nginx/sites-enabled/

  4. Test configuration for syntax error

             sudo nginx -t

    ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/test%20nginx%20config.png)

  6. Reload nginx to apply changes
 
             sudo systemctl reload nginx

* create a mysql db and db user, grante all privileges and alos create a table
and insert some data into the table

    1. Create db
       
            CREATE DATABASE database2;

    2. Create User

            CREATE USER 'citatech2'@'localhost' IDENTIFIED BY '(choose a password)';

    3. Grant all privileges

           GRANT ALL PRIVILEGES ON database2.* TO 'citatech2'@'localhost';

   4. Apply the chnages you made

            FLUSH PRIVILEGES;

  ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/db%20user%20and%20pwd.png)




 ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/mysql%20db2.png)  

writing a simple todo_list.php to connect to my database and retrieve the content  ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/todo_list.php.png)  





