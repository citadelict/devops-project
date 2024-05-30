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
        -  under source code management, Choose Git repository and input your github repository link, also enter your github username and password.
        -  set branch to build as main. (ie) */main and save the configuration.
        -  Click on **build now** button to build
     
  OUTPUT ![build](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/build%20successful.png)

  OUTPUT2: ![build2](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/build%20successful(1).png)


 ### The whole idea behind using jenkins is to make Continious integration very seamless , to achieve this, we have to configure jenkins to build everytime we push a new code to our repository or update an existing code. 

   3. Click on configure and scroll down to build trigger, and select **GitHub hook trigger for GITScm polling**
   4. Scroll down to post build actions and click on **Add post build actions**
        - From the drop down that appears when you click add post build actions, select Archive artifacts. (NB) files resulting from a build action is what is reffred to as Artifacts
        - Under the form field for Files to archive, use ** to select all .
   5. Save the configuration

 ### To test this, we made slight changes to the README.md file of our github repo.  a build was launched automatically and the artifacts saved

 OUTPUT: ![artifacts](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/aritifacts%20saved%20on%20jenkins.png)

 ### The artifacts are also stored on jenkins server, to view, use the command below:

           sudo ls /var/lib/jenkins/jobs/tooling_github/<build number>/archive/

 OUTPUT: ![server](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/build%20archive%20history%20on%20terminal.png)



## Step 3: Configuring Jenkins to copy files to NFS server via ssh

   1. Install **publish over ssh ** plugin
       - On the left sidebar, click on `Manage Jenkins`.
       - In the Manage Jenkins page, click on `Manage Plugins`.
       - In the Plugin Manager, go to the `Available` tab.
       - Use the search box to find `Publish Over SSH Plugin
       - Check the box next to `Publish Over SSH Plugin`.
       - Click on install and wait for it to download and install
     
  OUTPUT: ![publish](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/installed%20publish%20over%20ssh.png)
   
   2. Configure the publish over ssh plugin
      - Go to the Jenkins dashboard.
      - Click on `Manage Jenkins` and select 'configure system'
      -  Scroll down to the `Publish over SSH` section.
      -  Under key, paste the content of your key pair (same keypairr to access nfs server)
      -  add a hostname : (nfs-server-private-ip)
      -  Add a username
      -  set the remote directory to /mnt/apps , this is because it is the same directory our webservers use to retrieve files from the nfs server
      -  Test the configuration to make sure it returns success
     
     
  OUTPUT: ![sucess](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/testing%20config.png)

   ### save configurations
   
  3.  Create another Post build actions
     - In the drop down, select as **send buiold artifacts over ssh**
     - Under remote directory, set the source file as ( ** )
     - Click on save
      
      
  ### make changes again to README.md , the build should trigger immediately and deploy to the nfs server.

  OUTPUT : ![auto](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/auto%20build%20successful.png)

  OUTPUT: ![deployed](https://github.com/citadelict/My-devops-Journey/blob/main/Tooling%20Website%20deployment%20automation%20with%20Continuous%20Integration.%20Introduction%20to%20Jenkins-%20104/images/deployed%20successfully.png)

  # BLOCKER - getting permission denied when jeenkins tried to connect via ssh to the nfs server

  
  # solution : ENSURE YOUR JENKINS SERVER IS IN THE SAME AVAILABILITY ZONE AS YOUR WEBSERVERS AND ENSURE THEY USE THE SAME SUBNET CIDR, if they do not use the same subnet cidr, you will need to  Configure access to the nfs servers  to do this : we have to export the mounts we created on nfs to allow jenkins connect as clients

  - ssh into your nfs server
  - open the exports file

           sudo vi /etc/exports

   - Add the line for the jenkins server

           /mnt/apps 172.31.16.0/20;(rw,sync,no_all_squash,no_root_squash)

   - save and exit
   - export the file

            sudo exportfs -arv
     
   - Restart the nfs daemon
   - open the nfs ports of tcp 2049, udp 2049, tcp 111, udp 111, and allow the subnet cidr of the jenkins server.

# Now we able to automate the build process and send to the NFS server


  
