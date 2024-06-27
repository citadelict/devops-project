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
   
![jenkins server](./images/18.png)

 - Update the ansible playbook in playbooks/site.yml for the tooling web app deployment. Click on Build Now.

![jenkins server](./images/19.png) 

![jenkins server](./images/20.png)

![jenkins server](./images/21.png)

### `Parameterizing Jenkinsfile For Ansible Deployment`      

- Update your `/inventory/sit.yml file with the code below

                    [tooling]
                    <SIT-Tooling-Web-Server-Private-IP-Address>
                    
                    [todo]
                    <SIT-Todo-Web-Server-Private-IP-Address>
                    
                    [nginx]
                    <SIT-Nginx-Private-IP-Address>
                    
                    [db:vars]
                    ansible_user=ec2-user
                    ansible_python_interpreter=/usr/bin/python
                    
                    [db]
                    <SIT-DB-Server-Private-IP-Address>

  ![jenkins server](./images/25.png)

There are always several environments that need configuration, such as CI, site, and pentest environments etc. To manage and run these environments dynamically, we need to update the Jenkinsfile.

                     parameters {
              string(name: 'inventory', defaultValue: 'dev',  description: 'This is the inventory file for the environment to deploy configuration')
            }

![jenkins server](./images/22.png)

- Update the inventory path with this : `${inventory}`
                 
![jenkins server](./images/23.png)

- Notice the `Build Now` is changed to `Build with Parameters` and this enables us to run differenet environment easily.

![jenkins server](./images/24.png)

### Add another Parameter to better understand the use, Introduce tagging in ansible , and limit the playbook execution to just specific roles,  for this task, ensure only the webserver roles are implemented when you run the playbook. To do this ,


   -  Add another parameter to the one we added above. specify the parameter name as `ansible_tags` and the default value to webserver

                       string(name: 'ansible_tags', defaultValue: 'webserver', description: 'Ansible tags to run specific roles or tasks')

![jenkins server](./images/26.png)

   - Update the playbook with tags to all the tasks to easily differentiate between them

![jenkins server](./images/27.png)

   - update the jenkins file to included the ansible tags before it runs playbook

![jenkins server](./images/28.png)

   - Click on build with parameters and update the inventory field to sit and the the ansible_tags to webserver

![jenkins server](./images/29.png)

   - Run your build .

![jenkins server](./images/30.png)

![jenkins server](./images/31.png)


### `CI/CD Pipeline for TODO application`

We already have tooling website as a part of deployment through Ansible. Here we will introduce another PHP application to add to the list of software products we are managing in our infrastructure. The good thing with this particular application is that it has unit tests, and it is an ideal application to show an end-to-end CI/CD pipeline for a particular application.

Our goal here is to deploy the application onto servers directly from `Artifactory` rather than from `git`.

### `Phase 1 – Prepare Jenkins`

  - Fork the todo repository below into your GitHub account

                  https://github.com/StegTechHub/php-todo.git

  - On you Jenkins server, install PHP dependencies for app, its dependencies and Composer tool

                  sudo apt update
                  sudo apt install -y zip libapache2-mod-php phploc php-{xml,bcmath,bz2,intl,gd,mbstring,mysql,zip}
                  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
                  sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
                  php -r "unlink('composer-setup.php');"
                  php -v
                  composer -v

![jenkins server](./images/32.png)


   - Install the required jenkins plugin, which is `plot` and `Artifactory` plugins

 `Plot Plugin Installation`  :  We will use plot plugin to display tests reports, and code coverage information.

![jenkins server](./images/33.png)

  ` Artifactory Plugin Installation`  :  The Artifactory plugin will be used to easily upload code artifacts into an Artifactory server.

![jenkins server](./images/34.png)


### `Phase 2 – Set up Ansible roles for artifactory`

  -  Create roles to install artifactory just the same way we set up apache, mysql and nginx in the previous project.

![jenkins server](./images/35.png)

![jenkins server](./images/36.png)

  -  Run the playbook against the `inventory/ci.yml`

![jenkins server](./images/37.png)

![jenkins server](./images/43.png)

  -  After installation, open port `8081` and port `8082` in your artifactory security group in bound rules

![jenkins server](./images/39.png)

![jenkins server](./images/40.png)

  - Configure Artifactory plugin by going to `manage jenkins` > `system configurations`, scroll down to jfrog and click on `add instance`
  - Input the ID, artifactory url , username and password
  - Click on `test connection` to test your url

![jenkins server](./images/44.png)

  -  Visit your `<your-artifactory-ip-address:8081`
  -  Sign in using the default artifactory credentials : `admin` and `password`


![jenkins server](./images/42.png)

  - Create a local repository and call it `todo-dev-local`, set the repository type to `generic`


![jenkins server](./images/45.png)

  - Update the database configuration in  `roles/mysql/vars/main.yml` to create a new database and user for the Todo App. use the details below :

                        Create database homestead;
                        CREATE USER 'homestead'@'%' IDENTIFIED BY 'sePret^i';
                        GRANT ALL PRIVILEGES ON * . * TO 'homestead'@'%';

![jenkins server](./images/46.png)

  - Create a Multibranch pipeline for the Php Todo App.

![jenkins server](./images/47.png)

  - Create a .env.sample file and update it with the credentials to connect the database, use sample the code  below :

                              APP_ENV=local
                              APP_DEBUG=true
                              APP_KEY=SomeRandomString
                              APP_URL=http://localhost
                              
                              DB_HOST=172.31.24.250
                              DB_DATABASE=homestead
                              DB_USERNAME=homestead
                              DB_PASSWORD=sePret^i
                              
                              CACHE_DRIVER=file
                              SESSION_DRIVER=file
                              QUEUE_DRIVER=sync
                              
                              REDIS_HOST=127.0.0.1
                              REDIS_PASSWORD=null
                              REDIS_PORT=6379
                              
                              MAIL_DRIVER=smtp
                              MAIL_HOST=mailtrap.io
                              MAIL_PORT=2525
                              MAIL_USERNAME=null
                              MAIL_PASSWORD=null
                              MAIL_ENCRYPTION=null
    
![jenkins server](./images/51.png)

   - php artisan uses the .env file to setup the required database objects – (After successful run of this step, login to the database, run show tables and you will see the tables being created for you)
   
![jenkins server](./images/48.png)

                            #update database server configuration
                            sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf
                            
                            # install mysql client on jenkins server
                            sudo yum install mysql -y 


   - Update Jenkinsfile with proper pipeline configuration

                                     pipeline {
                                    agent any
                                
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
                                            git branch: 'main', url: 'https://github.com/StegTechHub/php-todo.git'
                                      }
                                    }
                                
                                    stage('Prepare Dependencies') {
                                      steps {
                                             sh 'mv .env.sample .env'
                                             sh 'composer install'
                                             sh 'php artisan migrate'
                                             sh 'php artisan db:seed'
                                             sh 'php artisan key:generate'
                                      }
                                    }
                                  }
                                }
     
     - Ensure that all neccesary php extensions are already installed .
     - Run the pipeline build , you will notice that the database has been populated with tables using a method in laravel known as migration and seeding.      
    
![jenkins server](./images/53.png)

![jenkins server](./images/54.png)

  - Update the Jenkinsfile to include Unit tests step

                               stage('Execute Unit Tests') {
                              steps {
                                     sh './vendor/bin/phpunit'
                              } 
                                   
### `Phase 3 – Code Quality Analysis`

  This is one of the areas where developers, architects and many stakeholders are mostly interested in as far as product development is concerned. For PHP the most commonly tool used for code quality analysis is phploc.

The data produced by phploc can be ploted onto graphs in Jenkins.

To implement this, add the flow code snippet

                          stage('Code Analysis') {
                            steps {
                                  sh 'phploc app/ --log-csv build/logs/phploc.csv'
                          
                            }
                          }

Plot the data using plot Jenkins plugin

This plugin provides generic plotting (or graphing) capabilities in Jenkins. It will plot one or more single values variations across builds in one or more plots. Plots for a particular job (or project) are configured in the job configuration screen, where each field has additional help information. Each plot can have one or more lines (called data series). After each build completes the plots’ data series latest values are pulled from the CSV file generated by phploc.


![jenkins server](./images/55.png)

View in the `Plot` chart in Jenkins

![jenkins server](./images/59.png)

### `Phase 4 – Bundle and deploy` : Bundle the todo application code into an artifact and upload to jfrog artifactory. 

 - to do this, we have to add a stage to our todo jenkinsfile to save ethe artifact as a zip file, to do this : 
       * Edit your `php-todo/Jenkinsfile` , add the code below
   
                                              stage('Package Artifact') {
                                              steps {
                                                  sh 'zip -qr php-todo.zip ${WORKSPACE}/*'
                                              }
                                          }
                        
 -  Add another stage to upload the zipped artifact into our already configured artifactory repository.

                                     stage('Upload Artifact to Artifactory') {
                                      steps {
                                          script {
                                              def server = Artifactory.server 'artifactory-server'
                                              def uploadSpec = """{
                                                  "files": [
                                                  {
                                                      "pattern": "php-todo.zip",
                                                      "target": "Todo-dev/php-todo.zip",
                                                      "props": "type=zip;status=ready"
                                                  }
                                                  ]
                                              }"""
                                              println "Upload Spec: ${uploadSpec}"
                                              try {
                                                  server.upload spec: uploadSpec
                                                  println "Upload successful"
                                              } catch (Exception e) {
                                                  println "Upload failed: ${e.message}"
                                              }
                                          }
                                      }
                                  }


                                
   - Deploy the application to the dev envionment :  `todo server` by launching the ansible playbook.

                                      stage('Deploy to Dev Environment') {
                                      steps {
                                          build job: 'ansibllle-config-mgt/main', parameters: [[$class: 'StringParameterValue', name: 'inventory', value: 'dev']], propagate: false, wait: true
                                      }
                                  }
                              }

![jenkins server](./images/61.png)
                                
  - Write the tasks neccesary for setting up the dev environment in order to preapre it for deployment, like installing php, apache, creating html directories , etc , here is a sample of the tasks.

                              - name: install remi and rhel repo
                              ansible.builtin.yum:
                                name: 
                                  - https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
                                  - dnf-utils
                                  - http://rpms.remirepo.net/enterprise/remi-release-9.rpm
                                disable_gpg_check: yes
                            
                            - name: install httpd on the webserver
                              ansible.builtin.yum:
                                name: httpd
                                state: present
                            
                            - name: ensure httpd is started and enabled
                              ansible.builtin.service:
                                name: httpd
                                state: started 
                                enabled: yes
                              
                            - name: install PHP
                              ansible.builtin.yum:
                                name:
                                  - php 
                                  - php-mysqlnd
                                  - php-gd 
                                  - php-curl
                                  - unzip
                                  - php-common
                                  - php-mbstring
                                  - php-opcache
                                  - php-intl
                                  - php-xml
                                  - php-fpm
                                  - php-json
                                enablerepo: remi-7.4
                                state: present
                            
                            - name: ensure php-fpm is started and enabled
                              ansible.builtin.service:
                                name: php-fpm
                                state: started 
                                enabled: yes
                            
                            - name: Download the artifact
                              get_url:
                                url: http://18.192.100.8:8082/artifactory/Todo-dev-local/php-todo/php-todo.zip
                                dest: /home/ec2-user/php-todo.zip
                                url_username: admin
                                url_password: guessWhat232@
                            
                            - name: unzip the artifacts
                              ansible.builtin.unarchive:
                                src: /home/ec2-user/php-todo.zip
                                dest: /home/ec2-user/
                                remote_src: yes
                            
                            - name: deploy the code
                              ansible.builtin.copy:
                                src: /home/ec2-user/php-todo/
                                dest: /var/www/html/
                                force: yes
                                remote_src: yes
                            
                            - name: remove nginx default page
                              ansible.builtin.file:
                                path: /etc/httpd/conf.d/welcome.conf
                                state: absent
                            
                            - name: restart httpd
                              ansible.builtin.service:
                                name: httpd
                                state: restarted


    ![jenkins server](./images/62.png)

    
    ![jenkins server](./images/58.png)                            


     ![jenkins server](./images/63.png)

    Visit the todo ip address to access the todo application

     ![jenkins server](./images/64.png)
    

### `Install SonarQube on Ubuntu 24.04 With PostgreSQL as Backend Database`

 SonarQube is a tool that can be used to create quality gates for software projects, and the ultimate goal is to be able to ship only quality software code.

 #### `steps to Install SonarQube on Ubuntu 24.04 With PostgreSQL as Backend Database`

   - First thing we need to do is to tune linux to ensure optimum performance

                  sudo sysctl -w vm.max_map_count=262144
                  sudo sysctl -w fs.file-max=65536
                  ulimit -n 65536
                  ulimit -u 4096

  - Ensure a permanent change by editing the `/etc/security/limits.conf` , add the code below into it

                  sonarqube   -   nofile   65536
                  sonarqube   -   nproc    4096

  - Update and upgrade system packages

                  sudo apt-get update
                  sudo apt-get upgrade

  - Install wget and unzip packages

                  sudo apt-get install wget unzip -y

  - Install OpenJDK and Java Runtime Environment (JRE) 11

                  sudo apt-get install openjdk-11-jdk -y
                   sudo apt-get install openjdk-11-jre -y

  - Set default JDK - To set default JDK or switch to OpenJDK, to achieve this , use the command below :

                   sudo update-alternatives --config java
    
  - select your java from the list, that is if you already have mutiple installations of diffrent jdk versions
  - Verify the set JAVA Version:

                    java -version

 ![jenkins server](./images/64.png

  - Install and Setup PostgreSQL 10 Database for SonarQube

      * PostgreSQL repo to the repo list:

                  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
     
      * Download PostgreSQL software

                  wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

      * Install, start and ensure  PostgreSQL Database Server enables automatically during booting

                  sudo apt-get -y install postgresql postgresql-contrib
                  sudo systemctl start postgresql
                  sudo systemctl enable postgresql
        
      * Change the password for the default postgres user

                  sudo passwd postgres


![jenkins server](./images/66.png)

  - Set up User and password for postgres

      * Switch to the postgres user

                  su - postgres
        
      * Create a new user
   
                 createuser sonar

      * Switch to the PostgreSQL shell

                  psql

      * Set a password for the newly created user for SonarQube database
   
                      ALTER USER sonar WITH ENCRYPTED password 'sonar';


      * Create a new database for PostgreSQL database by running:

                  CREATE DATABASE sonarqube OWNER sonar;

      * Grant all privileges to sonar user on sonarqube Database.

                  grant all privileges on DATABASE sonarqube to sonar;

      * Exit from the psql shell and switch back to sudo user

                  \q
                  exit
        
![jenkins server](./images/67.png)

![jenkins server](./images/68.png)

#### Install SonarQube on Ubuntu 24.04

  - Navigate to the tmp directory to temporarily download the installation files

                  cd /tmp && sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.9.3.zip
    
  - Unzip the archive setup to /opt directory

                  sudo unzip sonarqube-7.9.3.zip -d /opt


  - Move extracted setup to /opt/sonarqube directory

                  sudo mv /opt/sonarqube-7.9.3 /opt/sonarqube

  - Configure SonarQube  - Sonarqube cannot be run as a root user, if you log in as a root user, it will stop automatically., so we need to configure sonarqube with a different user.

       * Create a group sonar

                   sudo groupadd sonar

       * Now add a user with control over the /opt/sonarqube directory

                    sudo useradd -c "user to run SonarQube" -d /opt/sonarqube -g sonar sonar 
                     sudo chown sonar:sonar /opt/sonarqube -R

       * Open SonarQube configuration file

                     sudo vim /opt/sonarqube/conf/sonar.properties

       * Find the following lines:  `#sonar.jdbc.username=` , `#sonar.jdbc.password=` , uncomment them and add the username and password we earlier created for postgres
