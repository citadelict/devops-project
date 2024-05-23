# DEVOPS TOOLING WEBSITE SOLUTION

## TASK : to implement a 2 tier web application architecture with a single database (MYSQL) and NFS server as a shared file storage 


# STEP ONE : SETTING UP NFS SERVER

   * Create an t3. micro EC2 instance, make use of REdhat OS
   * create 3 or 4 ebs volumes and attach to your instance
   * Access your instance via ssh

             ssh -i <keypair.pem> ec2-user@<ipaddress>

   * Check the disks available

            lsblk
     
     ![DEV](https://drive.google.com/file/d/1_eufeQqQI3343D2DKyr2nVHj7RD1ex3h/view?usp=sharing)

   * use the gdisk utility tpo create partitions for each disk

           sudo gdisk /dev/nvme1n1

      1. type **n** to create new partion
      2.  click on enter till it prompts for a command again
      3.  type **w** to write
      4.  repeat same process for other disks

  * use **lsblk** to check the create3d partitions

   

  * Install **Lvm2**

            sudo yum install lvm2
    
  * Use **pvcreate** to mark  each of the partitions as physical volume

            sudo pvcreate /dev/nvme1n1p1
            sudo pvcreate /dev/nvme2n1p1
            sudo pvcreate /dev/nvme3n1p1
            sudo pvcreate /dev/nvme4n1p1
    















    
