
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
           










