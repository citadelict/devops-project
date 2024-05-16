# CLIENT-SERVER ARCHITECTURE USING MYSQL


## A Client Server Architecture is a network-based computing structure where responsibilities and operations get distributed between clients and servers. Client-Server Architecture is widely used for network applications such as email, web, online banking, e-commerce, 
## The client is the application that requests services from the server, such as retrieving or storing data, performing calculations, or executing commands.  
## The server is the application that provides services to the client, such as processing requests, sending responses, or completing actions. The server and the client can be located on the same machine or different devices across the network. The server and the client communicate using a predefined protocol, such as HTTP, FTP, SMTP, etc

## Today, we will be implementing a server-client architecture using MYSQL database managemet system  on aws EC2 instance

# Steps involved :


  * create 2 aws ec2 instances, one should be called server, and the other called client

  *  connect to your instance via ssh

           ssh -i <key-pair-name> ubuntu@<ip-address>
     
  *  update packages in both instances

            sudo apt update

  * On the server instance, install mysqli-server

        sudo apt install mysql-server


  *  Edit the mysql configuration file to allow remote connections

         sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
     
  * Find the line that begins with bind-address and change it to 0.0.0.0

            bind-address = 0.0.0.0

  ![cl](https://github.com/citadelict/My-devops-Journey/blob/main/cllient-server%20architecture%20with%20mysql/images/bind%20address.png)

  * save and close file.

  * Create a user that can connect remotely and grant al privileges

          sudo mysql -u root -p
    
      !. Enter root password
      2. create a new user

            CREATE USER 'citatech'@'%' IDENTIFIED BY 'password';

      3. Grant all privileges

              GRANT ALL PRIVILEGES ON *.* TO 'citatech'@'%' WITH GRANT OPTION;

      4. Flush privileges

               FLUSH PRIVILEGES;

      %. Exit


  ![cl](https://github.com/citadelict/My-devops-Journey/blob/main/cllient-server%20architecture%20with%20mysql/images/created%20a%20user%20and%20granted%20full%20privileges.png)

    

  * On the client instance, install mysql - client

        sudo apt install mysql-client

  * You can verify mysql installation

          mysql --version

     ![cl](https://github.com/citadelict/My-devops-Journey/blob/main/cllient-server%20architecture%20with%20mysql/images/installed%20cmysql%20client%20and%20mysql%20server.png)

    ### Note: it is important to know that mysql server uses port 3306, so it is essential to allow our mysql client be able to connect to the mysql server, in oder to do this, we should edit the inbound rules of the security group of server instance, to do this, follow the steps below :

    * Click on your server instance and locate the security groups under security tab
    *  click on ibound rules and edit
    *  add new inbound rules by adding a custom tcp , set to port 3306 and allow the ip address from client instanvce (use private IP) example: ip-address/32
    *  save it
   

  ![cl](https://github.com/citadelict/My-devops-Journey/blob/main/cllient-server%20architecture%20with%20mysql/images/opened%20port%20and%20allowed%20mysql%20client.png)
   
## Connecting to Mysql server from the mysql client


  * On the terminal tab for mysql client, connect remotely to mysql server using mysql utitlty, run the connection code below

        mysql -u username -p -h mysql server ipaddress
    
  * Enter password

![cl](https://github.com/citadelict/My-devops-Journey/blob/main/cllient-server%20architecture%20with%20mysql/images/connected%20remotely%20to%20mysq%20server.png)

  *  you can use the show database command to verify you are properly connected and logged in

          SHOW DATABASES;

![cl](https://github.com/citadelict/My-devops-Journey/blob/main/cllient-server%20architecture%20with%20mysql/images/show%20databses.png)

## manipulating the database

  *    Create database

              CREATE DATABASE demodatabase;

  *    Select the database to use it

              USE demodatabase;
          
  *    Create tables

                CREATE TABLE users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) NOT NULL
        );

  *    insert data in to the tables

           INSERT INTO users (name, email) VALUES ('chidi augustine', 'chidi@gmail.com');


  *    verify inserted data

            SELECT * FROM users;

        
  *    drop the table

            DROP TABLE users;

  *    drop the database

            DROP DATABASE demodatabase;

  * Exit

![cl](https://github.com/citadelict/My-devops-Journey/blob/main/cllient-server%20architecture%20with%20mysql/images/playing%20around%20with%20mysq%20db.png)



# Conclusion 

 ## In this project, we successfully set up a client-server architecture using MySQL Database Management System on AWS EC2 instances


    


    
