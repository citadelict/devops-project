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
   \
 * verify that the logical volumes have been created

           sudo lvs

   OUTPUT: ![dev](https://github.com/citadelict/My-devops-Journey/blob/main/DEVOPS%20TOOLING%20WEBSITE%20SOLUTION/images/created%20logical%20volumes.png)

 * format the logical volumes using xfs

           sudo mkfs -t xfs /dev/webdata-vg/apps-lv
           sudo mkfs -t xfs /dev/webdata-vg/apt-lv
           sudo mkfs -t xfs /dev/webdata-vg/logs-lv


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

  * Edit the MySQL configuration file to bind it to all IP addresses,  Open the MySQL configuration file, usually located at /etc/mysql/mysql.conf.d/mysqld.cnf:

 * Go to your ec2 security group in bound rules and add the port 3306 (default mysql port) and allow access from your subnet cidr




    



    
