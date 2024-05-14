# Understanding the MEAN stack

## MEAN Stack is a JavaScript Stack that is used for easier and faster deployment of full-stack web applications. MEAN Stack comprises 4 technologies namely: MongoDB, Express.js, Angular.js, Node.js. It is designed to make the development process smoother and easier. It is a collection of software packages and other development tools that make web development faster and easier. Web developers use it to produce web applications that are dynamic and more sustainable. 

* MongoDB: Non-relational open-source document-oriented database.
* Express JS: Node.js framework that makes it easier to organize your application’s functionality with middleware and routing and simplify APIs.
* Angular JS: It is a JavaScript open-source front-end structural framework that is mainly used to develop single-page web applications(SPAs).
* Node JS: is an open-source and cross-platform runtime environment for building highly scalable server-side applications using JavaScript.

## How MEAN stack works




# Step One : Setting Up a MEAN Stack on AWS EC@ Instance

  * sign in to your aws account and create an ec2 instance

     ##output ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/ec2%20instance.png)
    
  *   Access your instance by logging in via ssh using terminal or git bash

            ssh - i (your key pair) ubuntu@(your ip-address)

      output : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/accessed%20instance.png)

  *  Update and upgrade your Ubuntu server

            sudo apt update && sudo apt upgrade

  *  Install Node js, Npm

              sudo apt install nodejs npm -y
               node -v
               npm -v

     OUTPUT : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/installed%20nodejs%20and%20npm.png)
     
  *

