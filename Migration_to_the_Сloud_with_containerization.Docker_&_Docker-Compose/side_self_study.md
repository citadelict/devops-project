
# Docker and Docker Compose Documentation

## Overview

__Docker__ is an open-source platform that enables developers to automate the deployment of applications in lightweight, portable containers. Containers are isolated environments that bundle an application and all its dependencies, ensuring consistency across various environments, from development to production.

__Docker Compose__ is a tool that simplifies the definition and sharing of multi-container Docker applications. It allows users to define a multi-container environment in a single YAML file, making it easier to deploy, manage, and scale applications composed of multiple interconnected services.

### Docker Components

1.	Docker Engine: The core component of Docker, it is responsible for creating and managing Docker containers, images, networks, and volumes.

2.	Docker Images: Read-only templates that include the application’s code, runtime, libraries, and environment settings required to run the application. Images are built from Dockerfiles and can be stored in Docker registries like Docker Hub.

3.	Docker Containers: Lightweight, portable encapsulations of an environment that run applications. Containers are instances of Docker images that can be started, stopped, and replicated.

4.	Dockerfile: A script containing a series of instructions on how to build a Docker image. It defines the base image, dependencies, configuration settings, commands, and any additional files or binaries required.

5.	Docker Registry: A storage and distribution system for Docker images. Public registries like Docker Hub and private registries allow users to store and manage their images securely.

### Docker Compose Components

1.	docker-compose.yml: A YAML file defining the services, networks, and volumes for a Docker application. This file specifies how to build and configure each service and how they interact.

2.	Services: Containers defined in a docker-compose.yml file. Each service represents a containerized component of the application (e.g., a web server, database, cache).

3.	Networks: Virtual networks that connect Docker containers, allowing them to communicate with each other. By default, Docker Compose creates a network for all services in the application, enabling seamless service discovery.

4.	Volumes: Persistent storage that allows data to be shared between containers or persist even after the container is stopped or removed.

### Basic Docker Commands

-	docker build: Builds a Docker image from a Dockerfile.

```bash
docker build -t <image-name> .
```
- docker run: Creates and starts a new container from a specified image.

```bash
docker run -d --name <container-name> <image-name>
```
- docker ps: Lists all running containers.

```bash
docker ps
```
- docker stop: Stops a running container.

```bash
docker stop <container-name>
```
- docker rm: Removes a stopped container.

```bash
docker rm <container-name>
```
- docker rmi: Removes a Docker image.

```bash
docker rmi <image-name>
```

### Basic Docker Compose Commands

- docker-compose up: Builds, (re)creates, starts, and attaches to containers for a service.

```bash
docker-compose up
```

- docker-compose down: Stops and removes containers, networks, volumes, and images created by up.

```bash
docker-compose down
```

- docker-compose build: Builds or rebuilds services defined in the docker-compose.yml.

```bash
docker-compose build
```

- docker-compose ps: Lists all running containers in the Docker Compose environment.

```bash
docker-compose ps
```
- docker-compose exec: Runs a command in a running container.

```bash
docker-compose exec <service-name> <command>
```

### Example docker-compose.yml File

Below is a basic example of a docker-compose.yml file for a web application using NGINX and a PostgreSQL database:

```yaml
version: '3'
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - webnet

  db:
    image: postgres:alpine
    environment:
      POSTGRES_USER: example
      POSTGRES_PASSWORD: example
    volumes:
      - dbdata:/var/lib/postgresql/data
    networks:
      - webnet

volumes:
  dbdata:

networks:
  webnet:
```

This configuration defines two services, web and db, where web uses the NGINX server and db uses PostgreSQL. The services are connected via a custom network named webnet.


### Conclusion

Docker and Docker Compose provide powerful tools for developing, deploying, and managing containerized applications. Docker simplifies the process of creating and running containers, while Docker Compose offers an easy way to define and manage multi-container applications. Together, they streamline development workflows and enable consistent, scalable deployments.
