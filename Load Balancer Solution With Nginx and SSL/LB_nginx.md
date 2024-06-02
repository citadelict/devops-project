# Documentation: Setting Up Load Balancer with NGINX, Domain Name, and SSL with Certbot

The goal of this task is to properly implement a Load balancer for our webservers , and connect the load balancer to a domain name so our website can be accessed via a domain name, install and configure ssl/tls for security.


## Prerequisites
- A Linux server (e.g., Ubuntu) for NGINX
- ensure both ssh, http and https ports are opened and are set to allow access from anywhere
- Domain name registered 
- Access to the server via SSH
- Sudo privileges on the server

---

## 1. Install NGINX

First, update your package lists and install NGINX:

        ```sh
        sudo apt update
        sudo apt install nginx

## 2. Configure NGINX

 - Open the default nginx config file

         sudo vi /etc/nginx/nginx.conf

 - within the http section, add the following code snippet below,

          upstream myproject {
            server Web1 weight=5;
            server Web2 weight=5;
          }
        
        server {
            listen 80;
            server_name domain.com www.domain.com;
            location / {
              proxy_pass http://myproject;
            }
          }

      * Replace your already purchased domain name in the section for domain name, save and exit
      * Restart nginx and ensure it is running

            sudo systemctl restart nginx
            sudo systemctl status nginx
  
   OUTPUT: ![nginx](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/nginx%20lb%20config.png)

  ## 3. Configure Elastic IP address for the load balancer. : This is done because , everytime we stop the ec2 instance, the public ip address changes, therefore if attached to a dns record, that would mean that everytime we stop and restart the ec2 instance, and the ip address changes, we will need to go back and point the domain to the new ip address, this is really stressful. To avoid this, we have to use a service by aws called 'ELASTIC IP', Elastic ip is a specialized public Ip address that can be assigned to an instance and that never changes no matter how many times the instance is restarted, it remains the same. in order to do this ,follow the steps below

  - On your AWS console search bar, type and search for 'Elastic IP'
  - Click on allocate IP and always confirm it is in the same availability zone as your intance
  - After creating the elastic Ip, click on the check box for the IP and under actions, select associate elastic IP address
  - Associate it with your load balancer instance
    
        
 OUTPUT: ![elastic IP](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/created%20elastic%20Ip.png)
 OUTPUT: ![attached to LB](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/associated%20with%20nginx%20lb.png)


 ## 4. Setting up dns records for your domain to point to the server using the elastic ip address

   - Go to your domain registra (where your domain was purchased)
   - configure the dns records to point to the instance by updating the 'A records of the domain name'. in the box for points to, input the Elastic Ip address and click on save.

OUTPUT: ![a records](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/pointed%20domain%20name%20to%20elastic%20ip%20address.png)

  Visit a website like 'https://dnschecker.org/'  and confirm if indeed the domain name is already pointing to the ip address via the a records

OUTPUT: ![dnschecker](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/dns%20checker.png)

   - Confirm if your domain loads the website

OUTPUT: ![website](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/berryplug%20connected%20to%20LB.png)

 ## 5. Install 'Certbot' and request for a SSL/TLS certificate

   - Ensure 'snapd' service is active and running

         sudo systemctl status snapd

 OUTPUT : ![snapd](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/snapd%20status.png)

   - Install certbot using snapd package manager

          sudo snap install --classic certbot

 OUTPUT: ![certbot installed](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/certbot%20installed.png)

 
   - Create a symlink for certbot

              sudo ln -s /snap/bin/certbot /usr/bin/certbot
     
   - Follow the prompt to configure and request for ssl certificate

             sudo certbot --nginx

OUTPUT: ![sslinstalled](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/installed%20ssl.png)

 Visit your website to confirm SSL has been successfully installed

 OUTPUT: ![website ssl](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/ssl%20installed.png)

 OUTPUT: ![logged in](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/logged.png)


## Note: Letsencrypt ssl certificate is usually valid for 90 days, in order to make this continually renew itself, this can be achieved using a service known as **Cron Job**;
A cron job is a scheduled task on Unix-like operating systems, such as Linux. The cron service runs these scheduled tasks at specified times and intervals. Cron jobs are useful for automating repetitive tasks, such as system maintenance, backups, and running scripts.

  
 - First test the renewal command

                sudo certbot renew --dry-run

OUTPUT: ![renewa](https://github.com/citadelict/My-devops-Journey/blob/main/Load%20Balancer%20Solution%20With%20Nginx%20and%20SSL/images/testing%20renewal.png)
        
 - setting up a cron job to automate checking the server for ssl and renewal constantly

    * edit the cron tab

              crontab -e

    * add the following line

              * */12 * * *   root /usr/bin/certbot renew > /dev/null 2>&1

    * save changes and exit


 # . We have now successfuly configured a Nginx based Load Balancer for our webservers, ensured it can be accessed by a domain name and has SSL installed for security.