![jenkins server](./images/69.png)

       * Edit the sonar script file and set RUN_AS_USER

                     sudo nano /opt/sonarqube/bin/linux-x86-64/sonar.sh
                     ```
![jenkins server](./images/70.png)

  - Now, to start SonarQube we need to do following:

      * Switch to sonar user

                          sudo su sonar

      * Move to the script directory

                          cd /opt/sonarqube/bin/linux-x86-64/

      * Run the script to start SonarQube , and Check SonarQube running status:

                          ./sonar.sh start
                          ./sonar.sh status

![jenkins server](./images/71.png)

![jenkins server](./images/72.png)

  * To check SonarQube logs, navigate to /opt/sonarqube/logs/sonar.log directory

                          tail /opt/sonarqube/logs/sonar.log

![jenkins server](./images/73.png)

 - Configure SonarQube to run as a systemd service, To do this, Stop the currently running SonarQube service

                           ./sonar.sh stop
![jenkins server](./images/74.png)

   
 - Create a systemd service file for SonarQube to run as System Startup.

                              sudo nano /etc/systemd/system/sonar.service

 - Add the configuration below for systemd to determine how to start, stop, check status, or restart the SonarQube service.

                             [Unit]
                            Description=SonarQube service
                            After=syslog.target network.target
                            
                            [Service]
                            Type=forking
                            
                            ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
                            ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
                            
                            User=sonar
                            Group=sonar
                            Restart=always
                            
                            LimitNOFILE=65536
                            LimitNPROC=4096
                            
                            [Install]
                            WantedBy=multi-user.target

  ![jenkins server](./images/75.png)

   - Save exit. now you can go ahead and control the service using systemctl

                           sudo systemctl start sonar
                           sudo systemctl enable sonar
                           sudo systemctl status sonar

  ![jenkins server](./images/76.png)

   - Visit sonarqube config file and uncomment the line of `sonar.web.port=9000`

   ![jenkins server](./images/77.png)   

   - Open port 9000 in your security group for the sonarqube server and access your `<ip-address>:9000`

  ![jenkins server](./images/78.png)



### `Configure SonarQube and Jenkins For Quality Gate` : 

- In jenkins , install the `sonarqubescanner plugin`
- Go to jenkins global configuration and add sonarqube server as shown below

  ![jenkins server](./images/79.png)

- Generate authentication token in SonarQube by `User > My Account > Security > Generate Tokens`

  ![jenkins server](./images/80.png)

- Configure Quality Gate Jenkins Webhook in SonarQube – The URL should point to your Jenkins server http://{JENKINS_HOST}/sonarqube-webhook/ , go to `Administration > Configuration > Webhooks > Create`

 ![jenkins server](./images/81.png)

- Setup SonarQube scanner from Jenkins – Global Tool Configuration

 ![jenkins server](./images/84.png)


- Update Jenkins Pipeline to include SonarQube scanning and Quality Gate and run Jenkinsfile

  > Note this will fail but enable us update the sonar-scanner.properties below

                          ```bash
                             stage('SonarQube Quality Gate') {
                                  environment {
                                      scannerHome = tool 'SonarQubeScanner'
                                  }
                                  steps {
                                      withSonarQubeEnv('sonarqube') {
                                          sh "${scannerHome}/bin/sonar-scanner"
                                      }
                          
                                  }
                              }
                          ```


     ![jenkins server](./images/86.png)
    ![jenkins server](./images/82.png)


  - Configure `sonar-scanner.properties` – From the step above, Jenkins will install the scanner tool on the Linux server. You will need to go into the tools directory on the server to configure the properties file in which SonarQube will require to function during pipeline execution.

                          ```bash
                            cd /var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQubeScanner/conf/
                            
                            sudo vi sonar-scanner.properties
                            ```
    ![jenkins server](./images/85.png)
    
 - Add configuration related to php-todo project


                                  ```bash
                                    sonar.host.url=http://<SonarQube-Server-IP-address>:9000
                                    sonar.projectKey=php-todo
                                    #----- Default source code encoding
                                    sonar.sourceEncoding=UTF-8
                                    sonar.php.exclusions=**/vendor/**
                                    sonar.php.coverage.reportPaths=build/logs/clover.xml
                                    sonar.php.tests.reportPath=build/logs/junit.xml
   
                                    ```
  ![jenkins server](./images/87.png)

  - To further examine the configuration of the scanner tool on the Jenkins server - navigate into the tools directory

                                cd /var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQubeScanner/bin

  - List the content to see the scanner tool sonar-scanner. That is what we are calling in the pipeline script.

    Output of `ls -latr`

    ![jenkins server](./images/88.png)  

  - Run your pipeline script and View the Quailty gate for the Php-Todo app in Sonarqube

   ![jenkins server](./images/90.png)  
   
   ![jenkins server](./images/91.png)  


  ### `Conditionally deploy to higher environments`

   - Let us update our Jenkinsfile to implement this:
      * First, we will include a When condition to run Quality Gate whenever the running branch is either develop, hotfix, release, main, or master

                            when { branch pattern: "^develop*|^hotfix*|^release*|^main*", comparator: "REGEXP"}

      * Then we add a timeout step to wait for SonarQube to complete analysis and successfully finish the pipeline only when code quality is acceptable.

                                timeout(time: 1, unit: 'MINUTES') {
                                  waitForQualityGate abortPipeline: true
                              }

      * The complete stage will now look like this

                                stage('SonarQube Quality Gate') {
                                  when { branch pattern: "^develop*|^hotfix*|^release*|^main*", comparator: "REGEXP"}
                                    environment {
                                        scannerHome = tool 'SonarQubeScanner'
                                    }
                                    steps {
                                        withSonarQubeEnv('sonarqube') {
                                            sh "${scannerHome}/bin/sonar-scanner -Dproject.settings=sonar-project.properties"
                                        }
                                        timeout(time: 1, unit: 'MINUTES') {
                                            waitForQualityGate abortPipeline: true
                                        }
                                    }
                                }

      * To test, create different branches and push to GitHub. You will realise that only branches other than develop, hotfix, release, main, ormaster will be able to deploy the code.

     ![jenkins server](./images/92.png)

     ![jenkins server](./images/94.png)  

  ### `Introduce Jenkins agents/slaves`
  Jenkins architecture is fundamentally "Master+Agent". The master is designed to do co-ordination and provide the GUI and API endpoints, and the Agents are designed to perform the     work. The reason being that workloads are often best "farmed out" to distributed servers.

  - Let's add 2 more servers to be used as Jenkins slave. Launch 2 more instances for Jenkins slave and install java in them

                                # install  java on slave nodes
                                  sudo yum install java-11-openjdk-devel -y
                                  
                                  #verify Java is installed
                                  java --version
                                  
 - Configure Jenkins to run its pipeline jobs randomly on any available slave nodes. Let's Configure the new nodes on Jenkins Server. Navigate to `Dashboard > Manage Jenkins > Nodes`, click on New node and enter a Name and click on create.                                                                

  ![jenkins server](./images/95.png)  

- At this point, Only one slave is  created but not connected. 

  ![jenkins server](./images/96.png)

- To connect to slave_one, click on the slave_one and completed this fields and save.
    * `Name`: slave_one
    * `Remote root directory`: /opt/build (This can be any directory for the builds)
    * `Labels`: slave_one and save
    * Click back on Slave_one to configure and navigate to status
    * Use any options. But since i am making use of a UNIX system ,I would use the first option.

   ![jenkins server](./images/102.png)

    * In the Slave_one terminal, enter the following
 
        
                  # Download agent.jar to /opt/build. Make sure to Jenkins IP here
                  curl -sO http://18.197.153.7:8080/jnlpJars/agent.jar

                  # If added a `Remote root directory` like above /opt/build. Create it and allow permission

                  Sudo mkdir /opt/build
                  
                  sudo chmod 777 /opt/build


      * Go to `dashboard > manage jenkins > security > Agents`
      * Set the TCP port for inbound agents to fixed and set the port at 5000 ( or any one you choose )
        
        ![jenkins server](./images/103.png)
        
      * Go to the security group on jenkins ec2 instance and open port 5000
      * go back to slave terminal and run the command
     
        ![jenkins server](./images/98.png)
      
                                    java -jar agent.jar -url http://18.197.153.7:8080/ -secret c2d38f8cd0ae08fc1930f1a486adfe095fc4a38f83d7948a273cfaa506e05aa7 -name "slave_one" -workDir "/opt/build"

      * Verify that slave is connected in jenkins
        
       ![jenkins server](./images/99.png)
      
      * Repeat same process for slave two
     
         ![jenkins server](./images/100.png)

      
 - Configure webhook between Jenkins and GitHub to automatically run the pipeline when there is a code push. The PHP -Todo repo, click on `settings > Webhooks`. Enter `/github-webhook/` and in content type, select application/json and save

    ![jenkins server](./images/101.png)


### `Optional Step` 

Using ansible roles, Install wireshark in the pentest env server. here are a list of ansible roles you could use : 

  - https://github.com/ymajik/ansible-role-wireshark (Ubuntu)
  - https://github.com/wtanaka/ansible-role-wireshark (RedHat)

* Add the roles to your ansible configuration managenment project
  
  ![jenkins server](./images/106.png)
  
* Import the playbook in your `playbooks/site.yml` file
  
  ![jenkins server](./images/106.png)
  
* Add the `wireshark.yml` playbook inside the static-assignments directory
  
  ![jenkins server](./images/108.png)
  
* Push to your repository and allow your pipeline build and eploy ansible playbook tasks
  
![jenkins server](./images/104.png)

![jenkins server](./images/105.png)






