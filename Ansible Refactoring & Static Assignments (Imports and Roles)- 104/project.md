
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














