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

          
          sudo apt update && sudo apt upgrade -y
          sudo apt install ansible -y
          
![jenkins server](./images/14.png)


### `Install Ansible Plugin on Jenkins`

   - On the dashboard page, click on `Manage Jenkins` > `Manage plugins` > Under `Available` type in `ansible` and install without restart

![jenkins server](./images/15.png)

   - Click on `Dashboard` > `Manage Jenkins` > `Tools` > `Add Ansible`. Add a name and the path ansible is installed on the jenkins server.
   - To get the ansible path on the jnekins server, run :

           > $ which ansible

![jenkins server](./images/16.png)

   - Now, delete all you have in your Jenkinsfile and start writing it again. to do this, we can make use of pipeline syntax to ensure we get the exact command for what we intend to achieve. here is how the Jenkinsfile should look eventually .

                       pipeline {
                              agent any
                            
                              environment {
                                ANSIBLE_CONFIG = "${WORKSPACE}/deploy/ansible.cfg"
                                ANSIBLE_HOST_KEY_CHECKING = 'False'
                              }
                            
                              stages {
                                stage("Initial cleanup") {
                                  steps {
                                    dir("${WORKSPACE}") {
                                      deleteDir()
                                    }
                                  }
                                }

                                stage('Checkout SCM') {
                                  steps {
                                    git branch: 'main', url: 'https://github.com/citadelict/ansibllle-config-mgt.git'
                                  }
                                }
                            
                                stage('Prepare Ansible For Execution') {
                                  steps {
                                    sh 'echo ${WORKSPACE}'
                                    sh 'sed -i "3 a roles_path=${WORKSPACE}/roles" ${WORKSPACE}/deploy/ansible.cfg'
                                  }
                                }
                            
                                stage('Test SSH Connections') {
                                  steps {
                                    script {
                                      def hosts = [
                                        [group: 'tooling', ip: '172.31.30.46', user: 'ec2-user'],
                                        [group: 'tooling', ip: '172.31.25.209', user: 'ec2-user'],
                                        [group: 'nginx', ip: '172.31.26.108', user: 'ubuntu'],
                                        [group: 'db', ip: '172.31.24.250', user: 'ubuntu']
                                      ]
                                      for (host in hosts) {
                                        sshagent(['private-key']) {
                                          sh "ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/key.pem ${host.user}@${host.ip} exit"
                                        }
                                      }
                                    }
                                  }
                                }
                            
                                stage('Run Ansible playbook') {
                                  steps {
                                    sshagent(['private-key']) {
                                      ansiblePlaybook(
                                        become: true,
                                        credentialsId: 'private-key',
                                        disableHostKeyChecking: true,
                                        installation: 'ansible',
                                        inventory: "${WORKSPACE}/inventory/dev.yml",
                                        playbook: "${WORKSPACE}/playbooks/site.yml"
                                      )
                                    }
                                  }
                                }
                            
                                stage('Clean Workspace after build') {
                                  steps {
                                    cleanWs(cleanWhenAborted: true, cleanWhenFailure: true, cleanWhenNotBuilt: true, cleanWhenUnstable: true, deleteDirs: true)
                                  }
                                }
                              }
                            }


![jenkins server](./images/17.png)
  * ### Here is what each part of my jenkinsfile does :
      - Environment variables are set for the pipeline: `ANSIBLE_CONFIG` specifies the path to the Ansible configuration file. while `ANSIBLE_HOST_KEY_CHECKING` disables host key checking to avoid interruptions during SSH connections.
      - Stage: `Initial cleanup` : This cleans up the workspace to ensure a fresh environment for the build by deleting all files in the workspace directory.
      - Stage: `Checkout SCM` : This checks out the source code from the specified Git repository, and alos uses `git` step to clone the repository.
      - Stage:` Prepare Ansible For Execution` : Prepares the Ansible environment by configuring the Ansible roles path by printing the workspace path, and modifying the Ansible configuration file to add the roles path.
      - Stage: `Test SSH Connections` : Verifies SSH connectivity to each server.
      - Stage: `Run Ansible playbook` : Executes the Ansible playbook. :
            - Uses the sshagent step to ensure the SSH key is available for Ansible.
            - Runs the ansiblePlaybook step with the specified parameters .
            ####  To ensure jenkins properly connects to all servers, you will need to install another plugin known as `ssh agent` , after that, go to `manage jenkins` > `credentials` > `global` > `add credentials` , usee `ssh username and password` , fill out the neccesary details and save.

    - Now back to your `inventory/dev.yml` , update the inventory with thier respective servers private ip address

      
         




