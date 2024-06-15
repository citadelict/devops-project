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
     












  










    

    
