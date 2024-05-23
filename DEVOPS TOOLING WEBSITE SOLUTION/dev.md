# DEVOPS TOOLING WEBSITE SOLUTION

## TASK : to implement a 2 tier web application architecture with a single database (MYSQL) and NFS server as a shared file storage 


# STEP ONE : SETTING UP NFS SERVER

   * Create an t3. micro EC2 instance, make use of REdhat OS
   * create 3 or 4 ebs volumes and attach to your instance
   * Access your instance via ssh

             ssh -i <keypair.pem> ec2-user@<ipaddress>

   * Check the disks available

            lsblk
     
  OUTPUT: ![DEV](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/checked%20available%20disks.png)

   * use the gdisk utility tpo create partitions for each disk

           sudo gdisk /dev/nvme1n1

      1. type **n** to create new partion
      2.  click on enter till it prompts for a command again
      3.  type **w** to write
      4.  repeat same process for other disks

  * use **lsblk** to check the create3d partitions

 OUTPUT:    ![dev](https://github.com/citadelict/My-devops-Journey/tree/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images)


  * Install **Lvm2**

            sudo yum install lvm2
    
  * Use **pvcreate** to mark  each of the partitions as physical volume

            sudo pvcreate /dev/nvme1n1p1
            sudo pvcreate /dev/nvme2n1p1
            sudo pvcreate /dev/nvme3n1p1
            sudo pvcreate /dev/nvme4n1p1
  * verify that physical volumes have been created

            sudo pvs

    
OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/created%20physical%20volumes.png)


 *  Add all three pvs to a volume group, lets call it webdata

           sudo vgcreate webdata-vg /dev/nvme1n1p1 /dev/nvme2n1p1 /devnvme3n1p1 /dev/nvme4n1p1

 * verify the setup by running **sudo vgs**

  OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/created%20a%20volume%20group.png)


 * Create 3 logical volumes, one should be apps-lv, another should be apt-lv and the last should be logs-lv

           sudo lvcreate apps-lv -L 12G webdata-vg
           sudo lvcreate apt-lv -L 12G webdata=-vg
           sudo lvcreate logs-lv -L 12G webdata-vg
   
 * verify that the logical volumes have been created

           sudo lvs

   OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/created%20logical%20volumes.png)

 * format the logical volumes using xfs

           sudo mkfs -t xfs /dev/webdata-vg/apps-lv
           sudo mkfs -t xfs /dev/webdata-vg/apt-lv
           sudo mkfs -t xfs /dev/webdata-vg/logs-lv

   OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/formatted%20using%20xfs.png)

 * Create mount directories

           sudo mkdir /mnt/apps
           sudo mkdir /mnt/apt
           sudo mkdir /mnt/logs

   OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/created%20various%20mount%20directories.png)

* Now mount the volume group into their respective mount directories

          sudo mount /dev/webdata-vg/apps-lv /mnt/apps
           sudo mount /dev/webdata-vg/apt-lv /mnt/apt
           sudo mount /dev/webdata-vg/logs-lv /mnt/logs

OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/verified%20my%20mount%20points%20.png)
OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/mounted%20apt%2C%20apps%2C%20and%20logs%20in%20thier%20various%20mount%20points.png)

* Install NFS server and configure it to start on reboot

        sudo yum -y update
        sudo yum install nfs-utils -y
        sudo systemctl start nfs-server.service
        sudo systemctl enable nfs-server.service
        sudo systemctl status nfs-server.service

  OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/instaled%20and%20enabled%20nfs%20server.png)

