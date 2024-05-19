# Web Solutions With Wordpress


## Prerequisites
- AWS Account
- Terminal / Git Bash

## Steps to Set Up EC2 Instances

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












