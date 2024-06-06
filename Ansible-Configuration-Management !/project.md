
# Ansible Configuration Management for EC2

## Overview

This guide details the process for deploying and managing EC2 instances using Ansible. It includes steps for Ansible installation, playbook creation, and server management automation.

## Installation: Setting Up Ansible on Your EC2 Instance

### Step 1: Preparing Your EC2 Instance

- **Rename your Jenkins EC2 instance to `Jenkins-Ansible`**:
  - **Purpose**: This specific naming helps in easily identifying the purpose of the instance, which is crucial when managing multiple servers.
  - **Action**: Update the `Name` tag on your EC2 instance dashboard.
    
  ![EC2 Instance List](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible-Configuration-Management%20!/images/updated%20name%20tag%20jtoa.png)

### Step 2: Creating a GitHub Repository

- **Initiate a new repository named `ansible-config-mgt`**:
 


### Step 3: Installing Ansible

- **Install Ansible on your EC2 instance**:
  - **Purpose**: Ansible automates and simplifies application deployment, systems configuration, and other IT needs.

    ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install ansible -y
    ```
  -  Ensure the installation was successful by checking the Ansible version.
    ```bash
    ansible --version
    ```
  ![Verify Ansible Installation](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible-Configuration-Management%20!/images/installed%20ansible.png)

### Step 4: Configuring Jenkins

- **Configure Jenkins to build from the GitHub repository**:
  - **Purpose**: Automates the deployment process, ensuring that the latest configurations are always in use.
  - **Action**: Set up a new freestyle project in Jenkins and link it to the `ansible-config-mgt` GitHub repository.
 

- **Set up a GitHub webhook**:
  - **Purpose**: Triggers Jenkins builds automatically upon code commits, reducing the need for manual oversight.
  ![GitHub Webhook Configuration](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible-Configuration-Management%20!/images/created%20webhook.png)

- **Configure SCM and build triggers**:
  - Under configure, select source code management and set it up to connect to github, set user name and password 
  ![SCM and Build Trigger Configuration](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible-Configuration-Management%20!/images/scm.png)

  
  ![Build Trigger Setup](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible-Configuration-Management%20!/images/build%20triggers.png)

- **Post-build actions**:
  - **Purpose**: Saves all necessary files and ensures that any deployment artifacts are stored properly.


## Preparing Your Development Environment

### Step 5: Using Visual Studio Code

- **Connect VSC to GitHub**:
  - **Commands**:
    ```bash
    git config --global user.email "your-github-email"
    git config --global user.name "Your-userName"
    ```

- **Clone the repository**:
  - **Purpose**: Allows you to work locally on the Ansible configurations.
  - **Command**:
    ```bash
    git clone <repository-url>
    ```
 

## Developing with Ansible

### Step 6: Ansible Playbook Development

- **Create a playbook directory structure**:
  - **Directories**: `playbooks` for storing playbooks and `inventory` for managing hosts.
  - **Purpose**: Organizes your Ansible project clearly, making it easier to manage.
  ![Create Playbook and Inventory](https://github.com/citadelict/My-devops-Journey/blob/main/Ansible-Configuration-Management%20!/images/created%20dir%20inv%2C%20playbooks.png)

### Step 7: Setting Up an Ansible Inventory

- **Configure inventory files**:
  - **Purpose**: Defines which hosts are managed by which playbooks, crucial for targeting the correct environments.
  - **Files**: `inventory/dev`, `inventory/staging`, `inventory/uat`, and `inventory/prod`.
  ```bash
       [nfs]
      172.31.57.222; ansible_ssh_user=ec2-user
      
      [webservers]
      172.31.189.178; ansible_ssh_user=ec2-user
      172.31.222.77; ansible_ssh_user=ec2-user
      
      [db]
      172.31.176.122; ansible_ssh_user=ubuntu
      
      [lb]
      18.194.126.158; ansible_ssh_user=ubuntu
       
