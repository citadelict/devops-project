
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
  - **Command**:
    ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install ansible -y
    ```
  - **Verification**: Ensure the installation was successful by checking the Ansible version.
    ```bash
    ansible --version
    ```
  ![Verify Ansible Installation](./images/ansible-version.PNG)

### Step 4: Configuring Jenkins

- **Configure Jenkins to build from the GitHub repository**:
  - **Purpose**: Automates the deployment process, ensuring that the latest configurations are always in use.
  - **Action**: Set up a new freestyle project in Jenkins and link it to the `ansible-config-mgt` GitHub repository.
  ![Jenkins Freestyle Project Setup](./images/create-freestyle-project-ansible.PNG)

- **Set up a GitHub webhook**:
  - **Purpose**: Triggers Jenkins builds automatically upon code commits, reducing the need for manual oversight.
  ![GitHub Webhook Configuration](./images/enable-webhook-on-github-repo.PNG)

- **Configure SCM and build triggers**:
  ![SCM and Build Trigger Configuration](./images/configure-ansible-job.PNG)
  ![Build Trigger Setup](./images/configure-build-triggers.PNG)

- **Post-build actions**:
  - **Purpose**: Saves all necessary files and ensures that any deployment artifacts are stored properly.
  ![Post Build Job](./images/create-post-build-action.PNG)

## Preparing Your Development Environment

### Step 5: Using Visual Studio Code

- **Install and configure Visual Studio Code**:
  - **Purpose**: Provides a robust environment for coding with direct integration to Git.
  - **Action**: Download and install from [Visual Studio Code official](https://code.visualstudio.com/learn/get-started/basics).

- **Connect VSC to GitHub**:
  - **Commands**:
    ```bash
    git config --global user.email "your-email@example.com"
    git config --global user.name "Your Name"
    ```

- **Clone the repository**:
  - **Purpose**: Allows you to work locally on the Ansible configurations.
  - **Command**:
    ```bash
    git clone <repository-url>
    ```
  ![Clone Repository](./images/clone-ansible-config-mgt-repo-locally.PNG)

## Developing with Ansible

### Step 6: Ansible Playbook Development

- **Create a playbook directory structure**:
  - **Directories**: `playbooks` for storing playbooks and `inventory` for managing hosts.
  - **Purpose**: Organizes your Ansible project clearly, making it easier to manage.
  ![Create Playbook and Inventory](./images/create-playbook-inventory-file.PNG)

### Step 7: Setting Up an Ansible Inventory

- **Configure inventory files**:
  - **Purpose**: Defines which hosts are managed by which playbooks, crucial for targeting the correct environments.
  - **Files**: `inventory/dev`, `inventory/staging`, `inventory/uat`, and `inventory/prod`.
  ```bash
  [webservers]
  web1 ansible_host=192.168.1.100
  web2 ansible_host=192.168.1.101

  [database]
  db1 ansible_host=192.168.1.200
