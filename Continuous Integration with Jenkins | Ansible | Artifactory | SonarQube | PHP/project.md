# Configure Ansible configuration repo For Jenkins Deployment

This is project is continuation from my ansible dynamic assignment projects.
I would be using a copy of the  `ansible-config-mgt` repo which I have renamed `ansible-configuration`


## 1 `Installing Jenkins`

Start by launching an AWS EC2 instance with a Ubuntu OS and set up the Jenkins server.

![jenkins server](./images/1.png)

> Make sure to open port 8080 in the security group

## 2 `Installing Blue-Ocean Plugin`
To make managing your Jenkins pipelines easier and more intuitive, install the Blue Ocean plugin. This plugin offers a user-friendly and visually appealing interface, helping you quickly understand the status of your continuous delivery pipelines.

To do this , follow the steps below :

  - Go to `manage jenkins` > `manage plugins` > `available`
  - Search for BLUE OCEAN PLUGIN  and install

![jenkins server](./images/2.png)

## 3 `Configure the Blue Ocean plugin pipeline with our github repo`

To do this, follow the step below:

  - Open the blue oceans plugin and `create a new pipeline`
  - Select github
  - Connect github with jenkins using your github personal access token
  - Select the repository
  - Create the pipeline

![jenkins server](./images/3.png)

  - In order for Jenkins to reconginze our repo, we need to add a Jenkinsfile. Create a `deploy` folder and add a `Jenkinsfile` to it.

![jenkins server](./images/5.png)

  - Let's create a simple pipeline with one stage `build`. This has a shell command to echo a text "echo "Building Stage".

          ```bash
              pipeline {
                  agent any
              
                stages {
                  stage('Build') {
                    steps {
                      script {
                        sh '"echo "Building Stage"'
                      }
                    }
                  }
                  }
              }
          ```
              
  - Now go back into the Ansible pipeline in Jenkins, and select `configure` then Scroll down to `Build Configuration`, inside `script Path` specify the location of the Jenkinsfile at `deploy/Jenkinsfile`

![jenkins server](./images/6.png)

  - Go back to the pipeline again, this time click `Build` now and then click on `blue ocean` on the right menu.

![jenkins server](./images/7.png)
![jenkins server](./images/8.png)

  - Jenkins usually scan all branches to build. Let see this in action. Create a new branch `feature/jenkinspipeline-stages` and add one more stage `test`to the pipeline`

![jenkins server](./images/10.png)

  - Click on `scan repository now` to build all available branches on the repository.
  - In `Blue Ocean`, you can now see how the Jenkinsfile has caused a new step in the pipeline launch build for the new branch.

![jenkins server](./images/11.png)

`additinal Tasks to perform tp better understand the whole process`.

  - Let's create a pull request to merge the latest code into the main branch, after merging the PR, go back into your terminal and switch into the main branch.Pull the latest change.
  - Create a new branch, add more stages into the Jenkins file to simulate below phases. (Just add an echo command like we have in build and test stages)

       1. Package 
       2. Deploy 
       3. Clean up

![jenkins server](./images/13.png)

   - Scan the repo again and allow jenkins build

![jenkins server](./images/12.png)

### `Running Ansible playbook from Jenkins`

 Now that we have understanding of how a typical jenkins pipeline works, lets go further by integratiing `Ansible` into our setup

### `Install Ansible`








