
# Ansible Refactoring & Static Assignments (Imports and Roles) - 102

## Overview
This project enhances our Jenkins setup and refactors Ansible code to improve scalability and maintainability by introducing more structured organization and deployment strategies through Jenkins and Ansible.

# Step 1: Jenkins Job Enhancement

### Initial Setup
Before we begin, we need to optimize our Jenkins setup to handle artifacts more efficiently:
- **Create a directory** on your Jenkins-Ansible server (ec2-instance) to store all artifacts after each build:

        sudo mkdir /home/ubuntu/ansible-config-artifact

- **Change Permission** to this new directory so that jenkins can save the arcchives to it

        sudo chmod -R 0777 /home/ubuntu/ansible-config-artifact

- Go to Jenkins web console -> `Manage Jenkins` -> `Manage Plugins`.search for `copy Artifacts` and then install it
  
  OUTPUT:![save artifacts plugin](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/installed%20copy%20artifacts%20plugin.png)
  
- Create a new Freestyle project and call it `save_artifacts`
- Configure this project to be triggered by the completion of the previous ansible project(ansible), to do this ,
    - go to `save_artifacts` project, > `configure` > `general tab` , Click to check the `discard old builds` option, on `strategy` ,set it to **log rotation**, also set the `max number of builds` to ""2"" . this is done in order to keep space on the server
      
  OUTPUT:![configure save artifacts](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/configure%20save%20artifacts.png)
  
    - Set `SCM` to **none**,
    - Under `build triggers` , select `build after other projects are built` , and under `projects to watch`, input the name of your previous ansible project, in this case : "ansible"
    - Set up `build steps`  select "copy artifacts from another project" , in the drop down , input the name of the project. as is this case : "ansible". under `which build`, set it to "latest successful build" , and under artifacts to copy , use `**` to select all
 
  OUTPUT : ![build steps](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/configure%20build%20steps.png)

    - Save the configurations and make changes to your `README.md` file in your github `ansible-config-mgt` and ensure the build triggers upon changes made on the file, also confirm the new save artifact job build also triggers from the completion of the ansible build
 

  OUTPUT: ![build successful](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/build%20succesful.png)

# Step 2 .  Refactor Ansible Code by Importing Other Playbooks
   * Setting Up for Refactoring
       - Ensure you have pulled the latest code from the master (main) branch. This is best practice and to ensure your project is always updated with the latest code

                 git pull origin <branch>
         
       - Create a new branch and name it `refactor`

                 git branch refactor
         
       - Select the created refactor branch

                 git checkout refactor
         
  OUTPUT: ![new branch](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/create%20a%20new%20branch-refactor.png)
  
 -  Create a `site.yml` file in the playbooks folder. This will serve as the entry point to all configurations.
 -  Create a `static-assignments` folder at the root of the repository for organizing child playbooks.
 -  Move the `common.yml` file into the newly created static-assignments folder
 -  In site.yml, import common.yml:

                 ---
                - hosts: all
                - import_playbook: ../static-assignments/common.yml

* Your folder structure should like this below

  OUTPUT: ![folder structure](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/folder%20structure.png)

* Push to your github repo and create a pull request, carefully check your codes and merge into your main branch

 OUTPUT: ![git add](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/git%20add%2C%20git%20commit.png)
 
* Access your jenkins-ansible server via ssh agent and navigate to `ansible-config-artifact` directory and run the playbook command against the dev environment

                  ansible-playbook -i inventory/dev.yml playbooks/site.yml
  
  OUTPUT: ![playbook command](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/running%20site-yml%20playbook.png)

  OUTPUT2 : ![playbook 2](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/running%20site-yml%20playbook%202.png)

    - Create another playbook `common-del.yml` under static-assignments for deleting Wireshark. inside it, place the following code in it and save

                        ---
                        - name: update web, nfs servers
                          hosts: webservers, nfs
                          remote_user: ec2-user
                          become: yes
                          become_user: root
                          tasks:
                          - name: delete wireshark
                            yum:
                              name: wireshark
                              state: removed
                        
                        - name: update LB and db servers
                          hosts: lb, db
                          remote_user: ubuntu
                          become: yes
                          become_user: root
                          tasks:
                          - name: delete wireshark
                            apt:
                              name: wireshark
                              state: absent
                              autoremove: yes
                              purge: yes
                              autoclean: yes
                            - 
          
        - Update site.yml to import `common-del.yml` instead of common.yml.
        - Push to github 

    OUTPUT: ![create common-del.yml](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/create%20common-del.yml.png)
      OUTPUT : ![confirm code ](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/confirm%20code%20.png)

   - Access your ansible-jenkins server, navigate to the directory where the artifacts are saved and run the playbook command again
     
                  cd /home/ubuntu/ansible-config-artifact/
                  ansible-playbook -i inventory/dev.yml playbooks/site.yml

      OUTPUT: ![delete wireshark](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/running%20playbook%20to%20delete%20wireshark.png)

   - Ensure wireshark is deleted on all servers by running `wireshark --version`

      OUTPUT: ![del-wireshark-web A](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/webserver%20a%20del-wireshark.png)
      
      OUTPUT: ![del-wireshark-web-B](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/wireshark%20del%20-web%20b.png)
      
      OUTPUT: ![del-wireshark-nfs](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/wireshark%20del-nfs.png)
      
      OUTPUT: ![del-wireshark-lb](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/del-%20wireshark%20lb.png)

      OUTPUT: ![del-wirehsark mysql](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/wireshark-del-mysql.png)
           
 # Step 3. Configure UAT Webservers with a Role 'Webserver'

 ## Overview
