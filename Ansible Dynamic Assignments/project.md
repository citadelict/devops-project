# Ansible Dynamic Assignments (Include) and Community Roles

## Tasks goal :  The goal of this task is to build on our existing ansible projects, and include dynamic roles to better understand the diffrence between a dynamic playbook and a static playbook.


### Step 1 : Updating Github Repo

  - In your ansible-config-mgt directory github repo , create another branch , name it `dynamic-assignments`
  - Inside the dynamic-assignments folder, create a new **YAML** file, name it `env-vars.yml`

    #### Your folder structure should like the output below

    Output: ![folder structure](./images/dynamic.png)

    #### Since the goal of this project is to create and maintain a dynamic ansible project, we will be making use of variables to store the env details we will be needing, therefore ;

  - Create another directory and call it `env-vars`
  - inside it, create a new **YAML** file for each environment, that is `dev.yml prod.yml staging.yml uat.yml`,
  - inside the env-vars.yml fine, configure the required variables, use the code below

          ---
        vars_files:
          - "{{ playbook_dir }}/../../env-vars/dev.yml"
          - "{{ playbook_dir }}/../../env-vars/stage.yml"
          - "{{ playbook_dir }}/../../env-vars/prod.yml"
          - "{{ playbook_dir }}/../../env-vars/uat.yml"

    #### The code block above is an env yaml file that references other env variables files and thier location, so when the playbook searches for env variables, it goes directly through the folders specified


   - Now, inside your site.yml file , Update it to make use of the dynamic assignments, here is how it should look

                             ---
                            - name: Include dynamic variables
                              hosts: all
                              become: yes
                              tasks:
                                - include_vars: ../dynamic-assignments/env-vars.yml
                                  tags:
                                    - always
                            
                            - import_playbook: ../static-assignments/uat-webservers.yml
          

   ####  Based on the above playbook, we are simply referencing the dynamic-assignments/env-vars.yml file as well as importing other playbooks, this way, it is easier to manage and run multiple playbooks inside one general playbook

