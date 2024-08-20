# Understanding the MEAN stack

## MEAN Stack is a JavaScript Stack that is used for easier and faster deployment of full-stack web applications. MEAN Stack comprises 4 technologies namely: MongoDB, Express.js, Angular.js, Node.js. It is designed to make the development process smoother and easier. It is a collection of software packages and other development tools that make web development faster and easier. Web developers use it to produce web applications that are dynamic and more sustainable. 

* MongoDB: Non-relational open-source document-oriented database.
* Express JS: Node.js framework that makes it easier to organize your application’s functionality with middleware and routing and simplify APIs.
* Angular JS: It is a JavaScript open-source front-end structural framework that is mainly used to develop single-page web applications(SPAs).
* Node JS: is an open-source and cross-platform runtime environment for building highly scalable server-side applications using JavaScript.

## How MEAN stack works

 WE ARE GOING TO EXPLORE THE MEAN STACK BY CREATING A SIMPLE BOOK REGISTER WEB APP

# Step One

##   Setting Up a MEAN Stack on AWS EC2 Instance

  * sign in to your aws account and create an ec2 instance

     ##output ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/ec2%20instance.png)
    
  *   Access your instance by logging in via ssh using terminal or git bash

            ssh - i (your key pair) ubuntu@(your ip-address)

      output : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/accessed%20instance.png)

  *  Update and upgrade your Ubuntu server

            sudo apt update && sudo apt upgrade

# Step Two : Installing Node js

  * Install Node js, Npm

              sudo apt install nodejs npm -y
               node -v
               npm -v

     OUTPUT : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/installed%20nodejs%20and%20npm.png)

# Step Three  : Installing Mongo DB

  * Import Mongodb Repository key

           sudo apt install gnupg curl
           curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
              sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
              --dearmor

  * Add Mongodb into your Ubuntu System

        echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /        etc/apt/sources.list.d/mongodb-org-7.0.list


   * Update Ubuntu again with the new Repo we added

           sudo apt update

   * Once the repository has been added and confirmed to be working, we can then proceed to installing mongodb, use the command below to install mongodb

            sudo apt -y install mongodb-org

   * Confirm mongodb installation, to do this , run the code below :

             mongo --version

        Output : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/installed%20mongodb.png)


 # Step Four  : Setting up the project

   * Install both body-parser, mongoose ,and express js

           npm isntall body-parser
           npm install express
           npm install mongoose

        OUTPUT: ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/installed%20express%20and%20mongoose.png)

   * Create a directory, name it Books ( this would be our project directory ), and initialize a new package in order to generate a package.json file, run the code below:

           mkdir Books
           npm init -y

   
   * Create a new file and name it server.js. and paste the source code below in it :

            sudo nano server.js

     source code :

              var express = require('express');
         var bodyParser = require('body-parser');
         var mongoose = require('mongoose');
         var app = express();
         
         // Connect to MongoDB
         var dbHost = 'mongodb://localhost:27017/test';
         mongoose.connect(dbHost, {
           useNewUrlParser: true,
           useUnifiedTopology: true
         });
         
         // Handle connection events
         mongoose.connection.on('connected', function() {
           console.log('Mongoose connected to ' + dbHost);
         });
         
         mongoose.connection.on('error', function(err) {
           console.log('Mongoose connection error: ' + err);
         });
         
         mongoose.connection.on('disconnected', function() {
           console.log('Mongoose disconnected');
         });
         
         // Middleware
         app.use(express.static(__dirname + '/public'));
         app.use(bodyParser.json());
         app.use(bodyParser.urlencoded({ extended: true }));
         
         // Routes
         require('./apps/routes')(app);
         
         // Start server
         app.set('port', 3300);
         app.listen(app.get('port'), function() {
           console.log('Server up: http://localhost:' + app.get('port'));
         });

    