* Setup permissions that will allow the webservers read, and write and execute files on the NFS

          sudo chown -R nobody: /mnt/apps
          sudo chown -R nobody: /mnt/logs
          sudo chown -R nobody: /mnt/opt
          
          sudo chmod -R 777 /mnt/apps
          sudo chmod -R 777 /mnt/logs
          sudo chmod -R 777 /mnt/opt
          
          sudo systemctl restart nfs-server.service

  OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/set%20permissions.png)

 * Configure access to the nfs servers within the same subnet, to do this : we have to export the mounts we created earlier to allow the webservers in the same subnet connect as clients

             sudo vi /etc/exports

            /mnt/apps 172.31.32.0/20;(rw,sync,no_all_squash,no_root_squash)
            /mnt/logs 172.31.32.0/20;(rw,sync,no_all_squash,no_root_squash)
            /mnt/opt 172.31.32.0/20;(rw,sync,no_all_squash,no_root_squash)

             Esc
             :wq!

          sudo exportfs -arv

   * Check the NFS ports and open it in the security group inbound rules , add the ports and allow access from the subnet cidr ipv4 address

             rpcinfo -P | grep nfs

     OUTPUT : ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/ports%20beeing%20used%20by%20nfs.png)

     


# STEP TWO : CONFIGURING MYSQL

  * Launch 1 Ec2 instance on ubuntu OS
  * ssh into it
  * update and upgrade the instance
  * install mysql server

            sudo apt install -y mysql-server
    
  * create db, user @ the subnet cidr, and grant all privileges to the user, It is essential to use the subnet cidr to ensure that all instances under that subnet can access the mysql database.

              sudo mysql
              CREATE DATABASE tooling;
              CREATE USER 'webaccess'@'192.168.1.0/20' IDENTIFIED BY 'password';
              GRANT ALL PRIVILEGES ON tooling.* TO 'webaccess'@'192.168.1.0/20';
              FLUSH PRIVILEGES;
              exit;

  * Edit the MySQL configuration file to bind it to all IP addresses, (0.0.0.0)  Open the MySQL configuration file, which is located at /etc/mysql/mysql.conf.d/mysqld.cnf:

 * Go to your ec2 security group in bound rules and add the port 3306 (default mysql port) and allow access from your subnet cidr


# STEP THREE : SETUP THE WEBSERVERS

  * Launch 2 ec2 instances (or dependending on the number of webservers you need), use Redhat OS
  * ssh into it
  * update and upgrade the instance
  * install NFS client (do thid for all webservers that would be client to the NFS server)

            sudo yum install nfs-utils nfs4-acl-tools -y

  * make /var/www/ directory

             sudo mkdir /var/www

  * Mount /var/www/ and target the NFS server export  for apps

         
          sudo mount -t nfs -o rw,nosuid 172.31.32.0/20:/mnt/apps /var/www

    OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/mounted%20on%20nfs%20server%20mount%20points.png)

  * make sure the changes persist after reboot

          sudo vi /etc/fstab
    
  * add the following

        172.31.32.0/20:/mnt/apps  /var/www nfs defaults 0 0

  * save and exit
    
      
  * install and configure REMI repository, apache, as well as php and all dependencies

              sudo yum install httpd -y

              sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
              
              sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm
              
              sudo dnf module reset php
              
              sudo dnf module enable php:remi-7.4
              
              sudo dnf install php php-opcache php-gd php-curl php-mysqlnd
              
              sudo systemctl start php-fpm
              
              sudo systemctl enable php-fpm
              
              setsebool -P httpd_execmem 1

    * Verify that both the webservers **/var/www** and NFS servers  **/mnt/apps** have the same files and directories, to do this,
   
              df -h

      OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/same%20files%20on%20nfs%20server%20and%20webservers.png)


   * make /var/log/httpd/ directory

          sudo  mkdir /var/log/httpd

   * Mount /var/log/httpd and target the NFS server export  for logs

         
          sudo mount -t nfs -o rw,nosuid 172.31.32.0/20:/mnt/logss /var/log/httpd

 
   * make sure the changes persist after reboot

          sudo vi /etc/fstab
    
   * add the following

          172.31.32.0/20:/mnt/logs  /var/log/httpd nfs defaults 0 0

   * save and exit
    
     OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/mounted%20nfs%20logs%20on%20both%20servers.png)





    

        



    



    