### Step 2: Creating Mysql Database using roles : 

   * note there are lots of community roles already built which we can use in our existing projects, one of these is mysql role by `geerlingguy ` , they can be found in this link : [roles-link](https://galaxy.ansible.com/home)

   - Inside your roles folder, create the mysql role by making use of `ansible-galaxy` command

                   ansible-galaxy install geerlingguy.mysql

   -  Now Rename the downloaded folder to mysql

                   mv geerlingguy.mysql/ mysql

   - Inside the `mysql/vars/main.yml` , configure your db credentials. P.S: these credentials will be used to connect to our website later on.

                  mysql_root_password:
                  mysql_databases:
                    - name: ( input your required db name )
                      encoding: latin1
                      collation: latin1_general_ci
                  mysql_users:
                    - name:  ( include your required db user name )
                      host: "( include the required subnet cidr ip address of your webservers )"
                      password: ( include your required password for the db )
                      priv: "(include the added db name).*:ALL"

   -  Save. Create a new playbook inside static-assignments folder and call it `db-servers.yml` , update it with the created roles. use the code below

                       ---
                    - hosts: db-servers
                      become: yes
                      vars_files:
                        - vars/main.yml
                      roles:
                        - role: mysql

 Output: ![db-servers](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Dynamic%20Assignments/images/db%20code.png)
 
   - Save , now return to your general playbook which is the `playbooks/site.yml` and reference the newly created db-servers playbook, add the code below to import it into the main playbook

                      - import_playbook: ../static-assignments/db-servers.yml

   - Save and exit, Create a pull request and merge with the main branch of your git hub repository.

### Step 3: Creating roles for load balancer, for this project , we will be making use of NGINX and APACHE as load balancers, so we need to create roles for them using same method as we did for mysql


   - Download and install roles for apache , we can get this role from same source as mysql

                         ansible-galaxy role install geerlingguy.apache

   - Rename the folder to apache

                         mv geerlingguy.apache/ apache

   - Download and install roles for nginx also.

                         ansible-galaxy role install geerlingguy.nginx

   - Rename the folder to nginx

                         mv geerlingguy.nginx/ nginx
     
   #### Since we cannot use both apache and nginx load balancer at the same time, it is advisable to create a condition that enables eithr one of the two, to do this ,

   - Declare a variable in `roles/apache/defaults/main.yml` file inside the apache role , name the variable  `enable_apache_lb`
   - Declare a variable in `roles/nginx/defaults/main.yml` file inside the Nginx role , name the variable  `enable_nginx_lb`

   - declare another variable that ensures either one of the load balancer is required and set it to `false`.

                         load_balancer_is_required : false

   - Create a new playbook in `static-assignments` and call it `loadbalancers.yml`, update it with code below:

                         ---
                        - hosts: lb
                          roles:
                            - { role: nginx, when: enable_nginx_lb and load_balancer_is_required }
                            - { role: apache, when: enable_apache_lb and load_balancer_is_required }
                        
     Output: ![loadbalancer](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Dynamic%20Assignments/images/LB%20code%20.png)
                         

   - Now , inside your generaal playbook (site.yml) file, dynamically import the load balancer playbook so it can use the roles weve created

                         - import_playbook: ../static-assignments/loadbalancers.yml
                           when: load_balancer_is_required

      Your `site.yml` should like the output below

     Output: ![site](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Dynamic%20Assignments/images/site.yml.png)

   - To activate load balancer, and enable either of Apache or Nginx load balancer, we can achieve this  by setting these in the respective environment's env-vars file.
   - Open the `env-vars/uat.yml` file and set it . here is how is how the code should be

                         ---
                        load_balancer_is_required: true
                        enable_nginx_lb: true
                        enable_apache_lb: false
     
   - To use apache, we can set the `enable_apache_lb` variable to true, and `enable_nginx_lb` to false. do the same thing for nginx if you want to enable nginx load balancer

### Step 4 : Configuring the apache and Nginx roles to work as load balancer

  #### For Apache

  - in the  `roles/apache/tasks/main.yml` file, wwe need to include a task that tells ansible to first check if nginx  is currently running and enabled, if it is, ansible should first stop and disable nginx before proceeding to install and enable apache. this is to avoid confliction and should always free up the port 80 for the required load balancer. use the code beow to achieve this :

                        - name: Check if nginx is running
                          ansible.builtin.service_facts:
                        
                        - name: Stop and disable nginx if it is running
                          ansible.builtin.service:
                            name: nginx 
                            state: stopped
                            enabled: no
                          when: "'nginx' in services and services['nginx'].state == 'running'"
                          become: yes

  - Save and exit
    
   Output: ![disable nginx](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Dynamic%20Assignments/images/disable-nginx.png)

  ##### To use apache as a load balancer, we will need to allow certain apache modules that will enable the load balancer. this is the APACHE A2ENMOD

  - in the `roles/apache/tasks/configure-debian.yml` file, Create a task to install and enable the required `apache a2enmod modules`, use the code below :

                          - name: Enable Apache modules
                            ansible.builtin.shell:
                              cmd: "a2enmod {{ item }}"
                            loop:
                              - rewrite
                              - proxy
                              - proxy_balancer
                              - proxy_http
                              - headers
                              - lbmethod_bytraffic
                              - lbmethod_byrequests
                            notify: restart apache
                            become: yes
                          
   - Create another task to update the apache configurations with required code block needed for the load balancer to function. use the code below :

                          - name: Insert load balancer configuration into Apache virtual host
                            ansible.builtin.blockinfile:
                              path: /etc/apache2/sites-available/000-default.conf
                              block: |
                                <Proxy "balancer://mycluster">
                                  BalancerMember http://<webserver1-ip-address>:80
                                  BalancerMember http://<webserver2-ip-address>:80
                                  ProxySet lbmethod=byrequests
                                </Proxy>
                                ProxyPass "/" "balancer://mycluster/"
                                ProxyPassReverse "/" "balancer://mycluster/"
                              marker: "# {mark} ANSIBLE MANAGED BLOCK"
                              insertbefore: "</VirtualHost>"
                            notify: restart apache
                            become: yes  

  
   - Save and create a pull request to merge with the main branch of your github repo.

     output: ![apache](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Dynamic%20Assignments/images/apache.png)

   #### For Nginx

   - In the `roles/nginx/tasks/main.yml` file, create a similar task like we did above to check if apache is active and enabled, if it is, it should disable and stop apache before proceeding with the tasks of installing nginx. use the code below :

                              - name: Check if Apache is running
                                ansible.builtin.service_facts:
                              
                              - name: Stop and disable Apache if it is running
                                ansible.builtin.service:
                                  name: apache2 
                                  state: stopped
                                  enabled: no
                                when: "'apache2' in services and services['apache2'].state == 'running'"
                                become: yes

   - In the `roles/nginx/handlers/main.yml` file, set nginx to always perform the tasks with sudo privileges, use the function : `become: yes` to achieve this
   - Do the same for all tasks that require sudo privileges

   output: ![sudo](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Dynamic%20Assignments/images/sudo.png)

   - In the `role/nginx/defaults/main.yml` file, uncomment the **nginx_vhosts, and nginx_upstream section**
   - Under the nginx_vhosts section, ensure you have the same code :

                             nginx_vhosts:
                              - listen: "80" # default: "80"
                                server_name: "example.com" 
                                server_name_redirect: "example.com"
                                root: "/var/www/html" 
                                index: "index.php index.html index.htm" # default: "index.html index.htm"
                                # filename: "nginx.conf" # Can be used to set the vhost filename.
                            
                                locations:
                                          - path: "/"
                                            proxy_pass: "http://myapp1"
                            
                              # Properties that are only added if defined:
                                server_name_redirect: "www.example.com" # default: N/A
                                error_page: ""
                                access_log: ""
                                error_log: ""
                                extra_parameters: "" # Can be used to add extra config blocks (multiline).
                                template: "{{ nginx_vhost_template }}" # Can be used to override the `nginx_vhost_template` per host.
                                state: "present" # To remove the vhost configuration.

     Output : ![nginx_vhost](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Dynamic%20Assignments/images/nginx_vhosts.png)

     - Under the `nginx_upstream` section, you wil need to update the servers address to include your webservers or uat servers.

                              nginx_upstreams: 
                              - name: myapp1
                                strategy: "ip_hash" # "least_conn", etc.
                                keepalive: 16 # optional
                                servers:
                                  - "<uat-server2-ip-address> weight=5"
                                  - "<uat-server1-ip-address> weight=5"

      Output: ![upstream](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Dynamic%20Assignments/images/nginx_upstream.png)

     - Save and exit.
     - finally, update the `inventory/uat.yml` to include the neccesary details for ansible to connect to each of these servers to perform all the roles we have specified. use the code below :

                                 [uat-webservers]
                                 <server1-ipaddress> ansible_ssh_user=<ec2-username> 
                                 <server2-ip address> ansible_ssh_user=<ec2-username> 
                                
                                 [lb]
                                 <lb-instance-ip> ansible_ssh_user=<ec2-username> 
                                
                                 [db-servers]
                                 <db-isntance-ip> ansible_ssh_user=<ec2-user>  



    

    