After setting up a clean development environment, we will now configure two new Web Servers as UAT environments using Red Hat Enterprise Linux (RHEL) 8. This step involves using Ansible roles to ensure our configurations are reusable and maintainable.

## Initial Setup
1. **Launch two EC2 instances** using the RHEL 8 image. Name them `Web1-UAT` and `Web2-UAT`.
2. **Remember to stop EC2 instances** that you are not using to avoid unnecessary charges.

## Role Creation
You can create the Ansible role using either the `ansible-galaxy` command or manually: However , since we use github as version control, it is advisable to manually create the roles directory and the chikd fikes in it, so in your vs code terminal, run the following code to create the roles directory and child files

                mkdir roles
                cd roles
                mkdir webserver
                cd webserver
                touch README.md
                mkdir defaults, handlers, meta, tasks, templates

   * Navigate into each of the created directories and create a `main.yml` file in each directory
  
 - Update your `uat.yml` at "ansible-config-mgt/inventory/uat.yml" with the IP addresses of your two UAT Web servers:

                   [uat-webservers]
                <Web1-UAT-Server-Private-IP-Address> ansible_ssh_user='ec2-user'
                <Web2-UAT-Server-Private-IP-Address> ansible_ssh_user='ec2-user'

  - Configure ansible.cfg : Ensure that your ansible.cfg file (usually located at /etc/ansible/ansible.cfg) has the roles_path uncommented and correctly set:

             roles_path = /home/ubuntu/ansible-config-artifact/roles

  - Navigate to the `tasks` directory of your webserver role and add tasks to install Apache, clone the GitHub repository, and configure the server:

  - Open the `tasks/main.yml` file and update it with the code to perform the above tasks i mentioned, 

                        
                              ---
                        - name: install apache
                          become: true
                          ansible.builtin.yum:
                            name: "httpd"
                            state: present
                        
                        - name: install git
                          become: true
                          ansible.builtin.yum:
                            name: "git"
                            state: present
                        
                        - name: clone a repo
                          become: true
                          ansible.builtin.git:
                            repo: https://github.com/citadelict/tooling2.git
                            dest: /var/www/html
                            force: yes
                        
                        - name: copy html content to one level up
                          become: true
                          command: cp -r /var/www/html/html/ /var/www/
                        
                        - name: Start service httpd, if not started
                          become: true
                          ansible.builtin.service:
                            name: httpd
                            state: started
                        
                        - name: recursively remove /var/www/html/html/ directory
                          become: true
                          ansible.builtin.file:
                            path: /var/www/html/html
                            state: absent

### NB- These tasks will ensure that your UAT servers are configured with Apache serving content cloned from your specified GitHub repository.

OUTPUT: ![tasks-main](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/tasksmain.yml.png)

  - save and exit

     # Step 4 :  Reference 'Webserver' Role in Playbook

       - Within the `static-assignments` folder, create a new playbook file named `uat-webservers.yml`. This playbook will specifically configure your UAT web servers by utilizing the 'Webserver' role. update the file with the code below to reference the webserver role

                                 ---
                                - hosts: uat-webservers
                                  roles:
                                     - webserver
  OUTPUT: ![refrence](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/uat-webserver.yml.png)

 - Make sure to add a reference to this new playbook in `site.yml`, alongside your existing playbook settings. By doing this, site.yml will continue to serve as the central point for all your Ansible configurations. therefore update the `site.yml` file with the code below :

                         ---
                        ##- hosts: all
                        ##- import_playbook: ../static-assignments/common.yml
                        - hosts: uat-webservers
                        - import_playbook: ../static-assignments/uat-webservers.yml

OUTPUT: ![updated site.yml](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/updated%20site.yml.png)

 # Step 5: Commit & Test

  - Commit your changes to your Git repository.
  - Create a Pull Request and merge it into the main branch
  - Access your ansible-jenkins server and navigate to the `ansible-config-artifact` directory
  - Run the playbook command

          cd /home/ubuntu/ansible-config-artifact
          ansible-playbook -i inventory/uat.yml playbooks/site.yml

 OUTPUT: ![playbook command](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/playbook%20command.png)

  - Please check that your UAT Web servers are set up correctly. You should be able to visit your servers using any web browser.

OUTPUT: ![uat-server a and b](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible%20Refactoring%20%26%20Static%20Assignments%20(Imports%20and%20Roles)-%20104/images/accessed%20tooling%20website%20via%20uat%20servers.png)

# Blockers  . "Jenkins Job Creation" : in a situation where you get an access denied from your jenkins save artifact job when trying to build , this is caused by jenkins not been able to access the specified folder to save the artifacts
- "How i solved it" :
  1. In your ansible-jenkins server, change user from `ubuntu` to `jenkins` 
      
                                sudo su - jenkins

  2. try accessing the the "/home/ubuntu/ansible-config-artifact" directory,If you get a permission denied, you need to ensure jenkins user has all the permision to read, write and execute on that directory. To do this , 
  3.  Add jenkins to the same sudo group as ubuntu

                               sudo usermod -a -G ubuntu jenkins
                               # verify jenkins has been added to the group
                               groups jenkins




   4. it should now show that jenkins is in the same group as ubuntu,
   5. Verify jenkins can now access the "/home/ubuntu/ansible-config-artifact" directory

                  cd /home/ubuntu/ansible-config-artifact
      NB-if it can now access the directory,
   6. Restart jenkins server

                   sudo systemctl restart jenkins

   7. Run your build again, this time , it should save artifacts to the server diectory


# conclusion : 

Throughout this project, we've tackled a variety of improvements and optimizations that really showcase the strength of incorporating advanced DevOps tools and practices. From tweaking our Jenkins configurations to taking advantage of Ansible for more powerful and scalable infrastructure management, every step has played a part in making our processes more streamlined and effective.


