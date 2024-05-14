# Understanding the MEAN stack

## MEAN Stack is a JavaScript Stack that is used for easier and faster deployment of full-stack web applications. MEAN Stack comprises 4 technologies namely: MongoDB, Express.js, Angular.js, Node.js. It is designed to make the development process smoother and easier. It is a collection of software packages and other development tools that make web development faster and easier. Web developers use it to produce web applications that are dynamic and more sustainable. 

* MongoDB: Non-relational open-source document-oriented database.
* Express JS: Node.js framework that makes it easier to organize your application’s functionality with middleware and routing and simplify APIs.
* Angular JS: It is a JavaScript open-source front-end structural framework that is mainly used to develop single-page web applications(SPAs).
* Node JS: is an open-source and cross-platform runtime environment for building highly scalable server-side applications using JavaScript.

## How MEAN stack works

 WE ARE GOING TO EXPLORE THE MEAN STACK BY CREATING A SIMPLE BOOK REGISTER WEB APP

# Step One

##   Setting Up a MEAN Stack on AWS EC2 Instance

  * sign in to your aws account and create an ec2 instance

     ##output ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/ec2%20instance.png)
    
  *   Access your instance by logging in via ssh using terminal or git bash

            ssh - i (your key pair) ubuntu@(your ip-address)

      output : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/accessed%20instance.png)

  *  Update and upgrade your Ubuntu server

            sudo apt update && sudo apt upgrade

# Step Two : Installing Node js

  * Install Node js, Npm

              sudo apt install nodejs npm -y
               node -v
               npm -v

     OUTPUT : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/installed%20nodejs%20and%20npm.png)

# Step Three  : Insalling Mongo DB

  * Import Mongodb Repository key

           sudo apt install gnupg curl
           curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
              sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
              --dearmor

  * Add Mongodb into your Ubuntu System

           echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee 
           /etc/apt/sources.list.d/mongodb-org-7.0.list

   * Update Ubuntu again with the new Repo we added

           sudo apt update

   * Once the repository has been added and confirmed to be working, we can then proceed to installing mongodb, use the command below to install mongodb

            sudo apt -y install mongodb-org

   * Confirm mongodb installation, to do this , run the code below :

             mongo --version

        Output : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/installed%20mongodb.png)


 # Step Four  : Setting up the project

   * Install both body-parser, mongoose ,and express js

           npm isntall body-parser
           npm install express
           npm install mongoose

        OUTPUT: ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/installed%20express%20and%20mongoose.png)

   * Create a directory, name it Books ( this would be our project directory ), and initialize a new package in order to generate a package.json file, run the code below:

           mkdir Books
           npm init -y

     


    