# Step Five :  setting  up routes to  the server.

   * Create a new folder inside the Books directory and name it apps, then move into it.

             mkdir apps
             cd apps

   * Create a new routes file, and paste the source code below in it :;

            sudo nano routes.js

      Source Code :

             var Book = require('./models/book');
         var path = require('path');
         
         module.exports = function(app) {
           
           // Get all books
           app.get('/book', async function(req, res) {
             try {
               let result = await Book.find({});
               res.json(result);
             } catch (err) {
               res.status(500).json({ error: err.message });
             }
           });
         
           // Add a new book
           app.post('/book', async function(req, res) {
             try {
               var book = new Book({
                 name: req.body.name,
                 isbn: req.body.isbn,
                 author: req.body.author,
                 pages: req.body.pages
               });
               let result = await book.save();
               res.json({
                 message: "Successfully added book",
                 book: result
               });
             } catch (err) {
               res.status(500).json({ error: err.message });
             }
           });
         
           // Delete a book by ISBN
           app.delete('/book/:isbn', async function(req, res) {
             try {
               let result = await Book.findOneAndRemove({ isbn: req.params.isbn });
               res.json({
                 message: "Successfully deleted the book",
                 book: result
               });
             } catch (err) {
               res.status(500).json({ error: err.message });
             }
           });
         
           // Serve the index.html file for any other routes
           app.get('*', function(req, res) {
             res.sendFile(path.join(__dirname, '../public', 'index.html'));
           });
         };
         
  * Next, we have to create another directory insode the app directory, this would be called models

             mkdir models
             cd models

  * Create a new file and call it book.js, and paste the source code below in it

            sudo nano book.js
    
     source code :

              var mongoose = require('mongoose');

             var bookSchema = new mongoose.Schema({
               name: String,
               isbn: { type: String, index: true },
               author: String,
               pages: Number
             });
             
             module.exports = mongoose.model('Book', bookSchema);


# Step Six :  Accessing the routes via a front end, we will create this front end using Angular JS

  * in the project directory, create a new folder and call it public, move into it and create another file and call that script.js, then we can paste in the logic/controller to handle the requests: 

              mkdir public
              cd public
              sudo nano script.js
    
    source Code :

             
        var app = angular.module('myApp', []);
            app.controller('myCtrl', function($scope, $http) {
              $http( {
                method: 'GET',
                url: '/book'
              }).then(function successCallback(response) {
                $scope.books = response.data;
              }, function errorCallback(response) {
                console.log('Error: ' + response);
              });
              $scope.del_book = function(book) {
                $http( {
                  method: 'DELETE',
                  url: '/book/:isbn',
                  params: {'isbn': book.isbn}
                }).then(function successCallback(response) {
                  console.log(response);
                }, function errorCallback(response) {
                  console.log('Error: ' + response);
                });
              };
              $scope.add_book = function() {
                var body = '{ "name": "' + $scope.Name + 
                '", "isbn": "' + $scope.Isbn +
                '", "author": "' + $scope.Author + 
                '", "pages": "' + $scope.Pages + '" }';
                $http({
                  method: 'POST',
                  url: '/book',
                  data: body
                }).then(function successCallback(response) {
                  console.log(response);
                }, function errorCallback(response) {
                  console.log('Error: ' + response);
                });
              };
            });
            
            
            
    * Create an Index.html file to setup the forms that would collect the dtata we need ;

             sudo nano index.html

      Copy the source code below  :

             <!doctype html>
           <html ng-app="myApp" ng-controller="myCtrl">
             <head>
               <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.6.4/angular.min.js"></script>
               <script src="script.js"></script>
             </head>
             <body>
               <div>
                 <table>
                   <tr>
                     <td>Name:</td>
                     <td><input type="text" ng-model="Name"></td>
                   </tr>
                   <tr>
                     <td>Isbn:</td>
                     <td><input type="text" ng-model="Isbn"></td>
                   </tr>
                   <tr>
                     <td>Author:</td>
                     <td><input type="text" ng-model="Author"></td>
                   </tr>
                   <tr>
                     <td>Pages:</td>
                     <td><input type="number" ng-model="Pages"></td>
                   </tr>
                 </table>
                 <button ng-click="add_book()">Add</button>
               </div>
               <hr>
               <div>
                 <table>
                   <tr>
                     <th>Name</th>
                     <th>Isbn</th>
                     <th>Author</th>
                     <th>Pages</th>
                   </tr>
                   <tr ng-repeat="book in books">
                     <td>{{book.name}}</td>
                     <td>{{book.isbn}}</td>
                     <td>{{book.author}}</td>
                     <td>{{book.pages}}</td>
                     <td><input type="button" value="Delete" ng-click="del_book(book)"></td>
                   </tr>
                 </table>
               </div>
             </body>
           </html>


   
# Step Seven : Running the server, now we have been able to build a simple book register web form app, it is important to check if our project is working without errors, visit :your IP address with port 3300 , (ie)  ipaddress:3300

  * Start the server :

         node server.js

    OUTPUT : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/node%20server.js.png)

P.S, ensure you adjust your inbound rule to open port 3300

OUTPUT 1: ![mern](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/allowing%20port%203300%20in%20aws.png)

OUTPUT 2 ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/saved%20port%203300%20inbound%20rule.png)


## Finally, we can now check if our web app is up and running.

OUTPUT 1 : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/final%20output.png)

OUTPUT 2 : ![mean](https://github.com/citadelict/My-devops-Journey/blob/main/MEAN/IMAGES/final%20output(1).png)





## Conclusion,

This is a documentation of how i built and deployed a book register web app on AWS EC2 insance using the MEAN stackk 
