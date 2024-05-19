# Web Solutions With Wordpress


## Prerequisites
- AWS Account
- Terminal / Git Bash

### Step One :  to Set Up EC2 Instances

#### Server Instance
1. Open the EC2 Dashboard on the AWS Management Console.
2. Click on **Launch Instance**.
3. Select an Amazon Machine Image (AMI) , (ie) Use Redhat for this project
4. Choose an instance type ( t3.micro).
5. Configure instance details:
    - Number of instances: 1
    - Subnet: Choose a subnet
6. Add Storage: Default 8GB root volume will be added automatically.

7. Configure Security Group:
    - Add rule for SSH: Port 22
    - Add rule for HTTP: Port 80 (if needed)
10. Launch the instance.
11.  Create a new one and launch the instance.


#### Database Instance

##### Repeat same steps to create an EC2 instance that will serve as the database, you can name it DB

### . Create and Attach EBS Volumes

#### Create EBS Volumes
1. Go to the **Elastic Block Store > Volumes** section in the AWS Management Console.
2. Click **Create Volume**.
3. Configure the volume:
    - Volume type: General Purpose SSD (gp2)
    - Size: 10 GB
    - Availability Zone: Same as the  EC2 instances we created earlier (eg. af-south 1a)
4. Click **Create Volume**.
5. Repeat the above steps to create 5 more volumes.

   Output : ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/ebs%20volumes%20created.png)

#### Attach EBS Volumes to Server Instance
1. Go to the **Elastic Block Store > Volumes** section.
2. Select the first volume, click **Actions** > **Attach Volume**.
3. Select the server instance from the list and specify a device name (e.g., `/dev/nvme1`).
4. Click **Attach**.
5. Repeat the above steps to attach the other two volumes to the server instance using device names `/dev/nvm2` and `/dev/nvme3`.

#### Attach EBS Volumes to Database Instance
1. Go to the **Elastic Block Store > Volumes** section.
2. Select the fourth volume, click **Actions** > **Attach Volume**.
3. Select the database instance from the list and specify a device name (e.g., `/dev/nvme1`).
4. Click **Attach**.
5. Repeat the above steps to attach the other two volumes to the database instance using device names `/dev/nvme2` and `/dev/nvme3`.

OUTPUT : ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/attaching%20ebs%20to%20instance.png)
OUTPUT2 : ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/attached%20all%20ebs.png)

### . Connect to the Instances and Prepare Volumes

#### Connect to the Server Instance

1. Open your terminal and connect to the server instance:
    ```sh
    ssh -i /path/to/keypai.pem ec2-user@your-server-public-ip
    ```


2. List attached volumes:
    ```sh
    lsblk
    ```

   OUTPUT: ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/inspect%20ebs%20blocks.png)

3. Use **df -h ** to see all mounted drives and free spaces

4. Create a single partition on each of the 3 disks
    ```sh
    sudo gdisk /dev/nvme1
    ```
    Type **n** to create a new partition
    Enter the partition number (default is 1).
    Enter the first sector (default is fine).
    Enter the last sector or size
    Type **w** to write the partition table and exit

5. Use the **lsblk** utility to see all newly created partitions for the 3 volumnes

    OUTPUT: ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/full%20partitioned%20all%20disks.png)

6. Install lvm2 package. Lvm2 is used for managing disk drives and other storage devices
      ```sh
    sudo yum install lvm2
    ```
7. Use the **pvcreate** utility tool to mark each of the volumes as physical volumes
     ```sh
    sudo pvcreate /dev/nvme1n1p1
    sudo pvcreate /dev/nvme2n1p1
    sudo pvcreate /dev/nvme3n1p1
    ``` 
 OUTPUT: ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/made%20the%20disks%20physical%20volume.png)

8. Verify that the physical volume has been created
     ```sh
    sudo pvs
    ```
  
9. Add all 3 PVs to a volume group, lets call it webdata-vg
     ```sh
    sudo vgcreate webdata-vg /dev/nvme1n1p1  /dev/nvme2n1p1  /dev/nvme3n1p1
    ```

10. Verify the setup by running ** sudo vgs **\

