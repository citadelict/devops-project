# Tooling Website deployment automation with Continuous Integration. Introduction to Jenkins- 104

This guide documents the detailed steps I followed to set up Jenkins on an AWS EC2 instance using Ubuntu 24.04, connected it to my github repo and was able to set up automatic build process everytime i push to my repository, as well as upload to my network file server.

## Prerequisites

Visit my previous documentations from project 8 to fully setup your NFS server, Mysql server and 2 web servers.

## Step 1: Setting Up jenkins

  1. **Launch a new EC2 instance on Ubuntu 24.04 OS/Image**.
  2. **ssh into your instance using terminal**.

         ssh -i "your-key-pair.pem" ubuntu@your-ec2-public-ip

  3. **Update your ec2 instance**

         sudo apt update

  4. Install JDK 11 , Jenkins requires Java to run. :

         sudo apt install openjdk-11-jdk


OUTPUT: ![JDK](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/installed%20jdk.png)

   5. Install Jenkins

          wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add - 
          sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
          sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5BA31D57EF5975CA
          sudo apt update
          sudo apt install jenkins -y


 OUTPUT: ![jenkins](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/installed%20jenkins.png)


   6. Ensure Jenkins is properly installed and running

          sudo systemctl status jenkins

 OUTPUT: ![status](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/installed%20jenkins.png)


   7. The defaul port for jenkins is **8080** , go to your jenkins ec2 instance security group, and open an inbound rule , set port 8080 to be accessible from any where

   8. Visit your <jenkins-ip-address>:8080

OUTPUT: ![broswer](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/unlock%20jrnkins.png)

   9.  You will be required to input a password, you can retrieve the password from termianl, using

            sudo cat /var/lib/jenkins/secrets/initialAdminPassword

       - Copy the password that displays as out put and paste it into your jenkins page opened in the browser, you should get the same output below :
     
 OUTPUT: ![password](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/signed%20in%20to%20jenkins%20admin.png)

   10. Install suggested plugins and wait for the installation to be complete, then create an admin user and password, when this is done, you will get the jenkins server address

 OUTPUT: ![installed](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/completely%20installed%20jenkins.png)


## Step 2: Configuring Jenkins to retrieve source code from github using webhooks

  1. Enable webhooks in your github repo settings
      - Navigate tto your github repository page
      - Click on settings, scroll down and click on webhooks
      - Click on add webhook
      - in the form field for payload URL, add your jenkins server ip:8080/github-webhooks/ , example :

               http://<jenkins-server-address:8080/github-webhook/
        
      -  Set content type to application/json

OUTPUT: ![webhooks](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/added%20webhook.png)


   2. Log into your jenkins server
        - Select new item from the side nav bar
        - Input your desired name <eg> tooling , and select freestye project from the list below it
        -  Choose Git repository and input your github repository link, also enter your github username and password.










