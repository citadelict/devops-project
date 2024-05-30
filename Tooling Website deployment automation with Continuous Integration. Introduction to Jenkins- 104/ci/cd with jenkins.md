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








