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
### OUTPUT

![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/installed%20Nginx.png)  , 
![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/nginx.png)  

  * installing mysql and configuring root password and privileges
    
        
          ```
          sudo apt install mysql-server


 ### OUTPUT
 ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/installed%20mysql.png)

 
    

* installing php via php fpm package manager 
  

    ```
    sudo apt install php-fpm php-mysql
     ```
    

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

### OUTPUT 
![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/test%20nginx%20config.png)

  6. Reload nginx to apply changes
 
             sudo systemctl reload nginx

* create a mysql db and db user, grante all privileges and alos create a table
and insert some data into the table

    1. Create db
       
            CREATE DATABASE citatech;

    2. Create User

            CREATE USER 'citatech2'@'localhost' IDENTIFIED BY '(choose a password)';

    3. Grant all privileges

           GRANT ALL PRIVILEGES ON citatech.* TO 'citatech2'@'localhost';

   4. Apply the chnages you made

            FLUSH PRIVILEGES;

### OUTPUT
![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/db%20user%20and%20pwd.png)

* Testing PHP with Nginx
      !. create an info.php file in your root directory

                sudo nano /var/www/citatechlemp/info.php
     2. create a simple php script to check for php info, then save 

                
                  <?php
                    phpinfo();
  ### OUTPUT
     ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/testing%20php%20with%20nginx.png)

* Retrieving Data from mysql Database with PHP
     1.  connect to mysql console using
 
                sudo -u root -p

     2 Show Database

                SHOW DATABASES;

  
     3.  Use database you created earlier

                USE (DB NAME);

     4. Create a test table

                CREATE TABLE todo_lists (
              id INT AUTO_INCREMENT PRIMARY KEY,
              content VARCHAR(50),
              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          );

     5. Insert some rows into it

              INSERT INTO citatech2  (content)  VALUES   ( sample data  )


     6.  Confirm data was inserted
 
                SELECT * FROM todo_lists;

    7. Now exit console

                 exit
       
   ### OUTPUT
   ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/mysql%20db2.png)  

* Create a php script to interact with the mysql database
    1. use nano or vim to create a sample php file, lets call it todo_lists.php

                   sudo nano /var/www/citatechlemp/todo_lists.php

    2. now , write a test script to connect to mysql, heres a sample script:

                   <?php
            $user = "citatech"; 
            $password = "dbpassword";  
            $database = "db name";  
            $table = "todo_lists";
            
            try {
               
                $db = new PDO("mysql:host=localhost;dbname=$database", $user, $password);
                $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);  // Set the PDO error mode to exception

                echo "<h2>TODO</h2><ol>";
                $query = "SELECT content FROM $table";  // SQL query to fetch data from todo_list
                foreach ($db->query($query) as $row) {
                    // Display each row as a list item, ensuring content is safely escaped to prevent XSS
                    echo "<li>" . htmlspecialchars($row['content']) . "</li>";
                }
                echo "</ol>";
            } catch (PDOException $e) {
                // Error handling: display error message and stop script execution
                echo "Error!: " . $e->getMessage() . "<br/>";
                die();
            }
            ?>

  ### OUTPUT

   ![LEMP ](https://github.com/citadelict/My-devops-Journey/blob/main/LEMP/todo_list.php.png)  
        
                    
  ### CONCLUSION:

    These are all the steps involved in creating a LEMP stack environment for deloying php websites, and alos a sample php website to connect to the database we created
              
    