OUTPUT: ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/successfully%20added%20them%20to%20web%20data%20group.png)

11. Create 2 logical volumes, name one **app-lv** and the other **logs-lv**. For app-lv, use half of the disk size, then use the remaining part fpor the logs-lv

       ```sh
    sudo lvcreate -n app-lv -L 14G webdata-vg
    sudo lvcreate -n logs-lv -L 14G webdata-vg
    ```
12. Verify that the logical volumes has been created
       ```sh
    sudo lvs
    ```
13. Verify the entire setup to be sure all has been configured properly
     ```sh
    sudo vgdisplay -v #view complete setup - VG, PV, and LV sudo lsblk 
    ```
    
14. format the logical volumes using **ext4** filesystems
    ```sh
    sudo mkfs -t ext4 /dev/webdata-vg/apps-lv
     sudo mkfs -t ext4 /dev/webdata-vg/logs-lv
    ```
OUTPUT: ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/formatted%20the%20logical%20volumn.png)

15. Create a directory to store website file
    ```sh
    sudo mkdir -p /var/www/html
    ```  

16. Create another directory for the log files
    ```sh
    sudo mkdir -p /home/recovery/logs
    ``` 
OUTPUT: ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/Screenshot_2024_05_17-20.png)

17. Mount the newly created directory for website files on tyhe app logical volume we earlier created
    ```sh
    sudo mount /dev/webdata-vg/apps-lv/   /var/www/html/
    ```
    OUTPUT: ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/mounted%20html%20dir%20on%20apps-lv.png)
18. Back up all the files on the logs logical volume before mounting, this is done using rsync utility
    ```sh
    sudo rsync -av /var/log/. /home/recovery/logs/
    ``` 
19.  Mount the .var/logs on the log-lv
      ```sh
    sudo mount /dev/webdata-vg/logs-lv/   /var/log/
    ``` 

20. Restore the log files back into /var/log/ directory
    ```sh
    sudo rsync -av /home/recovery/logs/log/. /var/log 
    ```
21. Ensure that the mount configurations persist after server restart, this can be done by updating the **UUID** of the /etc/fstab
    ```sh
    sudo blkid
    ``
            
    
            sudo vi /etc/fstab
            ``
 * Replace the UUID for the log-lv with the one you copied , ave and exit. then test the configuration
    ```sh
    sudo mount -a
    ```
 * Reload the daemom
   ```sh
   sudo systemctl reload daemon
   ```

22. Verify the setup
    ```sh
    df -h
    ```
    OUTPUT: ![WP](https://github.com/citadelict/My-devops-Journey/blob/main/web%20solution%20with%20wordpress/verified%20setup.png)


### STEPS TWO: Installing MySQL Server on Amazon EC2 Instance

We can now proceed to installing and configuring MYSQL server that will serve as the database for our website on the server instance, to do this, we can follow same process as we did in the server instance to create ec2 instance, create and attach the 3 ebs volumes, ssh into your nstance and create partitions


1. Create logical volumes, ( use same process as we did in the server instance, the logical volume should be db-lv instead of apps-lv, alos create logs-lv
2. Mount the db-lv to /db/ directory

### STEPS THREE : Insalling wordpress on the server EC2 instance

!. update the instance

        sudo yum -y update

2. Install **wget** **apache** , and all its dependencies

       sudo yum -y install wget httpd php php-mysqlnd php-fpm php-json

3. Enable, and start apache

           sudo systemctl enable httpd
           sudo systemctl start httpd
   
5. Install php and all its dependencies

           sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
           sudo yum install yum-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm
           sudo yum module list php sudo yum module reset php
           sudo yum module enable php:remi-7.4
           sudo yum install php php-opcache php-gd php-curl php-mysqlnd
           sudo systemctl start php-fpm
           sudo systemctl enable php-fpm setsebool -P httpd_execmem 1

6. Restart Apache

            sudo systemctl restart httpd

7. Create an info.php page to test if your configuration is correct

               sudo vi /var/www/html/info.php
   
   write the following code to check php config

                <?php
               phpinfo();
                   ?>
                   
  8. Visit your IPaddress/info.php  














