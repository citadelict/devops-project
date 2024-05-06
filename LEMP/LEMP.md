## WEB STACK IMPLEMENTATION (LEMP STACK) IN AWS 

### INTRODUCTION

__The LEMP stack is a popular open-source web development platform that consists of four main components: Linux, Nginx, MySQL, and PHP (or sometimes Perl or Python). This documentation outlines the setup, configuration, and usage of the LEMP stack.


## 0. install git bash
   
    ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/gitbash.png)

  
## 1. Configuring and Installing Lemp Stack into aws EC2 instance

     * launch aws Ec2 instance and ssh into it
          `ssh -i (keypair.pem) ubuntu@(ipaddress)` 

          `sudo apt update`

          `sudo APT install nginx`

     




Installing Nginx Web server  ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/installed%20Nginx.png)  , ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/nginx.png)  

installing mysql and configuring root password and privileges   ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/installed%20mysql.png)  

installing php via php fpm package manager AND TESTING NGINX WITH PHP  ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/testing%20php%20with%20nginx.png)  
 

created a mysql db and user, granted all privileges and alos created a table
and inserting into the table   ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/mysql%20db2.png)  

writing a simple todo_list.php to connect to my database and retrieve the content  ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/todo_list.php.png)  





