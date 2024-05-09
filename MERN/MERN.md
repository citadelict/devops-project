# Overview of the MERN Stack

The MERN stack is a popular technology stack used for building dynamic and scalable web applications. MERN is an acronym that stands for MongoDB, Express.js, React.js, and Node.js. Each of these components provides a layer in the stack, handling everything from the database, server, and API layers to the frontend.

## Components of the MERN Stack

### MongoDB

- **Type**: NoSQL database
- **Use**: Stores data in flexible, JSON-like documents which allows varied data structures to be used.
- **Features**: High performance, high availability, and easy scalability.
- **Why Use**: It is schema-less, which makes it more flexible than traditional relational databases.

### Express.js

- **Type**: Web application framework
- **Use**: Simplifies the task of building server setups and routing, handling HTTP requests and middleware functionality with ease.
- **Features**: Robust routing, asynchronous programming, and integration with numerous middleware modules.
- **Why Use**: It’s minimal, scalable, and pairs seamlessly with Node.js.

### React.js

- **Type**: JavaScript library for building user interfaces
- **Use**: Constructs the front-end or client-side of the application.
- **Features**: Virtual DOM (for efficient updates), JSX (JavaScript XML for building components), and component-based architecture.
- **Why Use**: It enables developers to create large web applications that can change data, without reloading the page for every single state change.

### Node.js

- **Type**: JavaScript runtime environment
- **Use**: Allows you to run JavaScript on the server-side.
- **Features**: Non-blocking, event-driven architecture, capable of asynchronous I/O.
- **Why Use**: It’s lightweight, efficient, and its non-blocking I/O model makes it ideal for data-intensive real-time applications that run across distributed devices.

## Workflow of MERN Stack

1. **Client Requests**: The process begins with the client sending a request to the server, typically through a web interface created with React.js.
2. **Server Interaction**: Express.js running on Node.js handles the incoming request. It can interact with the database to create, read, update, or delete data.
3. **Database Operations**: MongoDB stores or retrieves data, which is then sent back to the server.
4. **Response Generation**: The server may perform additional processing based on the data retrieved or manipulated in the database before sending a response back to the client.
5. **Displaying Data**: React.js then takes this data and updates the view for the user, without needing a full page refresh.

##  Installing the MERN Stack on AWS EC2

These are the steps involved in the  process of setting up the MERN stack on an AWS EC2 instance.

## Step 1: Set Up AWS EC2 Instance

1. **Log In to your AWS Console** and navigate to the EC2 dashboard.
2. **Launch an Instance**:
   - Select an Amazon Machine Image (AMI), such as Amazon Linux 2 or Ubuntu.
   - Choose an instance type, like `t3.micro`, which is free tier eligible.
   - Configure instance details, add storage, and configure a security group to allow traffic on ports 80 (HTTP), 443 (HTTPS), and 3000 (React).
   - Launch the instance

## Step 2: Connect to Your Instance

Connect to your EC2 instance using SSH:

         
         ssh -i /path/to/-key-pair.pem ubuntu@ipaddress

 Update your Ubuntu Ec2 Instance

          sudo apt update
          sudo apt upgrade

 install node js and npm (node package manager) 

          curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
          sudo apt-get install -y nodejs

 
# Creating a Todo application
### this application will be able to
  * create new task
  * display a list of all tasks
  * delete completed tasks
    
## step one :  Make a new directory, name it "todo" and move into it

         sudo mkdir
         cd todo

## step two :   Run an NPM init to create a package.json file

         npm init

## step three :  Install Express Js

         npm install express

## step four : create an index.js file

         touuch index.js

## step five :  Installing dotenv module

         npm install dotenv

## step six :  Open the index.js file , use nano or vim and write a simple code in it

            sudo nano index.js



            const express = require('express');
            require('dotenv').config();
            
            const app = express();
            
            const port = process.env.PORT || 5000;
            
            app.use((req, res, next) => {
            res.header("Access-Control-Allow-Origin", "\*");
            res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
            next();
            });
            
            app.use((req, res, next) => {
            res.send('Welcome to Express');
            });
            
            app.listen(port, () => {
            console.log(`Server running on port ${port}`)
            });

## step seven : start server to see if it works

first, go back to your aws console and allow access from all ips to your port 5000

then visit your ipaddess:5000

## step eight :  For each task, we need to create a routes for the different end points that the todo application will depend on

     mkdir routes
     cd routes

   * create an api.js file in it

           touch api.js

   * open the file using 

           sudo nano api.js

   * paste the code below

                    const express = require ('express');
                  const router = express.Router();
                  
                  router.get('/todos', (req, res, next) =&gt; {
                  
                  });
                  
                  router.post('/todos', (req, res, next) =&gt; {
                  
                  });
                  
                  router.delete('/todos/:id', (req, res, next) =&gt; {
                  
                  })
                  
                  module.exports = router;








